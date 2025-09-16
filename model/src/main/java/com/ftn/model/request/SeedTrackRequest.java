package com.ftn.model.request;

import java.util.UUID;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class SeedTrackRequest {
    @EqualsAndHashCode.Include private UUID id;
    private String userId;
    private String seedTrackId;
    private Integer yearDeltaMax;
}