package com.ftn.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/**
 * Represents a characteristic/trait that groups genres.
 * Traits can have parent-child relationships for hierarchical inheritance.
 */
@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Entity
@Table(name = "traits")
public class TraitEntity {
    @Id
    @EqualsAndHashCode.Include
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id = UUID.randomUUID();

    private String name;

    @Column(name = "parent_id")
    private UUID parentId;  // Parent trait for hierarchy

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "trait_genres", joinColumns = @JoinColumn(name = "trait_id"))
    @Column(name = "genre_id")
    private Set<UUID> genreIds = new HashSet<>();
}
