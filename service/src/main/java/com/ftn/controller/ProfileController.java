package com.ftn.controller;

import com.ftn.repository.ProfileRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {
    private final ProfileRepository profileRepository;

    public ProfileController(ProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    @GetMapping
    public ResponseEntity<?> findAll() {
        var profiles = profileRepository.findAll();
        return ResponseEntity.ok(profiles);
    }
}
