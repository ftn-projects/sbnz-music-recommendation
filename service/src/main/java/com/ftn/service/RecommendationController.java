package com.ftn.service;

import java.util.List;
import java.util.UUID;

import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ftn.model.request.ProfileRequest;
import com.ftn.model.request.SeedTrackRequest;
import com.ftn.model.track.TrackCandidate;
import com.ftn.service.dto.ProfileRequestDTO;
import com.ftn.service.dto.SeedTrackRequestDTO;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {

    private final KieSession session;

    public RecommendationController(KieContainer kieContainer) {
        this.session = kieContainer.newKieSession();
    }

    @PostMapping("/profile")
    public ResponseEntity<List<String>> createProfileRequest(@RequestBody ProfileRequestDTO dto){
        session.insert(new ProfileRequest(UUID.randomUUID(), dto.userId, dto.profileId));
        session.fireAllRules();
        List<TrackCandidate> recommendations = session.getObjects(o -> o instanceof TrackCandidate)
            .stream()
            .map(o -> (TrackCandidate) o)
            .toList();

        List<String> result = recommendations.stream()
            .map(c -> c.getTrackId().toString())
            .toList();
            
        return ResponseEntity.ok(result);
    }

    @PostMapping("/seed-track")
    public ResponseEntity<List<String>> createSeedTrackRequest(@RequestBody SeedTrackRequestDTO dto){
        session.insert(new SeedTrackRequest(UUID.randomUUID(), dto.userId, dto.seedTrackId, dto.yearDeltaMax));
        session.fireAllRules();
        List<TrackCandidate> recommendations = session.getObjects(o -> o instanceof TrackCandidate)
            .stream()
            .map(o -> (TrackCandidate) o)
            .toList();

        List<String> result = recommendations.stream()
            .map(c -> c.getTrackId().toString())
            .toList();
            
        return ResponseEntity.ok(result);
    }
}
