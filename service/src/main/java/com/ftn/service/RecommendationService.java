package com.ftn.service;

import com.ftn.mapper.ProfileMapper;
import com.ftn.model.Profile;
import com.ftn.model.User;
import com.ftn.model.request.ProfileRequest;
import com.ftn.model.request.SeedTrackRequest;
import com.ftn.model.track.RecommendationProposal;
import com.ftn.model.track.TrackCandidate;
import com.ftn.mapper.UserMapper;
import com.ftn.mapper.TrackMapper;
import com.ftn.repository.ProfileRepository;
import com.ftn.repository.TrackRepository;
import com.ftn.repository.UserRepository;
import com.ftn.util.Page;
import org.kie.api.KieBase;
import org.kie.api.runtime.StatelessKieSession;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import jakarta.annotation.PreDestroy;
import com.ftn.util.DebugAgendaEventListener;
import com.ftn.util.DebugRuleRuntimeEventListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

@Service
public class RecommendationService {
    private static final Logger LOG = LoggerFactory.getLogger(RecommendationService.class);

    private final KieBase kieBase;
    private final ExecutorService pool;
    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;
    private final TrackRepository trackRepository;
    private final ProfileMapper profileMapper;
    private final UserMapper userMapper;
    private final TrackMapper trackMapper;

    @Value("${recommendation.batch-size}")
    private int batchSize;
    @Value("${recommendation.top-n}")
    private int topN;
    @Value("${recommendation.artist-cap}")
    private int artistCap;

    // Toggle to attach Drools agenda event listener (rule firing debug)
    @Value("${recommendation.debug-rules:false}")
    private boolean debugRules;

    public RecommendationService(
            @Value("${recommendation.thread-count}") int threadCount,
            @Qualifier("appRulesKieBase") KieBase kieBase,
            ProfileRepository profileRepository,
            UserRepository userRepository,
            TrackRepository trackRepository,
            ProfileMapper profileMapper,
            UserMapper userMapper,
            TrackMapper trackMapper) {

        this.kieBase = kieBase;
        this.profileRepository = profileRepository;
        this.userRepository = userRepository;
        this.trackRepository = trackRepository;
        this.profileMapper = profileMapper;
        this.userMapper = userMapper;
        this.trackMapper = trackMapper;
        this.pool = Executors.newFixedThreadPool(
                Math.max(1, threadCount),
                r -> {
                    var t = new Thread(r, "recommendation-worker");
                    t.setDaemon(true);
                    return t;
                }
        );
    }

    @PreDestroy
    public void shutdown() {
        if (pool != null && !pool.isShutdown()) {
            pool.shutdown();
        }
    }

    public List<UUID> recommendForProfile(UUID userId, UUID profileId) {
        LOG.info("Starting profile-based recommendation: user={}, profile={}", userId, profileId);
        // Load user and profile
        var user = userMapper.toUser(
                userRepository.findById(userId)
                        .orElseThrow(() -> new NoSuchElementException("User not found: " + userId))
        );

        var profile = profileMapper.toProfile(
                profileRepository.findById(profileId)
                        .orElseThrow(() -> new NoSuchElementException("Profile not found: " + profileId))
        );

        // Create ProfileRequest
        var profileRequest = new ProfileRequest(
                UUID.randomUUID(),
                userId,
                profileId
        );

        return runBatchRecommendation(user, profile, profileRequest, null);
    }

    public List<UUID> recommendForTrack(UUID userId, UUID seedTrackId, Integer yearDeltaMax) {
        LOG.info("Starting seed-track recommendation: user={}, seedTrack={}, yearDeltaMax={}", userId, seedTrackId, yearDeltaMax);
        // Load user
        var user = userMapper.toUser(
                userRepository.findById(userId)
                        .orElseThrow(() -> new NoSuchElementException("User not found: " + userId))
        );

        // Create SeedTrackRequest
        var seedRequest = new SeedTrackRequest(
                UUID.randomUUID(),
                userId,
                seedTrackId,
                yearDeltaMax
        );

        return runBatchRecommendation(user, null, null, seedRequest);
    }

    private List<UUID> runBatchRecommendation(
            User user,
            Profile profile,
            ProfileRequest profileRequest,
            SeedTrackRequest seedRequest) {

        var total = trackRepository.getTotal();
        var pages = planPages(total, batchSize);

        LOG.info("Planned recommendation run: totalTracks={}, batchSize={}, pages={}", total, batchSize, pages.size());

        var futures = pages.stream()
                .map(p -> CompletableFuture.supplyAsync(() -> processPage(user, profile, profileRequest, seedRequest, p), pool))
                .collect(Collectors.toList());

        // Combine all results from all batches
        var allScoredTracks = new ArrayList<TrackCandidate>();
        for (var future : futures) {
            var batchResults = future.join();
            // batchResults from processPage are TrackCandidate
            allScoredTracks.addAll(batchResults);
        }

        var result = allScoredTracks.stream()
                .sorted(Comparator.comparingDouble(TrackCandidate::getScore).reversed())
                .limit(topN)
                .map(TrackCandidate::getTrackId)
                .collect(Collectors.toList());

        LOG.info("Recommendation completed: returnedTopN={}, candidatesConsidered={}", result.size(), allScoredTracks.size());
        return result;
    }

    private List<TrackCandidate> processPage(
            com.ftn.model.User user,
            Profile profile,
            ProfileRequest profileRequest,
            SeedTrackRequest seedRequest,
            Page page) {

        LOG.debug("Processing page offset={}, limit={}", page.getOffset(), page.getLimit());

        var trackEntities = trackRepository.findAllPaginated(page.getOffset(), page.getLimit());
        if (trackEntities.isEmpty()) {
            LOG.debug("No tracks returned for page offset={}, limit={}", page.getOffset(), page.getLimit());
            return Collections.emptyList();
        }

        // Map entities to domain models
        var tracks = trackMapper.toTrackList(trackEntities);

        StatelessKieSession session = kieBase.newStatelessKieSession();

        // Attach debug event listener when requested - this will log each rule fired
        if (debugRules) {
            try {
                session.addEventListener(new DebugAgendaEventListener());
                LOG.info("Attached DebugAgendaEventListener for page offset={}, limit={}", page.getOffset(), page.getLimit());
                session.addEventListener(new DebugRuleRuntimeEventListener());
                LOG.info("Attached DebugRuleRuntimeEventListener for page offset={}, limit={}", page.getOffset(), page.getLimit());
            } catch (Exception e) {
                LOG.warn("Failed to attach DebugAgendaEventListener: {}", e.getMessage());
            }
        }

        // Build facts for Drools session
        var facts = new ArrayList<>();
        facts.add(user);

        // Add request and profile (if profile-based recommendation)
        if (profileRequest != null) {
            facts.add(profileRequest);
            if (profile != null) {
                facts.add(profile);
            }
        }

        // Add seed request (if seed-based recommendation)
        if (seedRequest != null) {
            facts.add(seedRequest);
        }

        // Create TrackCandidate for each track - these will be scored by Drools
        var trackCandidates = new ArrayList<TrackCandidate>();
        for (var track : tracks) {
            var candidate = new TrackCandidate(user.getId(), track.getId(), track.getArtist(), 0.0);
            trackCandidates.add(candidate);
            facts.add(track);
            facts.add(candidate);
        }

        try {
            session.execute(facts);
        } catch (Exception e) {
            LOG.error("Error executing Drools session for page offset={}, limit={}: {}", page.getOffset(), page.getLimit(), e.getMessage(), e);
        }

        long beforeFilter = trackCandidates.size();
        var filtered = trackCandidates.stream()
                .filter(candidate -> candidate.getScore() > 0)
                .collect(Collectors.toList());
        long afterFilter = filtered.size();
        LOG.debug("Page processed offset={}, limit={}, candidatesBefore={}, candidatesAfter={}", page.getOffset(), page.getLimit(), beforeFilter, afterFilter);

        // Return only the candidates that weren't filtered out and have scores
        return filtered;
    }

    private List<Page> planPages(long total, int batchSize) {
        List<Page> out = new ArrayList<>();
        if (total <= 0 || batchSize <= 0) return out;

        for (long off = 0; off < total; off += batchSize) {
            int lim = (int) Math.min(batchSize, total - off); // last page can be smaller
            out.add(new Page(off, lim));
        }
        return out;
    }
}
