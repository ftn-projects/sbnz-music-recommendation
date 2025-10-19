package com.ftn.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public final class AudioFeatures {
    private Double danceability;
    private Double energy;
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
                + ", speechiness=" + speechiness
                + ", acousticness=" + acousticness
                + ", instrumentalness=" + instrumentalness
                + ", liveness=" + liveness
                + ", valence=" + valence + ']';
    }
}
