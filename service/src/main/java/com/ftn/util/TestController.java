package com.ftn.util;

import com.ftn.mapper.ProfileMapper;
import com.ftn.mapper.TrackMapper;
import com.ftn.mapper.UserMapper;
import com.ftn.model.Genre;
import com.ftn.model.TrackEntity;
import com.ftn.model.User;
import com.ftn.model.specification.ScoringSpecification;
import com.ftn.model.track.Track;
import com.ftn.model.track.TrackCandidate;
import com.ftn.repository.ProfileRepository;
import com.ftn.repository.TrackRepository;
import com.ftn.repository.UserRepository;
import com.ftn.service.ProfileAlignmentService;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.kie.api.KieBase;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;
import org.kie.api.runtime.rule.QueryResults;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/test")
public class TestController {
    private final ProfileAlignmentService profileAlignmentService;
    private final ProfileRepository profileRepository;
    private final ProfileMapper profileMapper;
    private final KieSession backwardsKsession;
    private final KieBase kieBase;
    private final TrackRepository trackRepository;
    private final TrackMapper trackMapper;
    private final UserRepository userRepository;
    private final UserMapper userMapper;

    public TestController(
            ProfileAlignmentService profileAlignmentService,
            ProfileRepository profileRepository,
            ProfileMapper profileMapper,
            KieSession backwardsKsession,
            KieBase kieBase,
            TrackRepository trackRepository,
            TrackMapper trackMapper,
            UserRepository userRepository,
            UserMapper userMapper) {
        this.profileAlignmentService = profileAlignmentService;
        this.profileRepository = profileRepository;
        this.profileMapper = profileMapper;
        this.backwardsKsession = backwardsKsession;
        this.kieBase = kieBase;
        this.trackRepository = trackRepository;
        this.trackMapper = trackMapper;
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }

    @GetMapping("/profile-alignment/{profileId}")
    public ResponseEntity<?> testProfileAlignment(@PathVariable UUID profileId) {
        var profileEntity = profileRepository.findById(profileId);
        if (profileEntity.isPresent()) {
            var profile = profileMapper.toProfile(profileEntity.get());
            profileAlignmentService.computeAlignedGenres(profile);
            return ResponseEntity.ok(profile.getAlignedGenres());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/genre-preference/{userId}/{genreId}")
    public ResponseEntity<?> testGenrePreference(@PathVariable UUID userId, @PathVariable UUID genreId) {
        var direct = new ArrayList<String>();
        var parent = new ArrayList<String>();
        var child = new ArrayList<String>();
        var sibling = new ArrayList<String>();

        var userEntity = userRepository.findById(userId);
        if (userEntity.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        var user = userMapper.toUser(userEntity.get());
        for (Object obj : backwardsKsession.getObjects(fact -> fact instanceof Genre)) {
            Genre genre = (Genre) obj;
            UUID gId = genre.getId();

            // Check if user likes this genre through hierarchy
            if (queryMatch("userLikesDirectly", user, genre))
                direct.add(genre.getName());
            if (queryMatch("userLikesUp", user, genre))
                parent.add(genre.getName());
            if (queryMatch("userLikesDown", user, genre))
                child.add(genre.getName());
            if (queryMatch("userLikesViaParent", user, genre))
                sibling.add(genre.getName());
        }
        return ResponseEntity.ok(new GenrePreferenceResponse(direct, parent, child, sibling));
    }

    private boolean queryMatch(String queryName, User user, Genre genre) {
        QueryResults results = backwardsKsession.getQueryResults(queryName, user, genre);
        return results != null && results.size() > 0;
    }

    @Getter
    @Setter
    @AllArgsConstructor
    public static final class GenrePreferenceResponse {
        private List<String> direct;
        private List<String> parent;
        private List<String> child;
        private List<String> sibling;
    }

    // ---------- helper: run a scoring session with optional seed ----------
    private ResponseEntity<?> runScoring(
            UUID userId,
            List<UUID> candidateTrackIds,
            ScoringSpecification spec,
            UUID optionalSeedTrackId // can be null
    ) {
        var userEntity = userRepository.findById(userId).orElseThrow();
        var trackEntities = trackRepository.findAllById(candidateTrackIds);
        var user = userMapper.toUser(userEntity);
        var tracks = trackMapper.toTrackList(trackEntities);

        var facts = new ArrayList<>();
        facts.add(user);
        facts.add(spec);

        // If seed is supplied, add it to the fact set.
        if (optionalSeedTrackId != null) {
            var seedEntity = trackRepository.findById(optionalSeedTrackId).orElseThrow();
            var seed = trackMapper.toTrackList(List.of(seedEntity)).get(0);
            facts.add(seed);
            // If your DRL expects SeedTrackRequest, include it; otherwise, comment this out.
            // facts.add(new SeedTrackRequest(UUID.randomUUID(), user.getId(), seed.getId(), /*yearDelta*/ null));
        }

        // Build candidates
        var trackCandidates = new ArrayList<TrackCandidate>();
        for (var track : tracks) {
            var candidate = new TrackCandidate(user.getId(), track.getId(), track.getArtist(), 0.0);
            trackCandidates.add(candidate);
            facts.add(track);
            facts.add(candidate);
        }

        var session = kieBase.newStatelessKieSession();
        session.addEventListener(new DebugAgendaEventListener());
        session.addEventListener(new DebugRuleRuntimeEventListener());

        try {
            session.execute(facts);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error during Drools execution: " + e.getMessage());
        }
        return ResponseEntity.ok(trackCandidates);
    }

    // ---------------------------------------------------------------------
    // T1: B1 ONLY for U1 (same idea as your /score/1, leaving yours intact)
    // ---------------------------------------------------------------------
    @PostMapping("/score/1")
    public ResponseEntity<?> t1_b1_u1() {
        var userId = UUID.fromString("6e1abf3b-b2b6-46d2-899f-657bff5cf327"); // U1
        var candidates = List.of(
                UUID.fromString("100ee75d-87d7-4fb9-879e-e80738e730a7"), // A1 Rock+Pop
                UUID.fromString("8315a9a4-881a-4e90-b498-6b46d7987ee0"), // A2 Rock
                UUID.fromString("b6626350-017c-4d5e-acde-7a4f32c5c46f"), // A3 Rock+Pop+Metal
                UUID.fromString("4cccc436-b1c0-4425-843e-f5e67f36e2f8"), // A4 Electronic
                UUID.fromString("39279a24-b3e2-4fe3-afbe-b912ae00213d")  // A5 Jazz
        );
        var spec = new ScoringSpecification(1.0, 0.0, 0.0, 0.0, 0.0); // B1 only
        return runScoring(userId, candidates, spec, null);
    }

    // ---------------------------------------------------------------------
    // T2: B4 ONLY (Seed↔Genre) for U1 with Seed S1
    // ---------------------------------------------------------------------
    @PostMapping("/score/2")
    public ResponseEntity<?> t2_b4_u1() {
        var userId = UUID.fromString("6e1abf3b-b2b6-46d2-899f-657bff5cf327"); // U1
        var seedId = UUID.fromString("a230ad26-e58d-4313-9d9c-346eacacf9dd"); // S1 Rock+Pop
        var candidates = List.of(
                UUID.fromString("100ee75d-87d7-4fb9-879e-e80738e730a7"),
                UUID.fromString("8315a9a4-881a-4e90-b498-6b46d7987ee0"),
                UUID.fromString("b6626350-017c-4d5e-acde-7a4f32c5c46f"),
                UUID.fromString("4cccc436-b1c0-4425-843e-f5e67f36e2f8"),
                UUID.fromString("39279a24-b3e2-4fe3-afbe-b912ae00213d")
        );
        var spec = new ScoringSpecification(0.0, 0.0, 0.0, 1.0, 0.0); // B4 only
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T3: B5 ONLY (Seed↔Features) for U1 with Seed S1
    // ---------------------------------------------------------------------
    @PostMapping("/score/3")
    public ResponseEntity<?> t3_b5_u1() {
        var userId = UUID.fromString("6e1abf3b-b2b6-46d2-899f-657bff5cf327"); // U1
        var seedId = UUID.fromString("a230ad26-e58d-4313-9d9c-346eacacf9dd"); // S1
        var candidates = List.of(
                UUID.fromString("100ee75d-87d7-4fb9-879e-e80738e730a7"),
                UUID.fromString("8315a9a4-881a-4e90-b498-6b46d7987ee0"),
                UUID.fromString("b6626350-017c-4d5e-acde-7a4f32c5c46f"),
                UUID.fromString("4cccc436-b1c0-4425-843e-f5e67f36e2f8"),
                UUID.fromString("39279a24-b3e2-4fe3-afbe-b912ae00213d")
        );
        var spec = new ScoringSpecification(0.0, 0.0, 0.0, 0.0, 1.0); // B5 only
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T4: A1 aggregation (B4+B5, 50/50) for U1 with Seed S1
    // ---------------------------------------------------------------------
    @PostMapping("/score/4")
    public ResponseEntity<?> t4_agg_u1() {
        var userId = UUID.fromString("6e1abf3b-b2b6-46d2-899f-657bff5cf327"); // U1
        var seedId = UUID.fromString("a230ad26-e58d-4313-9d9c-346eacacf9dd"); // S1
        var candidates = List.of(
                UUID.fromString("100ee75d-87d7-4fb9-879e-e80738e730a7"),
                UUID.fromString("8315a9a4-881a-4e90-b498-6b46d7987ee0"),
                UUID.fromString("b6626350-017c-4d5e-acde-7a4f32c5c46f"),
                UUID.fromString("4cccc436-b1c0-4425-843e-f5e67f36e2f8"),
                UUID.fromString("39279a24-b3e2-4fe3-afbe-b912ae00213d")
        );
        var spec = new ScoringSpecification(0.0, 0.0, 0.0, 0.5, 0.5); // B4 50%, B5 50%
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T5: B1 ONLY for U3 (Electronic fan)
    // ---------------------------------------------------------------------
    @PostMapping("/score/5")
    public ResponseEntity<?> t5_b1_u3() {
        var userId = UUID.fromString("406c74d3-5f4a-4839-9b93-c82173cb6c35"); // U3
        var candidates = List.of(
                UUID.fromString("589d7917-cad8-4fd4-aaa1-d8f5a8377c54"), // C1 Electronic
                UUID.fromString("2337680c-d2ca-43a8-b931-494d8f18aaee"), // C2 ElectroPop
                UUID.fromString("b36e2def-23e2-4ee8-b226-916259c13c6f")  // C3 Rock mismatch
        );
        var spec = new ScoringSpecification(1.0, 0.0, 0.0, 0.0, 0.0); // B1 only
        return runScoring(userId, candidates, spec, null);
    }

    // ---------------------------------------------------------------------
    // T6: B4 ONLY for U3 with Seed S2 (Electronic)
    // ---------------------------------------------------------------------
    @PostMapping("/score/6")
    public ResponseEntity<?> t6_b4_u3() {
        var userId = UUID.fromString("406c74d3-5f4a-4839-9b93-c82173cb6c35"); // U3
        var seedId = UUID.fromString("f6a68f1f-8e95-457a-8f9b-38f842b3bc1f"); // S2 Electronic
        var candidates = List.of(
                UUID.fromString("589d7917-cad8-4fd4-aaa1-d8f5a8377c54"),
                UUID.fromString("2337680c-d2ca-43a8-b931-494d8f18aaee"),
                UUID.fromString("b36e2def-23e2-4ee8-b226-916259c13c6f")
        );
        var spec = new ScoringSpecification(0.0, 0.0, 0.0, 1.0, 0.0); // B4 only
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T7: B5 ONLY for U3 with Seed S2 (Electronic)
    // ---------------------------------------------------------------------
    @PostMapping("/score/7")
    public ResponseEntity<?> t7_b5_u3() {
        var userId = UUID.fromString("406c74d3-5f4a-4839-9b93-c82173cb6c35"); // U3
        var seedId = UUID.fromString("f6a68f1f-8e95-457a-8f9b-38f842b3bc1f"); // S2
        var candidates = List.of(
                UUID.fromString("589d7917-cad8-4fd4-aaa1-d8f5a8377c54"),
                UUID.fromString("2337680c-d2ca-43a8-b931-494d8f18aaee"),
                UUID.fromString("b36e2def-23e2-4ee8-b226-916259c13c6f")
        );
        var spec = new ScoringSpecification(0.0, 0.0, 0.0, 0.0, 1.0); // B5 only
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T8: A1 aggregation for U3 with Seed S2 (B4+B5 balanced)
    // ---------------------------------------------------------------------
    @PostMapping("/score/8")
    public ResponseEntity<?> t8_agg_u3() {
        var userId = UUID.fromString("406c74d3-5f4a-4839-9b93-c82173cb6c35"); // U3
        var seedId = UUID.fromString("f6a68f1f-8e95-457a-8f9b-38f842b3bc1f"); // S2
        var candidates = List.of(
                UUID.fromString("589d7917-cad8-4fd4-aaa1-d8f5a8377c54"),
                UUID.fromString("2337680c-d2ca-43a8-b931-494d8f18aaee"),
                UUID.fromString("b36e2def-23e2-4ee8-b226-916259c13c6f")
        );
        var spec = new ScoringSpecification(0.0, 0.0, 0.0, 0.5, 0.5); // B4 50%, B5 50%
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T11: Full aggregation for U4 with Seed S3 (Chill/Jazz)
    //      weights: B1=0.2, B4=0.4, B5=0.4
    // ---------------------------------------------------------------------
    @PostMapping("/score/9")
    public ResponseEntity<?> t11_agg_u4() {
        var userId = UUID.fromString("185d2e39-c0d3-432a-aac5-12a0ce795351"); // U4
        var seedId = UUID.fromString("083ec8bb-0e41-4e7d-89c0-39d0c81f5fd7"); // S3 Chill Jazz
        var candidates = List.of(
                UUID.fromString("a7bac5e4-9a5d-4a74-bbac-41db1780d6cd"), // D1 Jazz
                UUID.fromString("e6bd710f-afed-4e8c-b428-38248aa903ab"), // D2 Classical
                UUID.fromString("4d0dcab6-f649-46d2-bdb8-53e3a645af17")  // D3 Jazz+Class
        );
        var spec = new ScoringSpecification(0.2, 0.0, 0.0, 0.4, 0.4);
        return runScoring(userId, candidates, spec, seedId);
    }

    // ---------------------------------------------------------------------
    // T12: Mixed cross-signal test (U1 + Seed S1) including E2 Rocktronica
    //      weights: B1=0.3, B4=0.35, B5=0.35
    // ---------------------------------------------------------------------
    @PostMapping("/score/10")
    public ResponseEntity<?> t12_mixed_u1() {
        var userId = UUID.fromString("6e1abf3b-b2b6-46d2-899f-657bff5cf327"); // U1
        var seedId = UUID.fromString("a230ad26-e58d-4313-9d9c-346eacacf9dd"); // S1
        var candidates = List.of(
                UUID.fromString("100ee75d-87d7-4fb9-879e-e80738e730a7"),
                UUID.fromString("8315a9a4-881a-4e90-b498-6b46d7987ee0"),
                UUID.fromString("b6626350-017c-4d5e-acde-7a4f32c5c46f"),
                UUID.fromString("4cccc436-b1c0-4425-843e-f5e67f36e2f8"),
                UUID.fromString("39279a24-b3e2-4fe3-afbe-b912ae00213d"),
                UUID.fromString("c7ad185d-3085-46fc-8c5a-24c94a42bf20")  // E2 Rock+Electronic
        );
        var spec = new ScoringSpecification(0.3, 0.0, 0.0, 0.35, 0.35);
        return runScoring(userId, candidates, spec, seedId);
    }
}
