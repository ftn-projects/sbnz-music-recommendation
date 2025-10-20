package com.ftn.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
public class PreferenceDTO {
    private UUID userId;
    private String preference;
    private Boolean value;
}
