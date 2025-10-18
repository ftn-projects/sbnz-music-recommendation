package com.ftn.model.track;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class RecommendationProposal {
   @EqualsAndHashCode.Include private UUID userId;
   @EqualsAndHashCode.Include private UUID trackId;
   private double score;
}
