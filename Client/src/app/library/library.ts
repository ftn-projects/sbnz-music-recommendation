import { Component, inject, signal, computed } from '@angular/core';
import { FormControl } from '@angular/forms';
import { UserService } from '../services/user.service';
import { MusicPlayerService } from '../services/music-player.service';
import { Track } from '../models/track.model';
import { debounceTime, distinctUntilChanged } from 'rxjs';

@Component({
  selector: 'app-library',
  standalone: false,
  templateUrl: './library.html',
  styleUrl: './library.scss'
})
export class Library {
  private readonly userService = inject(UserService);
  private readonly musicPlayerService = inject(MusicPlayerService);

  readonly searchControl = new FormControl('');
  readonly searchResults = signal<Track[]>([]);
  readonly isSearching = signal(false);
  readonly library = this.userService.library;

  // Mock data for demonstration - remove when API is ready
  private mockTracks: Track[] = [
    { id: '1', title: 'Bohemian Rhapsody', artist: 'Queen', releaseYear: 1975, duration: 354, explicit: false },
    { id: '2', title: 'Stairway to Heaven', artist: 'Led Zeppelin', releaseYear: 1971, duration: 482, explicit: false },
    { id: '3', title: 'Hotel California', artist: 'Eagles', releaseYear: 1976, duration: 391, explicit: false },
    { id: '4', title: 'Imagine', artist: 'John Lennon', releaseYear: 1971, duration: 183, explicit: false },
    { id: '5', title: 'Smells Like Teen Spirit', artist: 'Nirvana', releaseYear: 1991, duration: 301, explicit: false }
  ];

  onSearchClick(): void {
    const query = this.searchControl.value;
    if (query && query.trim().length > 0) {
      this.performSearch(query);
    } else {
      this.searchResults.set([]);
    }
  }

  performSearch(query: string): void {
    this.isSearching.set(true);
    
    // Mock search - filter mock tracks
    const results = this.mockTracks.filter(track => 
      track.title?.toLowerCase().includes(query.toLowerCase()) ||
      track.artist?.toLowerCase().includes(query.toLowerCase())
    );
    this.searchResults.set(results);
    this.isSearching.set(false);

    // TODO: Replace with actual API call
    // this.userService.searchTracks(query).subscribe({
    //   next: (results) => {
    //     this.searchResults.set(results);
    //     this.isSearching.set(false);
    //   },
    //   error: () => {
    //     this.isSearching.set(false);
    //   }
    // });
  }

  addToLibrary(track: Track): void {
    this.userService.addToLibrary(track);
  }

  removeFromLibrary(trackId: string): void {
    this.userService.removeFromLibrary(trackId);
  }

  isInLibrary(trackId: string): boolean {
    return this.userService.isInLibrary(trackId);
  }

  formatDuration(seconds?: number): string {
    if (!seconds) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  playTrack(track: Track): void {
    this.musicPlayerService.playTrack(track);
  }
}
