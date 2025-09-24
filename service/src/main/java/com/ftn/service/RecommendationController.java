package com.ftn.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ftn.model.User;
import com.ftn.model.request.ProfileRequest;
import com.ftn.model.request.SeedTrackRequest;
import com.ftn.model.track.TrackCandidate;
import com.ftn.service.dto.ProfileRequestDTO;
import com.ftn.service.dto.SeedTrackRequestDTO;
import com.ftn.util.CsvRepository;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {
    private final KieContainer kieContainer;
    private final CsvRepository csvRepository;

    public RecommendationController(KieContainer kieContainer) {
        this.kieContainer = kieContainer;
        this.csvRepository = new CsvRepository();
    }

    @PostMapping("/profile")
    public ResponseEntity<List<UUID>> createProfileRequest(@RequestBody ProfileRequestDTO dto){
        var session = getNewSession(dto.userId);

        session.insert(new ProfileRequest(UUID.randomUUID(), dto.userId, dto.profileId));
        session.fireAllRules();

        var recommendations = session.getObjects(o -> o instanceof TrackCandidate)
            .stream()
            .map(o -> ((TrackCandidate) o).getTrackId())
            .collect(Collectors.toList());
        
        return ResponseEntity.ok(recommendations);
    }

    @PostMapping("/seed-track")
    public ResponseEntity<List<UUID>> createSeedTrackRequest(@RequestBody SeedTrackRequestDTO dto){
        var session = getNewSession(dto.userId);

        session.insert(new SeedTrackRequest(UUID.randomUUID(), dto.userId, dto.seedTrackId, dto.yearDeltaMax));
        session.fireAllRules();

        var recommendations = session.getObjects(o -> o instanceof TrackCandidate)
            .stream()
            .map(o -> ((TrackCandidate) o).getTrackId())
            .collect(Collectors.toList());

        return ResponseEntity.ok(recommendations);
    }

    private KieSession getNewSession(UUID userId) {
        var session = this.kieContainer.newKieSession("appKsession");

        for (var genre : csvRepository.loadGenres()) {
            session.insert(genre);
        }

        var preferences = csvRepository.loadGenrePreferences(userId);
        session.insert(new User(userId, "User", 23, preferences, new User.Preferences(false, true, true)));

        for (var track : csvRepository.loadTracks()) {
            session.insert(track);
            session.insert(new TrackCandidate(userId, track.getId()));
        }

        return session;
    }
}
