-- sql
-- Test data for scoring rules (B1, B2, B4) + backwards chaining inputs (traits -> genres)
-- Load this into the DB used by the recommendation service tests.
-- Tables assumed: users, genres, traits, profiles, profile_traits, trait_genres,
--                 tracks, track_genres, user_genre_preferences, user_library_tracks, user_recent_tracks

-- CLEAN
DELETE FROM profile_traits;
DELETE FROM trait_genres;
DELETE FROM user_genre_preferences;
DELETE FROM user_library_tracks;
DELETE FROM user_recent_tracks;
DELETE FROM profiles;
DELETE FROM traits;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- =================================
-- GENRES
-- =================================
INSERT INTO genres (id, name) VALUES
('g-rock-000000000000000000000000000001', 'Rock'),
('g-pop-000000000000000000000000000002', 'Pop'),
('g-elect-000000000000000000000000000003', 'Electronic'),
('g-jazz-000000000000000000000004', 'Jazz'),
('g-metal-000000000000000000000000000005', 'Metal');

-- =================================
-- TRAITS (trait hierarchy to test profileBackwards recursion)
-- =================================
-- T1: Energetic (groups Rock, Pop)
-- T2: Dance (child of Energetic, groups Electronic)
INSERT INTO traits (id, name, parent_id) VALUES
('t-energetic-00000000000000000000000000001', 'Energetic', NULL),
('t-dance-000000000000000000000000000002', 'Dance', 't-energetic-00000000000000000000000000001');

-- Map traits -> genres
INSERT INTO trait_genres (trait_id, genre_id) VALUES
('t-energetic-00000000000000000000000000001', 'g-rock-000000000000000000000000000001'),
('t-energetic-00000000000000000000000000001', 'g-pop-000000000000000000000000000002'),
('t-dance-000000000000000000000000000002', 'g-elect-000000000000000000000000000003');

-- =================================
-- PROFILES
-- =================================
-- Profile P1 has trait Energetic -> aligned genres should include Rock, Pop (via backwards chaining)
-- Profile P2 has trait Dance -> should align Electronic (and via parent may also align Rock/Pop depending on recursion)
INSERT INTO profiles (id, name) VALUES
('p-profile1-00000000000000000000000000001', 'Profile Energetic'),
('p-profile2-00000000000000000000000000002', 'Profile Dance');

-- profile -> trait assignments (store trait ids in mapping table so Profile.getTraitIds() can be populated)
INSERT INTO profile_traits (profile_id, trait_id) VALUES
('p-profile1-00000000000000000000000000001', 't-energetic-00000000000000000000000000001'),
('p-profile2-00000000000000000000000000002', 't-dance-000000000000000000000000000002');

-- =================================
-- USERS
-- =================================
-- USER U1: has explicit genre preferences for Rock and Pop (will test B1)
-- USER U2: no preferences (B1 should not produce score)
-- USER U3: prefers Electronic (test profile P2 & backwards chaining)
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
('u-user1-00000000000000000000000000001', 'User Taste 1', 28, true, true, true),
('u-user2-00000000000000000000000000002', 'User NoPrefs', 30, true, true, true),
('u-user3-00000000000000000000000000003', 'User Elect Lover', 26, true, true, true);

-- user genre preferences (for B1)
INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
('u-user1-00000000000000000000000000001', 'g-rock-000000000000000000000000000001', 0.90), -- strong Rock
('u-user1-00000000000000000000000000001', 'g-pop-000000000000000000000000000002', 0.50),  -- moderate Pop
-- user2: no prefs -> no rows
('u-user3-00000000000000000000000000003', 'g-elect-000000000000000000000000000003', 0.70); -- loves Electronic

-- USER LIBRARIES / RECENT (included but scoring-focused tests do not use filters)
INSERT INTO user_library_tracks (user_id, track_id) VALUES
('u-user1-00000000000000000000000000001', 't-lib-exclude-0000000000000000000000001');

INSERT INTO user_recent_tracks (user_id, track_id) VALUES
('u-user1-00000000000000000000000000001', 't-recent-00000000000000000000000001');

-- =================================
-- TRACKS & TRACK GENRES (seed + candidates)
-- =================================
-- Seed track S1: Rock + Pop
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('s-seed1-00000000000000000000000000001', 'Seed - RockPop', 'Seed Artist', 2021, false, 200, 0.5, 0.6, 0.04, 0.1, 0.0, 0.1, 0.6);
INSERT INTO track_genres (track_id, genre_id) VALUES
('s-seed1-00000000000000000000000000001', 'g-rock-000000000000000000000000000001'),
('s-seed1-00000000000000000000000000001', 'g-pop-000000000000000000000000000002');

-- Candidate TR1: Rock + Pop (perfect match to profile & seed)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('t-tr1-00000000000000000000000000001', 'Track RockPop', 'Artist A', 2020, false, 210, 0.6, 0.7, 0.03, 0.2, 0.0, 0.1, 0.7);
INSERT INTO track_genres (track_id, genre_id) VALUES
('t-tr1-00000000000000000000000000001', 'g-rock-000000000000000000000000000001'),
('t-tr1-00000000000000000000000000001', 'g-pop-000000000000000000000000000002');

-- Candidate TR2: Rock only
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('t-tr2-00000000000000000000000000002', 'Track RockOnly', 'Artist B', 2019, false, 190, 0.5, 0.6, 0.03, 0.15, 0.0, 0.05, 0.6);
INSERT INTO track_genres (track_id, genre_id) VALUES
('t-tr2-00000000000000000000000000002', 'g-rock-000000000000000000000000000001');

-- Candidate TR3: Electronic only (will test user3 + profile2)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('t-tr3-00000000000000000000000000003', 'Track Electronic', 'Artist C', 2022, false, 180, 0.8, 0.9, 0.02, 0.05, 0.0, 0.02, 0.9);
INSERT INTO track_genres (track_id, genre_id) VALUES
('t-tr3-00000000000000000000000000003', 'g-elect-000000000000000000000000000003');

-- Candidate TR4: Jazz only (no prefs, no alignment -> score 0)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('t-tr4-00000000000000000000000000004', 'Track Jazz', 'Artist D', 2018, false, 230, 0.3, 0.2, 0.05, 0.6, 0.0, 0.2, 0.2);
INSERT INTO track_genres (track_id, genre_id) VALUES
('t-tr4-00000000000000000000000000004', 'g-jazz-000000000000000000000000000004');

-- Candidate TR5: Rock + Pop + Metal (mixed; tests accumulate picks best pref & partial profile match)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('t-tr5-00000000000000000000000000005', 'Track RockPopMetal', 'Artist E', 2020, false, 205, 0.55, 0.7, 0.04, 0.12, 0.0, 0.08, 0.65);
INSERT INTO track_genres (track_id, genre_id) VALUES
('t-tr5-00000000000000000000000000005', 'g-rock-000000000000000000000000000001'),
('t-tr5-00000000000000000000000000005', 'g-pop-000000000000000000000000000002'),
('t-tr5-00000000000000000000000000005', 'g-metal-000000000000000000000000000005');

-- =================================
-- NOTES / USAGE
-- =================================
-- 1) To test profile scoring:
--    - Call: recommendForProfile(userId, profileId)
--    - Examples:
--       a) recommendForProfile('u-user1-00000000000000000000000000001', 'p-profile1-00000000000000000000000000001')
--          -> Profile P1 aligned genres: Rock, Pop (via trait t-energetic)
--       b) recommendForProfile('u-user3-00000000000000000000000000003', 'p-profile2-00000000000000000000000000002')
--          -> Profile P2 aligned genres: Dance -> Electronic (plus parent Energetic depending on recursion)
--
-- 2) To test seed scoring:
--    - Call: recommendForTrack(userId, seedTrackId, yearDeltaMax)
--    - Example:
--       recommendForTrack('u-user1-00000000000000000000000000001', 's-seed1-00000000000000000000000000001', NULL)
--
-- =================================
-- EXPECTED AGGREGATED SCORES (sum of ScoreComponents per track; A1 rule sums components)
-- =================================
-- NOTE: ScoringSpecification weights:
--   - For profile requests specRules sets wUserTaste=1.0, wProfileGenre=1.0
--   - For seed requests specRules sets all weights = 1.0
--
-- Assumptions:
--   - Scoring.distance(...) used by B2 returns Jaccard distance:
--       distance = 1 - (|intersection| / |union|)
--   - B2 then does similarity = 1 - distance => similarity = |intersection| / |union|
--     scoreAdjustment = similarity * 2.0
--
-- Scenario A: Profile-based -> user = U1, profile = P1 (aligned genres = {Rock,Pop})
--   - t-tr1 (Rock+Pop):
--       B1 (Taste) -> best pref among genres = max(0.90,0.50) = 0.90
--       B2 (Profile genre) -> intersection=2, union=2 => similarity=1.0 => adj = 2.0
--       TOTAL expected = 0.90 + 2.0 = 2.90
--
--   - t-tr2 (Rock):
--       B1 -> 0.90
--       B2 -> intersection=1, union=2 => similarity=0.5 => adj = 1.0
--       TOTAL expected = 0.90 + 1.0 = 1.90
--
--   - t-tr5 (Rock,Pop,Metal):
--       B1 -> best pref = 0.90
--       B2 -> intersection=2, union=3 => similarity = 2/3 => adj = 1.333333...
--       TOTAL expected ≈ 0.90 + 1.333333 = 2.2333333
--
--   - t-tr3 (Electronic): no B1 (user1 has no Electronic pref), B2 -> no overlap -> adj = 0 => TOTAL = 0
--   - t-tr4 (Jazz): TOTAL = 0
--
-- Scenario B: Seed-based -> user = U1, seed = s-seed1 (genres {Rock,Pop})
--   - t-tr1 (Rock+Pop):
--       B4 (Seed genre) -> matches=2 denom=2 => similarity=1.0 => seed comp = 1.0
--       B1 -> 0.90
--       TOTAL expected = 1.0 + 0.90 = 1.90
--
--   - t-tr2 (Rock):
--       B4 -> matches=1 denom=1 => 1.0
--       B1 -> 0.90
--       TOTAL expected = 1.90
--
--   - t-tr5 (Rock,Pop,Metal):
--       B4 -> matches=2 denom=3 => 0.6666667
--       B1 -> 0.90
--       TOTAL expected ≈ 1.5666667
--
--   - t-tr3 (Electronic): B4 -> 0 (no matches), B1 -> 0 (user1 no pref) => TOTAL = 0
--
-- Scenario C: Profile-based -> user = U3, profile = P2 (should align Electronic via trait t-dance)
--   - t-tr3 (Electronic):
--       B1 -> 0.70 (user3 Electronic pref)
--       B2 -> if profile aligned includes Electronic: intersection=1 union=1 => similarity=1 => adj=2.0
--       TOTAL expected = 0.70 + 2.0 = 2.70
--
-- Use these calls and expected totals to assert ScoreComponent sums (A1 aggregation) and final TrackCandidate.score values.