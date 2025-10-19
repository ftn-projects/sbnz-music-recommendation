package com.ftn.controller;

import com.ftn.dto.ProfileRequestDTO;
import com.ftn.dto.SeedTrackRequestDTO;
import com.ftn.service.RecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {
    private final RecommendationService recommendations;

    @Autowired
    public RecommendationController(RecommendationService recommendationService) {
        this.recommendations = recommendationService;
    }

    @PostMapping("/profile")
    public ResponseEntity<?> recommendForProfile(@RequestBody ProfileRequestDTO dto){
        var recommendations = this.recommendations.recommendForProfile(dto.userId, dto.profileId);
        return ResponseEntity.ok(recommendations);
    }

    @PostMapping("/seed-track")
    public ResponseEntity<?> recommendForTrack(@RequestBody SeedTrackRequestDTO dto){
        var recommendations = this.recommendations.recommendForTrack(dto.userId, dto.seedTrackId, dto.yearDeltaMax);
        return ResponseEntity.ok(recommendations);
    }
}
