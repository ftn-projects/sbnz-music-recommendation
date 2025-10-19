package com.ftn.model;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class ScoreComponent {
    @EqualsAndHashCode.Include private UUID userId;
    @EqualsAndHashCode.Include private UUID trackId;
    @EqualsAndHashCode.Include private Source source;
    private Double score;

    public enum Source {
        TASTE,
        PROFILE_GENRE,
        PROFILE_FEATURES,
        SEED_GENRE,
        SEED_FEATURES
    }
}
