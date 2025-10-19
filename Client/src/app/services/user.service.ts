import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';

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
    localStorage.removeItem('userId');
    localStorage.removeItem('username');
  }

  // Load user from localStorage on app init
  loadUserFromStorage(): void {
    const userId = localStorage.getItem('userId');
    const username = localStorage.getItem('username');
    if (userId) {
      this.userId.set(userId);
      this.username.set(username);
    }
  }
}
