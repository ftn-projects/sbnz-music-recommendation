import { Injectable, signal } from '@angular/core';
import { Track } from '../models/track.model';

@Injectable({
  providedIn: 'root'
})
export class MusicPlayerService {
  readonly currentTrack = signal<Track | null>(null);

  playTrack(track: Track): void {
    this.currentTrack.set(track);
  }
}
