import { HttpClient } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";
import { Profile } from "../models/profile.model";

@Injectable({
  providedIn: 'root'
})
export class ProfileService {
    private readonly http = inject(HttpClient);
    private readonly apiUrl = 'http://localhost:8080/api/profiles'; 

    loadProfiles() {
        return this.http.get<Profile[]>(`${this.apiUrl}`);
    }
}