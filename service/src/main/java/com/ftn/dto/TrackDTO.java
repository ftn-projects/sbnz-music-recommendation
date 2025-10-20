package com.ftn.dto;

import com.ftn.model.AudioFeaturesEntity;
import com.ftn.model.GenreEntity;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
public class TrackDTO {
    private UUID id;
    private String title;
    private String artist;
    private Integer releaseYear;
    private Boolean explicit;
    private Integer duration;
    private List<GenreEntity> genres;
    private AudioFeaturesEntity features;
}
