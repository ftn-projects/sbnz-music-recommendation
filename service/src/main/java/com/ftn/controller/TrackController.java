package com.ftn.controller;

import com.ftn.dto.TrackDTO;
import com.ftn.mapper.TrackMapper;
import com.ftn.repository.GenreRepository;
import com.ftn.repository.TrackRepository;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tracks")
public class TrackController {
    private final TrackRepository trackRepository;
    private final GenreRepository genreRepository;
    private final TrackMapper trackMapper;

    public TrackController(
            TrackRepository trackRepository,
            GenreRepository genreRepository,
            TrackMapper trackMapper) {
        this.trackRepository = trackRepository;
        this.genreRepository = genreRepository;
        this.trackMapper = trackMapper;
    }

    @GetMapping("/search")
    public ResponseEntity<?> search(@RequestParam(required = false) String term, Pageable pageable) {
        var tracks = trackRepository.searchByTerm(term, pageable);
        var dtos = tracks.getContent().stream().map(track -> {
            var dto = trackMapper.toDTO(track);
            var genres = genreRepository.findAllById(track.getGenreIds());
            dto.setGenres(genres);
            return dto;
        }).collect(Collectors.toList());
        return ResponseEntity.ok(new PageImpl<>(dtos, pageable, tracks.getTotalElements()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> findById(@PathVariable UUID id) {
        var trackOpt = trackRepository.findById(id);
        if (trackOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        } else {
            var genres = genreRepository.findAllById(trackOpt.get().getGenreIds());
            var dto = trackMapper.toDTO(trackOpt.get());
            dto.setGenres(genres);
            return ResponseEntity.ok(dto);
        }
    }
}
