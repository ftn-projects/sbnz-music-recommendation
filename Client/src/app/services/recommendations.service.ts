import { HttpClient } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";

@Injectable({
  providedIn: 'root'
})
export class RecommendationsService {
    private readonly http = inject(HttpClient);
    private readonly apiUrl = 'http://localhost:8080/api/recommendations'; 

    recommendationsByProfile(profileId: string, userId: string) {
        return this.http.post<any>(`${this.apiUrl}/profile`, { userId, profileId });
    }

    recommendationsByTrack(trackId: string, userId: string) {
        return this.http.post<any>(`${this.apiUrl}/seed-track`, { userId, trackId });
    }
}