package com.ftn.service.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class LikeDTO {
    public UUID userId;
    public UUID trackId;
}
