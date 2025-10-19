package com.ftn.service;

import com.ftn.mapper.GenreMapper;
import com.ftn.mapper.ProfileMapper;
import com.ftn.mapper.TraitMapper;
import com.ftn.model.Genre;
import com.ftn.model.Profile;
import com.ftn.repository.GenreRepository;
import com.ftn.repository.TraitRepository;
import org.kie.api.runtime.KieSession;
import org.kie.api.runtime.rule.FactHandle;
import org.kie.api.runtime.rule.QueryResults;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service that uses backwards chaining to compute which genres align with a profile's traits.
 * This is done ON-DEMAND (not persisted) by querying the backwards chaining session.
 */
@Service
public class ProfileAlignmentService {
    private static final Logger LOG = LoggerFactory.getLogger(ProfileAlignmentService.class);

    private final KieSession backwardsSession;
    private final List<Genre> allGenres;

    public ProfileAlignmentService(
            GenreRepository genreRepository,
            TraitRepository traitRepository,
            GenreMapper genreMapper,
            TraitMapper traitMapper,
            KieSession backwardsKsession) {
        this.backwardsSession = backwardsKsession;

        // Cache all genres
        this.allGenres = genreRepository.findAll().stream()
                .map(genreMapper::toGenre)
                .collect(Collectors.toList());

        // Insert all traits into backwards session once at startup
        traitRepository.findAll().forEach(traitEntity ->
            backwardsSession.insert(traitMapper.toTrait(traitEntity))
        );

        LOG.info("ProfileAlignmentService initialized with {} genres", allGenres.size());
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

            // Check each genre to see if it aligns with this profile through traits
            for (Genre genre : allGenres) {
                QueryResults results = backwardsSession.getQueryResults("genreAlignsWithProfile", profile, genre);

                if (results.size() > 0) {
                    alignedGenres.add(genre.getId());
                    LOG.debug("Genre '{}' aligns with profile '{}' through traits",
                            genre.getName(), profile.getName());
                }
            }

            // Set aligned genres in the profile model (in-memory only)
            profile.setAlignedGenres(alignedGenres);
            LOG.debug("Profile '{}' aligned with {} genres", profile.getName(), alignedGenres.size());

        } finally {
            // Clean up: remove profile from session
            backwardsSession.delete(profileHandle);
        }
    }
}
