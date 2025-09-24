package com.ftn.service.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class ListenDTO {
    public UUID userId;
    public UUID trackId;
    public int duration;
}
