package com.ftn.service;

import com.ftn.model.event.GenreDislikedEvent;
import com.ftn.model.event.GenreLikedEvent;
import com.ftn.model.event.ListenEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Tracks user activity from CEP events - recent tracks and genre preferences.
 */
@Service
public class UserActivityService {
    private static final Logger log = LoggerFactory.getLogger(UserActivityService.class);

    @Value("${user-activity.recent-track-expiry-ms:600000}")
    private long recentTrackExpiryMs;

    // userId -> (trackId -> last listen timestamp)
    private final Map<UUID, Map<UUID, Long>> recentTracks = new ConcurrentHashMap<>();

    // userId -> (genreId -> score delta)
    private final Map<UUID, Map<UUID, Double>> genreUpdates = new ConcurrentHashMap<>();

    public void onListenEvent(ListenEvent event) {
        recentTracks.computeIfAbsent(event.getUserId(), k -> new ConcurrentHashMap<>())
                .put(event.getTrackId(), System.currentTimeMillis());
    }

    public void onGenreLikedEvent(GenreLikedEvent event) {
        genreUpdates.computeIfAbsent(event.getUserId(), k -> new ConcurrentHashMap<>())
                .merge(event.getGenreId(), 0.1, Double::sum);
    }

    public void onGenreDislikedEvent(GenreDislikedEvent event) {
        genreUpdates.computeIfAbsent(event.getUserId(), k -> new ConcurrentHashMap<>())
                .merge(event.getGenreId(), 0.1, Double::sum);
    }

    public Set<UUID> getRecentTrackIds(UUID userId) {
        Map<UUID, Long> tracks = recentTracks.get(userId);
        if (tracks == null || tracks.isEmpty()) {
            return Set.of();
        }

        long cutoff = System.currentTimeMillis() - recentTrackExpiryMs;
        tracks.entrySet().removeIf(entry -> entry.getValue() < cutoff);

        if (tracks.isEmpty()) {
            recentTracks.remove(userId);
            return Set.of();
        }

        return tracks.keySet();
    }

    public Map<UUID, Double> consumeGenreUpdates(UUID userId) {
        return genreUpdates.remove(userId);
    }

    public Set<UUID> getUsersWithGenreUpdates() {
        return genreUpdates.keySet();
    }
}
