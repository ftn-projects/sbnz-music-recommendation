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
    // TODO: Implement queue/playlist logic
    console.log('Next track');
  }

  previous(): void {
    // TODO: Implement queue/playlist logic
    console.log('Previous track');
  }

  private startProgress(): void {
    this.stopProgress();
    this.intervalId = setInterval(() => {
      const current = this.currentTime();
      const dur = this.duration();
      if (current < dur) {
        this.currentTime.set(current + 1);
      } else {
        this.pause();
        this.currentTime.set(0);
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
      this.userService.removeFromLibrary(track.id!);
    } else {
      this.userService.addToLibrary(track);
    }
  }

  ngOnDestroy(): void {
    this.stopProgress();
  }
}
