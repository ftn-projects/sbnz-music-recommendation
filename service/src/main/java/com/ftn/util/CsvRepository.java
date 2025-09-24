package com.ftn.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.ftn.model.Genre;
import com.ftn.model.track.Track;

public class CsvRepository {
    private static final String TRACKS_PATH = "data/tracks.csv"; 
    private static final String GENRES_PATH = "data/genres.csv";
    private static final String USER_GENRE_PREFERENCES_PATH = "data/user_genre_preferences.csv";

    public List<Track> loadTracks() {
        List<Track> tracks = new java.util.ArrayList<>();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(
                    getClass().getClassLoader().getResourceAsStream(TRACKS_PATH)))) {
            br.readLine(); // skip header
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",", -1);

                // Parse basic fields
                UUID id = UUID.fromString(parts[0]);
                String title = parts[1];
                String artist = parts[2];
                Integer releaseYear = Integer.valueOf(parts[3]);
                Boolean explicit = Boolean.valueOf(parts[4]);

                // Parse genres (semicolon-separated UUIDs)
                List<UUID> genreIds = new java.util.ArrayList<>();
                for (String genreId : parts[5].split(";")) {
                    genreIds.add(UUID.fromString(genreId));
                }

                // Parse features
                Double danceability = Double.valueOf(parts[6]);
                Double energy = Double.valueOf(parts[7]);
                Double speechiness = Double.valueOf(parts[8]);
                Double acousticness = Double.valueOf(parts[9]);
                Double instrumentalness = Double.valueOf(parts[10]);
                Double liveness = Double.valueOf(parts[11]);
                Double valence = Double.valueOf(parts[12]);

                Track.Features features = new Track.Features(
                    danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence
                );

                tracks.add(new Track(id, title, artist, releaseYear, genreIds, features, explicit, 60));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return tracks;
    }

    public List<Genre> loadGenres() {
        List<Genre> genres = new java.util.ArrayList<>();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(
                    getClass().getClassLoader().getResourceAsStream(GENRES_PATH)))) {
            br.readLine(); // skip header
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",", -1);
                UUID id = java.util.UUID.fromString(parts[0]);
                String name = parts[1];
                genres.add(new Genre(id, name));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return genres;
    }

    public Map<UUID, Double> loadGenrePreferences(UUID userId) {
        Map<UUID, Double> preferences = new java.util.HashMap<>();

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(
                    getClass().getClassLoader().getResourceAsStream(USER_GENRE_PREFERENCES_PATH)))) {
            br.readLine(); // skip header
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(",", -1);
                UUID uid = UUID.fromString(parts[0]);
                if (!uid.equals(userId)) continue;
                UUID genreId = UUID.fromString(parts[1]);
                Double score = Double.valueOf(parts[2]);
                preferences.put(genreId, score);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return preferences;
    }
}
