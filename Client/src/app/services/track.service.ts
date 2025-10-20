import { HttpClient } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";

@Injectable({
  providedIn: 'root'
})
export class TrackService {
    private readonly http = inject(HttpClient);
  private readonly apiUrl = 'http://localhost:8080/api/tracks'; 

  searchTracks(query: string) {
    return this.http.get<any>(`${this.apiUrl}/search?term=${query}`);
  }
}