package com.ftn.model;

import java.util.Set;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Profile {
    @EqualsAndHashCode.Include private UUID id;
    private String name;
    private AudioFeatures targetFeatures;
    private Set<UUID> traitIds; // Traits this profile has (e.g., Energy, Motivation)
    private Set<UUID> alignedGenres; // Computed via backwards chaining - genres that align with profile's traits
}
