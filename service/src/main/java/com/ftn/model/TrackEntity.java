package com.ftn.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Entity
@Table(name = "tracks", indexes = {
        @Index(name = "idx_track_title", columnList = "title"),
        @Index(name = "idx_track_artist", columnList = "artist")
})
public class TrackEntity {
    @Id
    @EqualsAndHashCode.Include
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id = UUID.randomUUID();
    private String title;
    private String artist;
    private Integer releaseYear;
    private Boolean explicit;
    private Integer duration;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "track_genres", joinColumns = @JoinColumn(name = "track_id"))
    @Column(name = "genre_id")
    private Set<UUID> genreIds = new HashSet<>();

    @Embedded
    private AudioFeaturesEntity features;
}
