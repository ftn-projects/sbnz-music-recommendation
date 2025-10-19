package com.ftn.service;

import com.ftn.mapper.GenreMapper;
import com.ftn.mapper.UserMapper;
import com.ftn.model.Genre;
import com.ftn.model.User;
import com.ftn.model.UserEntity;
import com.ftn.repository.GenreRepository;
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
import java.util.stream.Collectors;

/**
 * Syncs genre preferences from CEP events to database every 5 seconds.
 * Uses backwards chaining to infer genre affinities through the genre hierarchy.
 */
@Service
public class GenrePreferenceSyncService {
    private static final Logger LOG = LoggerFactory.getLogger(GenrePreferenceSyncService.class);
    private static final double LIKENESS_THRESHOLD = 0.5;
    private static final double INFERRED_AFFINITY_BOOST = 0.1;
    private static final double MIN_PREFERENCE = 0.0;
    private static final double MAX_PREFERENCE = 1.0;

    private final UserActivityService userActivityService;
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final KieSession backwardsSession;
    private final List<Genre> allGenres;

    public GenrePreferenceSyncService(
            UserActivityService userActivityService,
            UserRepository userRepository,
            GenreRepository genreRepository,
            UserMapper userMapper,
            GenreMapper genreMapper,
            KieSession backwardsKsession) {
        this.userActivityService = userActivityService;
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.backwardsSession = backwardsKsession;

        // Cache all genres once at startup
        this.allGenres = genreRepository.findAll().stream()
                .map(genreMapper::toGenre)
                .collect(Collectors.toList());

        LOG.info("GenrePreferenceSyncService initialized with {} genres for backwards chaining", allGenres.size());
    }

    @Scheduled(fixedDelay = 5000) // Every 5 seconds
    @Transactional
    public void syncGenrePreferences() {
        for (UUID userId : userActivityService.getUsersWithGenreUpdates()) {
            Map<UUID, Double> updates = userActivityService.consumeGenreUpdates(userId);
            if (updates == null || updates.isEmpty()) continue;

            LOG.info("Syncing {} genre preferences from CEP for user {}", updates.size(), userId);

            // Fetch user from database (assuming you have a User entity/model)
            var userOpt = userRepository.findById(userId);
            if (userOpt.isEmpty()) continue;

            var user = userOpt.get();
            Map<UUID, Double> prefs = user.getGenrePreferences();

            // Apply direct updates from CEP
            updates.forEach((genreId, delta) ->
                    prefs.merge(genreId, delta, (old, d) -> Math.max(MIN_PREFERENCE, Math.min(MAX_PREFERENCE, old + d)))
            );

            // Use backwards chaining to infer genre affinities through hierarchy
            computeInferredAffinities(user, updates.keySet());

            userRepository.save(user);
        }
    }

    /**
     * Uses backwards chaining to determine if user likes genres based on hierarchy.
     * Applies affinity boost to genres that the user likes through parent/child/sibling relationships.
     */
    private void computeInferredAffinities(UserEntity userEntity, Set<UUID> directlyAffectedGenres) {
        // Create a User model object for the backwards chaining session
        User user = userMapper.toUser(userEntity);

        // Insert user into backwards session temporarily
        FactHandle userHandle = backwardsSession.insert(user);

        try {
            // Check each genre to see if user likes it through the hierarchy
            for (Genre genre : allGenres) {
                // Skip genres that were directly affected by CEP events
                if (directlyAffectedGenres.contains(genre.getId())) {
                    continue;
                }

                // Query backwards: does user like this genre (directly or through hierarchy)?
                QueryResults results = backwardsSession.getQueryResults("userLikes", user, genre);

                if (results.size() > 0) {
                    // User likes this genre through the hierarchy - apply boost to the entity
                    UUID genreId = genre.getId();
                    Map<UUID, Double> prefs = userEntity.getGenrePreferences();
                    double currentPref = prefs.getOrDefault(genreId, 0.0);
                    double newPref = Math.max(MIN_PREFERENCE, Math.min(MAX_PREFERENCE, currentPref + INFERRED_AFFINITY_BOOST));

                    if (Math.abs(newPref - currentPref) > 0.01) {
                        prefs.put(genreId, newPref);
                        LOG.debug("Inferred affinity for genre '{}' ({}): {} -> {}",
                                genre.getName(), genreId, currentPref, newPref);
                    }
                }
            }
        } finally {
            // Clean up: remove user from session
            backwardsSession.delete(userHandle);
        }
    }
}
