BEGIN;

-- =========================================================================================
-- DDL GUARD: minimal helper table for User.genrePreferences map
-- =========================================================================================
CREATE TABLE IF NOT EXISTS user_genre_preferences
(
    user_id    UUID             NOT NULL,
    genre_id   UUID             NOT NULL,
    preference DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (user_id, genre_id)
);

-- =========================================================================================
-- CLEANUP (FK-safe order)
-- =========================================================================================
DELETE
FROM user_genre_preferences;
DELETE
FROM users;
DELETE
FROM genres;

-- =========================================================================================
-- GENRES: Build a small but expressive hierarchy
-- IDs reused from your earlier seeds where possible; two extras added for sibling/deep tests.
-- =========================================================================================
-- Roots (parent_id = NULL): Electronic, Hip Hop, Rock, Jazz, Classical
INSERT INTO genres (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000007', 'Electronic', NULL),
       ('20000000-0000-0000-0000-000000000006', 'Hip Hop', NULL),
       ('20000000-0000-0000-0000-000000000008', 'Rock', NULL),
       ('20000000-0000-0000-0000-000000000002', 'Jazz', NULL),
       ('20000000-0000-0000-0000-000000000004', 'Classical', NULL);

-- Children of ELECTRONIC
INSERT INTO genres (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000012', 'House', '20000000-0000-0000-0000-000000000007'),
       ('20000000-0000-0000-0000-000000000010', 'Downtempo', '20000000-0000-0000-0000-000000000007'),
       ('20000000-0000-0000-0000-000000000003', 'Ambient', '20000000-0000-0000-0000-000000000007');

-- Grandchild of ELECTRONIC via AMBIENT (deep chain)
INSERT INTO genres (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000014', 'Ambient Drone', '20000000-0000-0000-0000-000000000003');

-- Children of HIP HOP (sibling test; Lo-Fi reused)
INSERT INTO genres (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000001', 'Lo-Fi', '20000000-0000-0000-0000-000000000006'),
       ('20000000-0000-0000-0000-000000000013', 'Boom Bap', '20000000-0000-0000-0000-000000000006');

-- Child of ROCK
INSERT INTO genres (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000009', 'Metal', '20000000-0000-0000-0000-000000000008');

-- =========================================================================================
-- USERS (one per scenario so results don’t interfere)
-- Columns match your earlier seeds
-- =========================================================================================
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent)
VALUES
    -- S1: Direct parent (ROCK) only
    ('11111111-1111-1111-1111-111111111001', 'S1 Direct Rock', 25, false, false, false),

    -- S2: Child like (LO-FI) → Upward to HIP HOP
    ('11111111-1111-1111-1111-111111111002', 'S2 Child Lo-Fi', 25, false, false, false),

    -- S3: Parent like (ELECTRONIC) → Downward to its descendants
    ('11111111-1111-1111-1111-111111111003', 'S3 Parent Electronic', 25, false, false, false),

    -- S4: Sibling via parent (like one HIP HOP child) – used with sibling test
    ('11111111-1111-1111-1111-111111111004', 'S4 Sibling via Parent', 25, false, false, false),

    -- S5a: Threshold == T (edge case: not strictly greater, should NOT count)
    ('11111111-1111-1111-1111-111111111005', 'S5a Threshold Equal', 25, false, false, false),

    -- S5b: Threshold just above (should count)
    ('11111111-1111-1111-1111-111111111006', 'S5b Threshold Above', 25, false, false, false),

    -- S6: Deep chain upward (like AMBIENT DRONE → AMBIENT → ELECTRONIC)
    ('11111111-1111-1111-1111-111111111007', 'S6 Deep Upward', 25, false, false, false),

    -- S7: Deep chain downward (like ELECTRONIC → AMBIENT → AMBIENT DRONE, HOUSE, DOWNTEMPO)
    ('11111111-1111-1111-1111-111111111008', 'S7 Deep Downward', 25, false, false, false),

    -- S8: No likes at all (control)
    ('11111111-1111-1111-1111-111111111009', 'S9 No Likes', 25, false, false, false);

-- =========================================================================================
-- USER GENRE PREFERENCES (preferences). Interpret with LIKENESS_THRESHOLD (e.g., 0.60)
-- =========================================================================================

-- S1: Direct Rock
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111001', '20000000-0000-0000-0000-000000000008', 0.90);
-- Rock

-- S2: Child Lo-Fi (expect ancestors via UP recursion)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111002', '20000000-0000-0000-0000-000000000001', 0.85);
-- Lo-Fi

-- S3: Parent Electronic (expect descendants via DOWN recursion)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111003', '20000000-0000-0000-0000-000000000007', 0.95);
-- Electronic

-- S4: Sibling via parent (like Lo-Fi; sibling is Boom Bap under same parent Hip Hop)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111004', '20000000-0000-0000-0000-000000000001', 0.90);
-- Lo-Fi

-- S5a: Threshold Equal (assume LIKENESS_THRESHOLD = 0.60 → direct should NOT count)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111005', '20000000-0000-0000-0000-000000000002', 0.60);
-- Jazz (edge)

-- S5b: Threshold Above (0.61 > 0.60 → should count)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111006', '20000000-0000-0000-0000-000000000002', 0.61);
-- Jazz

-- S6: Deep Upward (like deepest leaf → ancestors)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111007', '20000000-0000-0000-0000-000000000014', 0.88);
-- Ambient Drone

-- S7: Deep Downward (like root → all descendants)
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('11111111-1111-1111-1111-111111111008', '20000000-0000-0000-0000-000000000007', 0.88);
-- Electronic

-- S8: No likes (no rows)

COMMIT;
