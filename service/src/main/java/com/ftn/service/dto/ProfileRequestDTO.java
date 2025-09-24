package com.ftn.service.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class ProfileRequestDTO {
    public UUID userId;
    public UUID profileId;
}
