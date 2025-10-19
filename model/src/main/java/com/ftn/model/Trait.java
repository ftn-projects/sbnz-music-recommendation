package com.ftn.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.Set;
import java.util.UUID;

/**
 * Represents a characteristic/trait that groups genres.
 * Traits can have parent-child relationships for hierarchical inheritance.
 * Examples:
 * - "Physical Activity" (parent)
 *   ├─ "High Energy" (child)
 *   ├─ "Endurance" (child)
 *   └─ "Motivation" (child)
 */
@Data
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Trait {
    @EqualsAndHashCode.Include
    private UUID id;
    private String name;
    private UUID parentId;  // Parent trait for hierarchy
    private Set<UUID> genreIds; // Genres that have this trait
}
