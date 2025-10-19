package com.ftn.model.track;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class TrackCandidate {
    @EqualsAndHashCode.Include private UUID userId;
    @EqualsAndHashCode.Include private UUID trackId;
    private String artist;
    private double score;
}
