package com.ftn.controller;

import com.ftn.dto.ProfileRequestDTO;
import com.ftn.dto.SeedTrackRequestDTO;
import com.ftn.dto.TrackDTO;
import com.ftn.mapper.TrackMapper;
import com.ftn.model.TrackEntity;
import com.ftn.model.track.TrackCandidate;
import com.ftn.repository.GenreRepository;
import com.ftn.repository.TrackRepository;
import com.ftn.service.RecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {
    private final RecommendationService recommendations;
    private final TrackRepository trackRepository;
    private final GenreRepository genreRepository;
    private final TrackMapper trackMapper;

    @Autowired
    public RecommendationController(RecommendationService recommendationService, TrackRepository trackRepository, GenreRepository genreRepository, TrackMapper trackMapper) {
        this.recommendations = recommendationService;
        this.trackRepository = trackRepository;
        this.genreRepository = genreRepository;
        this.trackMapper = trackMapper;
    }

    @PostMapping("/profile")
    public ResponseEntity<?> recommendForProfile(@RequestBody ProfileRequestDTO dto) {
        var candidates = this.recommendations.recommendForProfile(
                dto.userId,
                dto.profileId);
        return ResponseEntity.ok(mapRecommendations(candidates));
    }

    @PostMapping("/seed-track")
    public ResponseEntity<?> recommendForTrack(@RequestBody SeedTrackRequestDTO dto) {
        var candidates = this.recommendations.recommendForTrack(
                dto.userId,
                dto.trackId,
                dto.yearDeltaMax);
        return ResponseEntity.ok(mapRecommendations(candidates));
    }

    private List<TrackDTO> mapRecommendations(List<TrackCandidate> candidates) {
        // Fetch all tracks by their IDs
        var trackIds = candidates.stream().map(TrackCandidate::getTrackId).collect(Collectors.toList());
        var tracks = trackRepository.findAllById(trackIds);

        // Create a map for quick lookup: trackId -> trackEntity
        var trackMap = tracks.stream()
                .collect(Collectors.toMap(TrackEntity::getId, track -> track));

        // Map candidates to DTOs, preserving order and including scores
        return candidates.stream().map(candidate -> {
            var track = trackMap.get(candidate.getTrackId());
            if (track == null) {
                return null; // Skip if track not found
            }
            var dto = trackMapper.toDTO(track);
            var genres = genreRepository.findAllById(track.getGenreIds());
            dto.setGenres(genres);
            dto.setScore(candidate.getScore()); // Add the score from the candidate
            return dto;
        })
                .filter(Objects::nonNull) // Remove nulls
                .collect(Collectors.toList());
    }

}
