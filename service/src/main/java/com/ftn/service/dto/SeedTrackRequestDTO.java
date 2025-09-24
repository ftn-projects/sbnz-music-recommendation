package com.ftn.service.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class SeedTrackRequestDTO {
    public UUID userId;
    public UUID seedTrackId;
    public Integer yearDeltaMax;
}
