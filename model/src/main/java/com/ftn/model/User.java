package com.ftn.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.Map;
import java.util.UUID;

@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @EqualsAndHashCode.Include private UUID id;
    private String name;
    private Integer age;
    private Map<UUID, Double> genrePreferences;
    private Preferences preferences;

    @Data
    public class Preferences {
        private Boolean explicitContent;
        private Boolean excludeOwned;
        private Boolean excludeRecent;

        @Override
        public String toString() {
            return "User.Preferences [" + "explicitContent=" + explicitContent + ", excludeOwned=" + excludeOwned + ", excludeRecent=" + excludeRecent + ']';
        }
    }
}
