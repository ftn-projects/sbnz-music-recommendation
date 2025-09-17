package com.ftn.model.specification;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ScoringSpecification {
    private Double wUserTaste;
    private Double wProfileGenre;
    private Double wProfileFeatures;
    private Double wSeedGenre;
    private Double wSeedFeatures;

    @Override
    public String toString() {
        return "ScoringSpecification ["
            + "wUserTaste=" + wUserTaste
            + ", wProfileGenre=" + wProfileGenre
            + ", wProfileFeatures=" + wProfileFeatures
            + ", wSeedGenre=" + wSeedGenre
            + ", wSeedFeatures=" + wSeedFeatures + ']';
    }
}
