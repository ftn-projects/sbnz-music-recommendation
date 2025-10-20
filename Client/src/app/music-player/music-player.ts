import { Component, inject, signal, computed, effect } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { UserService } from '../services/user.service';
import { MusicPlayerService } from '../services/music-player.service';
import { Track } from '../models/track.model';
import { filter } from 'rxjs';

@Component({
  selector: 'app-music-player',
  standalone: false,
  templateUrl: './music-player.html',
  styleUrl: './music-player.scss'
})
export class MusicPlayer {
  private readonly router = inject(Router);
  private readonly userService = inject(UserService);
  private readonly musicPlayerService = inject(MusicPlayerService);

  readonly currentTrack = this.musicPlayerService.currentTrack;
  readonly isPlaying = signal(false);
  readonly currentTime = signal(0);
  readonly duration = computed(() => this.currentTrack()?.duration ?? 0);
  readonly progress = computed(() => {
    const dur = this.duration();
    return dur > 0 ? (this.currentTime() / dur) * 100 : 0;
  });

  readonly showPlayer = signal(false);

  private intervalId: any = null;

  constructor() {
    // Track route changes to show/hide player
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe(() => {
      const url = this.router.url;
      this.showPlayer.set(url === '/library' || url === '/recommendation');
    });

    // Set initial state
    const url = this.router.url;
    this.showPlayer.set(url === '/library' || url === '/recommendation');

    // Auto-play when new track is set
    effect(() => {
      const track = this.currentTrack();
      if (track) {
        this.currentTime.set(0);
        this.play();
      }
    });
  }

  play(): void {
    this.isPlaying.set(true);
    this.startProgress();
  }

  pause(): void {
    this.isPlaying.set(false);
    this.stopProgress();
  }

  togglePlayPause(): void {
    if (this.isPlaying()) {
      this.pause();
    } else {
      this.play();
    }
  }

  next(): void {
    const currentPlayTime = this.currentTime();
    if (this.musicPlayerService.next(currentPlayTime, true)) { // true = skip
      this.currentTime.set(0);
      this.play();
    }
  }

  previous(): void {
    const currentPlayTime = this.currentTime();
    if (this.musicPlayerService.previous(currentPlayTime)) {
      this.currentTime.set(0);
      this.play();
    }
  }

  private startProgress(): void {
    this.stopProgress();
    this.intervalId = setInterval(() => {
      const current = this.currentTime();
      const dur = this.duration();
      if (current < dur) {
        const newTime = current + 1;
        this.currentTime.set(newTime);
        // Update play time in service
        this.musicPlayerService.updatePlayTime(newTime);
      } else {
        // Song finished naturally, play next (not a skip)
        const currentPlayTime = this.currentTime();
        if (this.musicPlayerService.hasNext()) {
          this.musicPlayerService.next(currentPlayTime, false); // false = not a skip
          this.currentTime.set(0);
          this.play();
        } else {
          this.pause();
          this.currentTime.set(0);
        }
      }
    }, 1000);
  }

  private stopProgress(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  seekTo(event: Event): void {
    const input = event.target as HTMLInputElement;
    const percentage = parseFloat(input.value);
    const newTime = (percentage / 100) * this.duration();
    this.currentTime.set(Math.floor(newTime));
  }

  formatTime(seconds: number): string {
    if (!seconds) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  isInLibrary(): boolean {
    const track = this.currentTrack();
    return track ? this.userService.isInLibrary(track.id!) : false;
  }

  toggleLibrary(): void {
    const track = this.currentTrack();
    if (!track) return;

    if (this.isInLibrary()) {
      // Remove from library
      this.userService.removeFromLibrary(track.id!);
    } else {
      // Add to library AND log like activity
      this.userService.addToLibrary(track);
      this.musicPlayerService.likeCurrentTrack();
    }
  }

  ngOnDestroy(): void {
    this.stopProgress();
  }
}
