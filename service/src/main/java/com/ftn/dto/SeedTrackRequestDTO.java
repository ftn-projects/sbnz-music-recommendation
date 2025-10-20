package com.ftn.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class SeedTrackRequestDTO {
    public UUID userId;
    public UUID trackId;
    public Integer yearDeltaMax;
}
