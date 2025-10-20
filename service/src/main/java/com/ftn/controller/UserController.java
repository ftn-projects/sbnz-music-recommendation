package com.ftn.controller;

import com.ftn.dto.*;
import com.ftn.mapper.TrackMapper;
import com.ftn.model.UserEntity;
import com.ftn.repository.GenreRepository;
import com.ftn.repository.TrackRepository;
import com.ftn.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserRepository userRepository;
    private final TrackRepository trackRepository;
    private final GenreRepository genreRepository;
    private final TrackMapper trackMapper;

    public UserController(
            UserRepository userRepository,
            TrackRepository trackRepository,
            GenreRepository genreRepository,
            TrackMapper trackMapper) {
        this.userRepository = userRepository;
        this.trackRepository = trackRepository;
        this.genreRepository = genreRepository;
        this.trackMapper = trackMapper;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterDTO dto) {
        userRepository.save(new UserEntity(
                dto.getName(), dto.getAge(), dto.getUsername()
        ));
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/login/{username}")
    public ResponseEntity<?> login(@PathVariable String username) {
        var userId = userRepository.findByUsername(username).getId();
        return ResponseEntity.ok(userId);
    }

    @GetMapping("/preferences/{userId}")
    public ResponseEntity<?> getPreferences(@PathVariable UUID userId) {
        var userEntity = userRepository.findById(userId);
        if (userEntity.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        var preferences = userEntity.get().getPreferences();
        return ResponseEntity.ok(preferences);
    }

    @PutMapping("/preferences")
    public ResponseEntity<?> updatePreferences(@RequestBody PreferenceDTO dto) {
        var userEntity = userRepository.findById(dto.getUserId());
        if (userEntity.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        var user = userEntity.get();
        var preferences = user.getPreferences();

        if (Objects.equals(dto.getPreference(), "explicitContent"))
            preferences.setExplicitContent(dto.getValue());
        else if (Objects.equals(dto.getPreference(), "includeOwned"))
            preferences.setIncludeOwned(dto.getValue());
        else if (Objects.equals(dto.getPreference(), "includeRecent"))
            preferences.setIncludeRecent(dto.getValue());
        else return ResponseEntity.badRequest().build();

        userRepository.save(user);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/library")
    public ResponseEntity<?> updateLibrary(@RequestBody LibraryUpdateDTO dto) {
        var userEntity = userRepository.findById(dto.getUserId());
        if (userEntity.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        var user = userEntity.get();
        var libraryTrackIds = user.getLibraryTrackIds();

        if (dto.getAdd()) {
            libraryTrackIds.add(dto.getTrackId());
        } else {
            libraryTrackIds.remove(dto.getTrackId());
        }

        user.setLibraryTrackIds(libraryTrackIds);
        userRepository.save(user);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/library/{userId}")
    public ResponseEntity<?> getUserLibrary(@PathVariable UUID userId) {
        var userEntity = userRepository.findById(userId);
        if (userEntity.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        var tracks = trackRepository.findAllById(userEntity.get().getLibraryTrackIds());
        var dtos = tracks.stream().map(track -> {
            var dto = trackMapper.toDTO(track);
            var genres = genreRepository.findAllById(track.getGenreIds());
            dto.setGenres(genres);
            return dto;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }
}
