import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { FormControl } from '@angular/forms';
import { UserService } from '../services/user.service';
import { MusicPlayerService } from '../services/music-player.service';
import { Track } from '../models/track.model';
import { debounceTime, distinctUntilChanged } from 'rxjs';
import { TrackService } from '../services/track.service';

@Component({
  selector: 'app-library',
  standalone: false,
  templateUrl: './library.html',
  styleUrl: './library.scss'
})
export class Library implements OnInit {
  ngOnInit(): void {
    this.performSearch('');
    this.loadLibrary();
  }
  private readonly userService = inject(UserService);
  private readonly trackService = inject(TrackService);
  private readonly musicPlayerService = inject(MusicPlayerService);

  readonly searchControl = new FormControl('');
  readonly searchResults = signal<Track[]>([]);
  readonly isSearching = signal(false);
  readonly library = this.userService.library;

  onSearchClick(): void {
    const query = this.searchControl.value;
    this.performSearch(query ?? '');
 
  }

  performSearch(query: string): void {
    this.isSearching.set(true);
    this.trackService.searchTracks(query).subscribe({
      next: (results) => {
        console.log('Results: ', results.content);
        this.searchResults.set(results.content);
        this.isSearching.set(false);
      },
      error: () => {
        this.isSearching.set(false);
      }
    });
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

  playTrack(track: Track, source: 'library' | 'search'): void {
    const tracks = source === 'library' ? this.library() : this.searchResults();
    const currentPlayTime = this.musicPlayerService.currentPlayTime();
    this.musicPlayerService.playTrack(track, source, tracks, currentPlayTime);
  }

  loadLibrary(): void {
    this.userService.loadLibrary();
  }
}
