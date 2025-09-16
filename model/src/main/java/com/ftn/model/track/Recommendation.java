package com.ftn.model.track;

import java.util.UUID;

import lombok.Data;

@Data
public class Recommendation {
    private UUID trackId;
    private Track track;
    private Integer rank;
    private Double score;
}
