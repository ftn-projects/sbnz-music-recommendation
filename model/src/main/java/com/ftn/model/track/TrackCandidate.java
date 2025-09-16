package com.ftn.model.track;

import java.util.UUID;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class TrackCandidate {
    @EqualsAndHashCode.Include private UUID userId;
    @EqualsAndHashCode.Include private UUID trackId;
}
