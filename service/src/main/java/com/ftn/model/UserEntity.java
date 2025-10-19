package com.ftn.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.*;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@NoArgsConstructor
@Entity
@Table(name = "users")
public class UserEntity {
    @Id
    @EqualsAndHashCode.Include
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id = UUID.randomUUID();

    private String name;
    private Integer age;

    @ElementCollection
    @CollectionTable(
            name = "user_library_tracks",
            joinColumns = @JoinColumn(name = "user_id")
    )
    @Column(name = "track_id")
    private Set<UUID> libraryTrackIds;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(
            name = "user_genre_preferences",
            joinColumns = @JoinColumn(name = "user_id"),
            uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "genre_id"})
    )
    @MapKeyColumn(name = "genre_id")
    @Column(name = "preference")
    private Map<UUID, Double> genrePreferences;

    @Embedded
    private Preferences preferences;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Embeddable
    public static class Preferences {
        private Boolean explicitContent;
        private Boolean includeOwned;
        private Boolean includeRecent;
    }

    public UserEntity(String name, Integer age, Preferences preferences) {
        this.name = name;
        this.age = age;
        this.genrePreferences = new HashMap<>();
        this.libraryTrackIds = new HashSet<>();
        this.preferences = preferences;
    }
}
