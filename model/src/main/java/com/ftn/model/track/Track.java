package com.ftn.model.track;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;
import java.util.UUID;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Track {
    @EqualsAndHashCode.Include private UUID id;
    private String title;
    private String artistId;
    private Integer releaseYear;
    private List<String> genreIds;
    private Features features;

    @Data
    public class Features {
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
