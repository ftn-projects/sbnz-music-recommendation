package com.ftn.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Entity
@Table(name = "tracks")
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
    private Features features;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Embeddable
    public static class Features {
        private Double danceability;
        private Double energy;
        private Double speechiness;
        private Double acousticness;
        private Double instrumentalness;
        private Double liveness;
        private Double valence;
    }
}
