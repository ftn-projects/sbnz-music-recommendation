package com.ftn.model.track;

import com.ftn.model.AudioFeatures;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.Set;
import java.util.UUID;

@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Track {
    @EqualsAndHashCode.Include private UUID id;
    private String title;
    private String artist;
    private Integer releaseYear;
    private Set<UUID> genreIds;
    private AudioFeatures features;
    private Boolean explicit;
    private Integer duration;
}
