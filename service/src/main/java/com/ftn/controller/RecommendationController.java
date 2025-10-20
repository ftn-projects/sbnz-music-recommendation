package com.ftn.controller;

import com.ftn.dto.ProfileRequestDTO;
import com.ftn.dto.RecommendationDTO;
import com.ftn.dto.SeedTrackRequestDTO;
import com.ftn.model.track.TrackCandidate;
import com.ftn.repository.TrackRepository;
import com.ftn.service.RecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {
    private final RecommendationService recommendations;
    private final TrackRepository trackRepository;

    @Autowired
    public RecommendationController(RecommendationService recommendationService, TrackRepository trackRepository) {
        this.recommendations = recommendationService;
        this.trackRepository = trackRepository;
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
                dto.seedTrackId,
                dto.yearDeltaMax);
        return ResponseEntity.ok(mapRecommendations(candidates));
    }

    private List<RecommendationDTO> mapRecommendations(List<TrackCandidate> candidates) {
        var tracks = trackRepository.findAllById(
                candidates.stream().map(TrackCandidate::getTrackId).collect(Collectors.toList())
        );

        return IntStream.range(0, candidates.size()).mapToObj(i -> new RecommendationDTO(
                tracks.get(i).getId(),
                tracks.get(i).getTitle(),
                tracks.get(i).getArtist(),
                candidates.get(i).getScore()
        )).collect(Collectors.toList());
    }

}
