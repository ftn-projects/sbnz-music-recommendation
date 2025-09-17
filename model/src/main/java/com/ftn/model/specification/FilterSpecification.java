package com.ftn.model.specification;

import java.util.List;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FilterSpecification {
    private Boolean allowExplicit;
    private List<UUID> forbiddenTrackIds;
    private List<UUID> contextGenreIds;
    private Integer contextReleaseYear;
    private Double contextGenreMaxDifference;
    private Integer yearDeltaMax;

    @Override
    public String toString() {
        return "FilterSpecification ["
            + "allowExplicit=" + allowExplicit
            + ", forbiddenTrackIds=" + forbiddenTrackIds
            + ", contextGenreIds=" + contextGenreIds
            + ", contextReleaseYear=" + contextReleaseYear
            + ", contextGenreMaxDifference=" + contextGenreMaxDifference
            + ", yearDeltaMax=" + yearDeltaMax
            + ']';
    }
}
