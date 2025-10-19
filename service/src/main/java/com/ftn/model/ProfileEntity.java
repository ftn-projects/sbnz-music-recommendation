package com.ftn.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Entity
@Table(name = "profiles")
public class ProfileEntity {
    @Id
    @EqualsAndHashCode.Include
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id = UUID.randomUUID();
    private String name;

    @Embedded
    private AudioFeaturesEntity targetFeatures;

    @ElementCollection
    @CollectionTable(name = "profile_traits", joinColumns = @JoinColumn(name = "profile_id"))
    @Column(name = "trait_id")
    private Set<UUID> traitIds = new HashSet<>();
}
