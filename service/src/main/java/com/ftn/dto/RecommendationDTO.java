package com.ftn.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@AllArgsConstructor
public class RecommendationDTO {
    private UUID trackId;
    private String title;
    private String artist;
    private Double score;
}
