import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { Track } from '../models/track.model';

interface Preferences {
  explicitContent: boolean;
  includeOwned: boolean;
  includeRecent: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = 'http://localhost:8080/api/users'; 
  
  readonly userId = signal<string | null>(null);
  readonly username = signal<string | null>(null);
  readonly isLoggedIn = computed(() => this.userId() !== null);
  readonly library = signal<Track[]>([]);
  readonly preferences = signal<Preferences>({
    explicitContent: false,
    includeOwned: false,
    includeRecent: false
  });

  login(username: string): Observable<string> {
    return this.http.post<string>(`${this.apiUrl}/login/${username}`, {}).pipe(
      tap(response => {
        this.userId.set(response);
        this.username.set(username);
        localStorage.setItem('userId', response);
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


  addToLibrary(track: Track): void {
    const currentLibrary = this.library();
    if (!currentLibrary.find(t => t.id === track.id)) {
      const updatedLibrary = [...currentLibrary, track];
      this.library.set(updatedLibrary);
      localStorage.setItem('library', JSON.stringify(updatedLibrary));

      const userId = this.userId();
      if (userId && track.id) {
        this.http.put(`${this.apiUrl}/library`, {
          userId: userId,
          trackId: track.id,
          add: true
        }).subscribe({
          error: (err) => console.error('Failed to add track to library:', err)
        });
      }
    }
  }

  removeFromLibrary(trackId: string): void {
    const updatedLibrary = this.library().filter(t => t.id !== trackId);
    this.library.set(updatedLibrary);
    localStorage.setItem('library', JSON.stringify(updatedLibrary));

    const userId = this.userId();
    if (userId) {
      this.http.put(`${this.apiUrl}/library`, {
        userId: userId,
        trackId: trackId,
        add: false
      }).subscribe({
        error: (err) => console.error('Failed to remove track from library:', err)
      });
    }
  }

  isInLibrary(trackId: string): boolean {
    return this.library().some(t => t.id === trackId);
  }

  searchTracks(query: string): Observable<Track[]> {
    return this.http.get<Track[]>(`${this.apiUrl}/tracks/search?q=${query}`);
  }

  registerUser(name: string, surname: string, username: string, age: number): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/register`, { fullName: name + ' ' + surname, username, age });
  }

  updatePreference(preference: 'explicitContent' | 'includeOwned' | 'includeRecent', value: boolean): void {
    const userId = this.userId();
    if (!userId) return;

    const currentPrefs = this.preferences();
    this.preferences.set({ ...currentPrefs, [preference]: value });

    this.http.put(`${this.apiUrl}/preferences`, {
      userId: userId,
      preference: preference,
      value: value
    }).subscribe({
      error: (err) => {
        console.error('Failed to update preference:', err);
        this.preferences.set(currentPrefs);
      }
    });
  }

  loadPreferences(): Observable<Preferences> {
    const userId = this.userId();
    console.log('Loading preferences for userId:', userId);
    if (!userId) {
      return new Observable(observer => observer.complete());
    }
    console.log('Fetching preferences from backend for userId:', userId);
    return this.http.get<Preferences>(`${this.apiUrl}/preferences/${userId}`).pipe(
      tap(prefs => {
        this.preferences.set(prefs);
      })
    );
  }

  loadLibrary(): void {
    const userId = this.userId();
    if (userId) {
      this.http.get<Track[]>(`${this.apiUrl}/library/${userId}`).subscribe({
        next: (tracks) => {
          this.library.set(tracks);
          localStorage.setItem('library', JSON.stringify(tracks));
        },
        error: (err) => console.error('Failed to load library:', err)
      });
    }
  }
}
