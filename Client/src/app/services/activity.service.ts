import { HttpClient } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";
import { UserService } from "./user.service";

@Injectable({
  providedIn: 'root'
})
export class ActivityService {
    private readonly http = inject(HttpClient);
    private readonly apiUrl = 'http://localhost:8080/api/activity'; 

    constructor(private userService: UserService) {}

    listenActivity(trackId: string, duration: number) {
        const activity = { userId: this.userService.userId(), trackId, duration };
        return this.http.post(`${this.apiUrl}/listen`, activity);
    }

    likeActivity(trackId: string) { 
        const activity = { userId: this.userService.userId(), trackId };
        return this.http.post(`${this.apiUrl}/like`, activity);
    }

    skipActivity(trackId: string, duration: number) { 
        const activity = { userId: this.userService.userId(), trackId, duration };
        return this.http.post(`${this.apiUrl}/skip`, activity);
    }
}