package com.ftn.service;

import com.ftn.model.Genre;
import com.ftn.model.Profile;
import org.kie.api.runtime.KieSession;
import org.kie.api.runtime.rule.FactHandle;
import org.kie.api.runtime.rule.QueryResults;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/**
 * Service that uses backwards chaining to compute which genres align with a profile's traits.
 * This is done ON-DEMAND (not persisted) by querying the backwards chaining session.
 */
@Service
public class ProfileAlignmentService {
    private static final Logger log = LoggerFactory.getLogger(ProfileAlignmentService.class);

    private final KieSession backwardsSession;

    public ProfileAlignmentService(KieSession backwardsKsession) {
        this.backwardsSession = backwardsKsession;
        log.info("ProfileAlignmentService initialized");
    }

    /**
     * Compute aligned genres for a profile ON-DEMAND using backwards chaining.
     * This populates profile.alignedGenres dynamically (not saved to DB).
     *
     * @param profile The profile to compute alignments for
     */
    public void computeAlignedGenres(Profile profile) {
        if (profile == null) return;

        // Insert profile into backwards session temporarily
        FactHandle profileHandle = backwardsSession.insert(profile);

        try {
            Set<UUID> alignedGenres = new HashSet<>();

            // Query all Genre facts from the session (already loaded by DroolsConfiguration)
            for (Object obj : backwardsSession.getObjects(fact -> fact instanceof Genre)) {
                Genre genre = (Genre) obj;

                QueryResults results = backwardsSession.getQueryResults("genreAlignsWithProfile", profile, genre);

                if (results.size() > 0) {
                    alignedGenres.add(genre.getId());
                    log.debug("Genre '{}' aligns with profile '{}' through traits",
                            genre.getName(), profile.getName());
                }
            }

            // Set aligned genres in the profile model (in-memory only)
            profile.setAlignedGenres(alignedGenres);
            log.debug("Profile '{}' aligned with {} genres", profile.getName(), alignedGenres.size());

        } finally {
            // Clean up: remove profile from session
            backwardsSession.delete(profileHandle);
        }
    }
}
