import { Injectable, signal, inject } from '@angular/core';
import { Track } from '../models/track.model';
import { ActivityService } from './activity.service';

export type QueueSource = 'library' | 'search' | 'recommendations';

@Injectable({
  providedIn: 'root'
})
export class MusicPlayerService {
  private readonly activityService = inject(ActivityService);
  
  readonly currentTrack = signal<Track | null>(null);
  readonly queue = signal<Track[]>([]);
  readonly currentIndex = signal<number>(-1);
  readonly queueSource = signal<QueueSource | null>(null);
  readonly currentPlayTime = signal<number>(0); // Track how long current song has been playing

  setQueue(tracks: Track[], source: QueueSource, startIndex: number = 0): void {
    this.queue.set(tracks);
    this.queueSource.set(source);
    this.currentIndex.set(startIndex);
    
    if (tracks.length > startIndex) {
      this.currentTrack.set(tracks[startIndex]);
    }
  }

  playTrack(track: Track, source: QueueSource, allTracks: Track[], currentPlayTime: number = 0): void {
    const trackIndex = allTracks.findIndex(t => t.id === track.id);
    
    // Send listen activity for previous track if it exists
    const previousTrack = this.currentTrack();
    if (previousTrack && previousTrack.id) {
      this.activityService.listenActivity(previousTrack.id, currentPlayTime).subscribe({
        error: (err) => console.error('Failed to log listen activity:', err)
      });
    }
    
    // Only update queue if source changed or queue is empty
    const currentSource = this.queueSource();
    if (currentSource !== source || this.queue().length === 0) {
      this.setQueue(allTracks, source, trackIndex);
    } else {
      // Same source, just update current track and index
      this.currentIndex.set(trackIndex);
      this.currentTrack.set(track);
    }
    
    // Reset play time for new track
    this.currentPlayTime.set(0);
  }

  next(currentPlayTime: number = 0, isSkip: boolean = false): boolean {
    const currentQueue = this.queue();
    const currentIdx = this.currentIndex();
    const previousTrack = this.currentTrack();
    
    if (currentQueue.length === 0) return false;

    // Send activity for previous track
    if (previousTrack && previousTrack.id) {
      if (isSkip) {
        // Send skip activity
        this.activityService.skipActivity(previousTrack.id, currentPlayTime).subscribe({
          error: (err) => console.error('Failed to log skip activity:', err)
        });
      } else {
        // Send listen activity (natural progression)
        this.activityService.listenActivity(previousTrack.id, currentPlayTime).subscribe({
          error: (err) => console.error('Failed to log listen activity:', err)
        });
      }
    }

    // Loop to beginning if at end
    const nextIndex = (currentIdx + 1) % currentQueue.length;
    this.currentIndex.set(nextIndex);
    this.currentTrack.set(currentQueue[nextIndex]);
    this.currentPlayTime.set(0);
    
    return true;
  }

  previous(currentPlayTime: number = 0): boolean {
    const currentQueue = this.queue();
    const currentIdx = this.currentIndex();
    const previousTrack = this.currentTrack();
    
    if (currentQueue.length === 0) return false;

    // Send skip activity for previous track
    if (previousTrack && previousTrack.id) {
      this.activityService.skipActivity(previousTrack.id, currentPlayTime).subscribe({
        error: (err) => console.error('Failed to log skip activity:', err)
      });
    }

    // Loop to end if at beginning
    const prevIndex = currentIdx <= 0 ? currentQueue.length - 1 : currentIdx - 1;
    this.currentIndex.set(prevIndex);
    this.currentTrack.set(currentQueue[prevIndex]);
    this.currentPlayTime.set(0);
    
    return true;
  }

  likeCurrentTrack(): void {
    const track = this.currentTrack();
    if (track && track.id) {
      this.activityService.likeActivity(track.id).subscribe({
        error: (err) => console.error('Failed to log like activity:', err)
      });
    }
  }

  updatePlayTime(time: number): void {
    this.currentPlayTime.set(time);
  }

  hasNext(): boolean {
    return this.queue().length > 0;
  }

  hasPrevious(): boolean {
    return this.queue().length > 0;
  }
}
