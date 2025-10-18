package com.ftn.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public class ListenDTO {
    public UUID userId;
    public UUID trackId;
    public int duration;
}
