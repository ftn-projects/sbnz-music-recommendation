package com.ftn.model.track;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;
import java.util.UUID;

@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Track {
    @EqualsAndHashCode.Include private UUID id;
    private String title;
    private String artist;
    private Integer releaseYear;
    private List<UUID> genreIds;
    private Features features;
    private Boolean explicit;

    @Data
    @AllArgsConstructor
    public static class Features {
        private Double danceability;
        private Double energy;
        private Double loudness;
        private Double speechiness;
        private Double acousticness;
        private Double instrumentalness;
        private Double liveness;
        private Double valence;

        @Override
        public String toString() {
            return "Track.Features ["
                + "danceability=" + danceability
                + ", energy=" + energy
                + ", loudness=" + loudness
                + ", speechiness=" + speechiness
                + ", acousticness=" + acousticness
                + ", instrumentalness=" + instrumentalness
                + ", liveness=" + liveness
                + ", valence=" + valence + ']';
        }
    }
}
