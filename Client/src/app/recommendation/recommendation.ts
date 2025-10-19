import { Component, inject, signal } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { UserService } from '../services/user.service';
import { Track } from '../models/track.model';
import { Profile } from '../models/profile.model';

@Component({
  selector: 'app-recommendation',
  standalone: false,
  templateUrl: './recommendation.html',
  styleUrl: './recommendation.scss'
})
export class Recommendation {
  private readonly userService = inject(UserService);

  readonly recommendations = signal<Track[]>([]);
  readonly isLoading = signal(false);
  readonly profiles = signal<Profile[]>([
    { id: '1', name: 'Rock Lover' },
    { id: '2', name: 'Pop Enthusiast' },
    { id: '3', name: 'Jazz Aficionado' },
    { id: '4', name: 'Classical Connoisseur' },
    { id: '5', name: 'Hip Hop Head' }
  ]);

  readonly preferencesForm = new FormGroup({
    includeExplicit: new FormControl(false),
    includeLibraryTracks: new FormControl(false),
    includeRecentTracks: new FormControl(false),
    selectedProfile: new FormControl<string | null>(null)
  });

  // Mock recommended tracks
  private mockRecommendations: Track[] = [
    { id: '10', title: 'Comfortably Numb', artist: 'Pink Floyd', releaseYear: 1979, duration: 382, explicit: false },
    { id: '11', title: 'Wish You Were Here', artist: 'Pink Floyd', releaseYear: 1975, duration: 334, explicit: false },
    { id: '12', title: 'Sweet Child O Mine', artist: 'Guns N Roses', releaseYear: 1987, duration: 356, explicit: false },
    { id: '13', title: 'November Rain', artist: 'Guns N Roses', releaseYear: 1991, duration: 537, explicit: false },
    { id: '14', title: 'Under Pressure', artist: 'Queen & David Bowie', releaseYear: 1981, duration: 248, explicit: false }
  ];

  getRecommendations(): void {
    this.isLoading.set(true);

    const preferences = this.preferencesForm.value;
    
    console.log('Getting recommendations with preferences:', preferences);

    // Mock API call with delay
    setTimeout(() => {
      this.recommendations.set(this.mockRecommendations);
      this.isLoading.set(false);
    }, 800);

    // TODO: Replace with actual API call
    // const payload = {
    //   includeExplicit: preferences.includeExplicit ?? false,
    //   includeLibraryTracks: preferences.includeLibraryTracks ?? false,
    //   includeRecentTracks: preferences.includeRecentTracks ?? false,
    //   profileId: preferences.selectedProfile ?? null
    // };
    // this.userService.getRecommendations(payload).subscribe({
    //   next: (recommendations) => {
    //     this.recommendations.set(recommendations);
    //     this.isLoading.set(false);
    //   },
    //   error: () => {
    //     this.isLoading.set(false);
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

  clearRecommendations(): void {
    this.recommendations.set([]);
  }
}
