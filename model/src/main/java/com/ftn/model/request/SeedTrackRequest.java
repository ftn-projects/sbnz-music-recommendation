package com.ftn.model.request;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class SeedTrackRequest {
    @EqualsAndHashCode.Include private UUID id;
    private UUID userId;
    private UUID seedTrackId;
    private Integer yearDeltaMax;
}