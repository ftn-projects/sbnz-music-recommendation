package com.ftn.model.track;

import java.util.UUID;

import lombok.Data;

@Data
public class RecommendationProposal {
   private UUID userId;
   private UUID trackId;
   private Double score;
}
