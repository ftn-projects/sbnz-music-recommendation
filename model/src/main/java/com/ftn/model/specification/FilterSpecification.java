package com.ftn.model.specification;

import java.util.List;
import java.util.UUID;

import lombok.Data;

@Data
public class FilterSpecification {
    private Boolean allowExplicit;
    private List<UUID> forbiddenTrackIds;
    private List<UUID> contextGenreIds;
    private Integer contextReleaseYear;
    private Integer yearDeltaMax;

    @Override
    public String toString() {
        return "FilterSpecification ["
            + "allowExplicit=" + allowExplicit
            + ", forbiddenTrackIds=" + forbiddenTrackIds
            + ", contextGenreIds=" + contextGenreIds
            + ", contextReleaseYear=" + contextReleaseYear
            + ", yearDeltaMax=" + yearDeltaMax
            + ']';
    }
}
