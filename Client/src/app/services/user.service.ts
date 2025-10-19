import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { Track } from '../models/track.model';

interface LoginResponse {
  userId: string;
  username?: string;
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = 'http://localhost:8080/api'; // Adjust to your backend URL
  
  // Signal to store the current userId
  readonly userId = signal<string | null>(null);
  readonly username = signal<string | null>(null);
  readonly isLoggedIn = computed(() => this.userId() !== null);
  readonly library = signal<Track[]>([]);

  login(username: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.apiUrl}/login`, { username }).pipe(
      tap(response => {
        this.userId.set(response.userId);
        this.username.set(username);
        // Optionally save to localStorage for persistence
        localStorage.setItem('userId', response.userId);
        localStorage.setItem('username', username);
      })
    );
  }

  logout(): void {
    this.userId.set(null);
    this.username.set(null);
    this.library.set([]);
    localStorage.removeItem('userId');
    localStorage.removeItem('username');
    localStorage.removeItem('library');
  }

  // Load user from localStorage on app init
  loadUserFromStorage(): void {
    const userId = localStorage.getItem('userId');
    const username = localStorage.getItem('username');
    const library = localStorage.getItem('library');
    if (userId) {
      this.userId.set(userId);
      this.username.set(username);
      if (library) {
        this.library.set(JSON.parse(library));
      }
    }
  }

  // Add track to library
  addToLibrary(track: Track): void {
    const currentLibrary = this.library();
    // Check if track already exists
    if (!currentLibrary.find(t => t.id === track.id)) {
      const updatedLibrary = [...currentLibrary, track];
      this.library.set(updatedLibrary);
      localStorage.setItem('library', JSON.stringify(updatedLibrary));
    }
  }

  // Remove track from library
  removeFromLibrary(trackId: string): void {
    const updatedLibrary = this.library().filter(t => t.id !== trackId);
    this.library.set(updatedLibrary);
    localStorage.setItem('library', JSON.stringify(updatedLibrary));
  }

  // Check if track is in library
  isInLibrary(trackId: string): boolean {
    return this.library().some(t => t.id === trackId);
  }

  // Search tracks (mock implementation - replace with actual API call)
  searchTracks(query: string): Observable<Track[]> {
    // TODO: Replace with actual API call
    return this.http.get<Track[]>(`${this.apiUrl}/tracks/search?q=${query}`);
  }
}
