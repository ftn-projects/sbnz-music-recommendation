import { Component, inject, OnInit, signal } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { UserService } from '../services/user.service';
import { MusicPlayerService } from '../services/music-player.service';
import { Track } from '../models/track.model';
import { Profile } from '../models/profile.model';
import { ProfileService } from '../services/profile.service';
import { RecommendationsService } from '../services/recommendations.service';

@Component({
  selector: 'app-recommendation',
  standalone: false,
  templateUrl: './recommendation.html',
  styleUrl: './recommendation.scss'
})
export class Recommendation implements OnInit {
  ngOnInit(): void {
    this.loadProfiles();
    this.loadPreferences();
    this.setupPreferenceListeners();
    this.getRecommendationsByCurrentTrack();
  }
  private readonly userService = inject(UserService);
  private readonly profileService = inject(ProfileService);
  private readonly musicPlayerService = inject(MusicPlayerService);
  private readonly recommendationService = inject(RecommendationsService);

  readonly recommendations = signal<Track[]>([]);
  readonly isLoading = signal(false);
  readonly profiles = signal<Profile[]>([]);

  readonly preferencesForm = new FormGroup({
    includeExplicit: new FormControl(false),
    includeLibraryTracks: new FormControl(false),
    includeRecentTracks: new FormControl(false),
    selectedProfile: new FormControl('')
  });

  getRecommendations(): void {
    this.isLoading.set(true);

    const preferences = this.preferencesForm.value;
    
    console.log('Getting recommendations with preferences:', preferences);

    if (preferences.selectedProfile == null || preferences.selectedProfile === '') {
      this.getRecommendationsByCurrentTrack();
      return;
    }

    this.recommendationService.recommendationsByProfile(preferences.selectedProfile!, this.userService.userId()!).subscribe({
      next: (recommendations) => {
        this.recommendations.set(recommendations);
        this.isLoading.set(false);
      },
      error: () => {
        this.isLoading.set(false);
      }
    });
  }

  getRecommendationsByCurrentTrack(): void {
    const currentTrack = this.musicPlayerService.currentTrack();
    if (!currentTrack || !currentTrack.id) {
      return;
    }

    this.isLoading.set(true);

    this.recommendationService.recommendationsByTrack(currentTrack.id, this.userService.userId()!).subscribe({
      next: (recommendations) => {
        this.recommendations.set(recommendations);
        this.isLoading.set(false);
      },
      error: () => {
        this.isLoading.set(false);
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

  clearRecommendations(): void {
    this.recommendations.set([]);
    this.getRecommendationsByCurrentTrack();
  }

  playTrack(track: Track): void {
    const currentPlayTime = this.musicPlayerService.currentPlayTime();
    this.musicPlayerService.playTrack(track, 'recommendations', this.recommendations(), currentPlayTime);
  }

  loadProfiles(): void {
    this.profileService.loadProfiles().subscribe({
      next: (profiles) => {
        this.profiles.set(profiles);
      },
      error: () => {
        console.error('Failed to load profiles');
      }
    });
  }

  loadPreferences(): void {
    this.userService.loadPreferences().subscribe({
      next: (prefs) => {
        this.preferencesForm.patchValue({
          includeExplicit: prefs.explicitContent,
          includeLibraryTracks: prefs.includeOwned,
          includeRecentTracks: prefs.includeRecent
        }, { emitEvent: false });
      },
      error: () => {
        console.error('Failed to load preferences');
      }
    });
  }

  setupPreferenceListeners(): void {
    // Listen to checkbox changes and update backend
    this.preferencesForm.get('includeExplicit')?.valueChanges.subscribe(value => {
      if (value !== null) {
        this.userService.updatePreference('explicitContent', value);
      }
    });

    this.preferencesForm.get('includeLibraryTracks')?.valueChanges.subscribe(value => {
      if (value !== null) {
        this.userService.updatePreference('includeOwned', value);
      }
    });

    this.preferencesForm.get('includeRecentTracks')?.valueChanges.subscribe(value => {
      if (value !== null) {
        this.userService.updatePreference('includeRecent', value);
      }
    });
  }
}
