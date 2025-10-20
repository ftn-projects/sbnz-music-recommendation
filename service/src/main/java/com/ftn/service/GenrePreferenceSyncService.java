package com.ftn.service;

import com.ftn.mapper.UserMapper;
import com.ftn.model.Genre;
import com.ftn.model.User;
import com.ftn.model.UserEntity;
import com.ftn.repository.UserRepository;
import org.kie.api.runtime.KieSession;
import org.kie.api.runtime.rule.FactHandle;
import org.kie.api.runtime.rule.QueryResults;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Syncs genre preferences from CEP events to database every 5 seconds.
 * Uses backwards chaining to infer genre affinities through the genre hierarchy.
 */
@Service
public class GenrePreferenceSyncService {
    private static final Logger log = LoggerFactory.getLogger(GenrePreferenceSyncService.class);
    private static final double LIKENESS_THRESHOLD = 0.6;

    private final UserActivityService userActivityService;
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final KieSession backwardsSession;

    public GenrePreferenceSyncService(
            UserActivityService userActivityService,
            UserRepository userRepository,
            UserMapper userMapper,
            KieSession backwardsKsession) {
        this.userActivityService = userActivityService;
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.backwardsSession = backwardsKsession;

        this.backwardsSession.setGlobal("LIKENESS_THRESHOLD", LIKENESS_THRESHOLD);
        log.info("GenrePreferenceSyncService initialized (syncing every 5 seconds)");
    }

    /**
     * Scheduled task that syncs genre preferences from CEP events to the database.
     * Runs every 5 seconds. For each user with pending updates:
     * 1. Applies direct preference changes from CEP events
     * 2. Computes inferred preferences via backwards chaining (genre hierarchy)
     * 3. Persists all changes to the database
     */
    @Scheduled(fixedDelay = 5000) // Every 5 seconds
    @Transactional
    public void syncGenrePreferences() {
        for (UUID userId : userActivityService.getUsersWithGenreUpdates()) {
            Map<UUID, Double> updates = userActivityService.consumeGenreUpdates(userId);
            if (updates == null || updates.isEmpty()) continue;

            log.info("Syncing {} genre preferences from CEP for user {}", updates.size(), userId);

            // Fetch user from database (assuming you have a User entity/model)
            var userOpt = userRepository.findById(userId);
            if (userOpt.isEmpty()) continue;

            var user = userOpt.get();

            // Use backwards chaining to infer genre affinities through hierarchy
            computeInferredPreferences(user, updates);

            userRepository.save(user);
        }
    }

    /**
     * Uses backwards chaining queries to infer genre preferences through the genre hierarchy.
     * For genres not directly affected by CEP events, applies a boost if the user likes them
     * through parent/child/sibling relationships (userLikesUp, userLikesDown, userLikesViaParent).
     *
     * @param userEntity             The user entity to update (modified in-place)
     * @param directlyAffectedGenres Genre IDs that were directly updated by CEP (excluded from boost)
     */
    private void computeInferredPreferences(UserEntity userEntity, Map<UUID, Double> directlyAffectedGenres) {
        // Create a User model object for the backwards chaining session
        User user = userMapper.toUser(userEntity);

        // Insert user into backwards session temporarily
        FactHandle userHandle = backwardsSession.insert(user);

        try {
            Map<UUID, Double> prefs = userEntity.getGenrePreferences();
            Map<UUID, Double> changedPrefs = new HashMap<>(prefs);

            for (var entry : directlyAffectedGenres.entrySet()) {
                UUID genreId = entry.getKey();
                double delta = entry.getValue();

                double currentPref = prefs.getOrDefault(genreId, 0.5);
                double newPref = Math.max(0.0, Math.min(1.0, currentPref + delta));
                prefs.put(genreId, newPref);
                changedPrefs.put(genreId, newPref);
                log.debug("Updated directly affected genre '{}' ({}): {}", genreId, genreId, newPref);
            }

            user.setGenrePreferences(changedPrefs);

            // Query all Genre facts from the session (already loaded by DroolsConfiguration)
            for (Object obj : backwardsSession.getObjects(fact -> fact instanceof Genre)) {
                Genre genre = (Genre) obj;
                UUID genreId = genre.getId();

                if (directlyAffectedGenres.containsKey(genreId)) {
                    continue;
                }

                // Check if user likes this genre through hierarchy
                boolean like =
                        queryMatch("userLikesUp", user, genre)
                                || queryMatch("userLikesDown", user, genre)
                                || queryMatch("userLikesViaParent", user, genre);

                if (like) {
                    double currentPref = prefs.getOrDefault(genreId, 0.0);
                    double newPref = Math.max(0.0, Math.min(1.0, currentPref + 0.8 * directlyAffectedGenres.get(genreId)));
                    prefs.put(genreId, newPref);
                    log.debug("Inferred affinity for genre '{}' ({}): {} -> {}", genre.getName(), genreId, currentPref, newPref);
                }
            }

            userEntity.setGenrePreferences(prefs);
        } finally {
            // Clean up: remove user from session
            backwardsSession.delete(userHandle);
        }
    }

    private boolean queryMatch(String queryName, User user, Genre genre) {
        QueryResults results = backwardsSession.getQueryResults(queryName, user, genre);
        return results != null && results.size() > 0;
    }
}
