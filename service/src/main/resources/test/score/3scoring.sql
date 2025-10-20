-- scoring_rules_test_data.sql
-- Comprehensive test data for scoring rules (B1, B2, B3, B4, B5) and A1 aggregation.
-- Goal: enable manual testing of scoring WITHOUT interference from filtering.
-- IMPORTANT: Set user preferences so filters are neutral (allow explicit; include owned; include recent).
-- If your session still inserts Seed/Profile FilterSpecification rules and they interfere,
-- run rules with an AgendaFilter that excludes rule names starting with 'Filter ' during testing.

-- ======================================================
-- CLEANUP (order matters for FK constraints if you have them)
-- ======================================================
DELETE FROM profile_traits;
DELETE FROM trait_genres;
DELETE FROM user_genre_preferences;
DELETE FROM user_library_tracks;
-- Optional helper table (ignore if you don't have it)
-- DELETE FROM profile_target_features;
DELETE FROM profiles;
DELETE FROM traits;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- ======================================================
-- GENRES
-- ======================================================
INSERT INTO genres (id, name) VALUES
('9e99b769-b159-4661-8dd6-f86b9c6082a4', 'Rock'),
('42baf15d-aed4-4d7d-be7b-153ac16475dd',  'Pop'),
('838e9073-a909-41f0-b862-185aafadc922','Electronic'),
('9745f7e8-8a02-45e1-97bd-177f4ce8845e', 'Jazz'),
('c6f21f77-2d4a-49c4-98a5-43affe231166','Metal'),
('b2aea5f0-1890-4df3-93b5-ddacc01a8d04',  'Hip-Hop'),
('0f6f8834-1373-4b40-b32e-619fba151e68', 'Classical');

-- ======================================================
-- TRAITS & TRAIT->GENRE MAPPING (for profile genre alignment / backwards chaining)
-- Hierarchy:
--   Energetic -> Rock, Pop
--   Dance (child of Energetic) -> Electronic
--   Chill -> Jazz, Classical
-- ======================================================
INSERT INTO traits (id, name, parent_id) VALUES
('fbb9acbb-add2-462c-b560-bea2b9aba5db', 'Energetic', NULL),
('70f6b5a8-1a6c-4916-9c7b-38de31cf5ee0',     'Dance',     'fbb9acbb-add2-462c-b560-bea2b9aba5db'),
('e7b0fdca-5304-47fb-be82-c2ae4ddee883',     'Chill',     NULL);

INSERT INTO trait_genres (trait_id, genre_id) VALUES
('fbb9acbb-add2-462c-b560-bea2b9aba5db', '9e99b769-b159-4661-8dd6-f86b9c6082a4'),
('fbb9acbb-add2-462c-b560-bea2b9aba5db', '42baf15d-aed4-4d7d-be7b-153ac16475dd'),
('70f6b5a8-1a6c-4916-9c7b-38de31cf5ee0',    '838e9073-a909-41f0-b862-185aafadc922'),
('e7b0fdca-5304-47fb-be82-c2ae4ddee883',    '9745f7e8-8a02-45e1-97bd-177f4ce8845e'),
('e7b0fdca-5304-47fb-be82-c2ae4ddee883',    '0f6f8834-1373-4b40-b32e-619fba151e68');

-- ======================================================
-- PROFILES (+ trait assignments)
-- For B2 (genre alignment) and B3 (profile feature similarity)
-- If you store target features in a separate table, uncomment that section.
-- Otherwise, adapt to your schema.
-- ======================================================
INSERT INTO profiles (id, name) VALUES
('e863b1cf-53d7-4b4b-b2da-ba0177dfc82a', 'Profile Energetic'),
('94865de9-163d-4391-accf-0e7270afed9e', 'Profile Dance'),
('0a501e8b-6e9f-4599-9d1b-397bb136f74b', 'Profile Chill');

INSERT INTO profile_traits (profile_id, trait_id) VALUES
('e863b1cf-53d7-4b4b-b2da-ba0177dfc82a', 'fbb9acbb-add2-462c-b560-bea2b9aba5db'),
('94865de9-163d-4391-accf-0e7270afed9e', '70f6b5a8-1a6c-4916-9c7b-38de31cf5ee0'),
('0a501e8b-6e9f-4599-9d1b-397bb136f74b', 'e7b0fdca-5304-47fb-be82-c2ae4ddee883');

-- OPTIONAL: If you have a profile_target_features table (profile_id, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
-- Uncomment if exists; otherwise ignore this block.
-- INSERT INTO profile_target_features (profile_id, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
-- ('e863b1cf-53d7-4b4b-b2da-ba0177dfc82a', 0.65, 0.75, 0.05, 0.15, 0.00, 0.10, 0.70),
-- ('94865de9-163d-4391-accf-0e7270afed9e', 0.85, 0.85, 0.05, 0.10, 0.00, 0.10, 0.80),
-- ('0a501e8b-6e9f-4599-9d1b-397bb136f74b', 0.30, 0.30, 0.04, 0.60, 0.00, 0.10, 0.30);

-- ======================================================
-- USERS (preferences set to NEUTRALIZE filters: allow explicit; include owned/recent)
-- U1: Rock/Pop lover
-- U2: No prefs
-- U3: Electronic
-- U4: Jazz/Classical
-- U5: Mixed light Pop/Hip-Hop
-- ======================================================
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
('6e1abf3b-b2b6-46d2-899f-657bff5cf327', 'User RockPop', 28, true, true, true),
('52868850-cde4-461e-91bd-e6b2649081de', 'User NoPrefs', 30, true, true, true),
('406c74d3-5f4a-4839-9b93-c82173cb6c35', 'User Electronic', 26, true, true, true),
('185d2e39-c0d3-432a-aac5-12a0ce795351', 'User Chill', 34, true, true, true),
('016b3ffd-231a-430a-be04-39bbf3b79877', 'User Mixed', 23, true, true, true);

INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
('6e1abf3b-b2b6-46d2-899f-657bff5cf327', '9e99b769-b159-4661-8dd6-f86b9c6082a4', 0.90),
('6e1abf3b-b2b6-46d2-899f-657bff5cf327', '42baf15d-aed4-4d7d-be7b-153ac16475dd',  0.50),
('406c74d3-5f4a-4839-9b93-c82173cb6c35', '838e9073-a909-41f0-b862-185aafadc922',0.70),
('185d2e39-c0d3-432a-aac5-12a0ce795351', '9745f7e8-8a02-45e1-97bd-177f4ce8845e', 0.80),
('185d2e39-c0d3-432a-aac5-12a0ce795351', '0f6f8834-1373-4b40-b32e-619fba151e68', 0.60),
('016b3ffd-231a-430a-be04-39bbf3b79877', '42baf15d-aed4-4d7d-be7b-153ac16475dd',  0.40),
('016b3ffd-231a-430a-be04-39bbf3b79877', 'b2aea5f0-1890-4df3-93b5-ddacc01a8d04',  0.45);

-- ======================================================
-- TRACKS (include audio features used by b3/b5) + GENRE MAPPING
-- All explicit = false to avoid the explicit filter even if accidentally enabled.
-- ======================================================

-- Seed S1: Rock + Pop (for B4/B5 with U1)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence)
VALUES ('a230ad26-e58d-4313-9d9c-346eacacf9dd', 'Seed RockPop', 'Seed A', 2021, false, 200,
        0.60, 0.70, 0.04, 0.10, 0.00, 0.10, 0.65);
INSERT INTO track_genres (track_id, genre_id) VALUES
('a230ad26-e58d-4313-9d9c-346eacacf9dd', '9e99b769-b159-4661-8dd6-f86b9c6082a4'),
('a230ad26-e58d-4313-9d9c-346eacacf9dd', '42baf15d-aed4-4d7d-be7b-153ac16475dd');

-- Seed S2: Electronic (for B4/B5 with U3)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('f6a68f1f-8e95-457a-8f9b-38f842b3bc1f', 'Seed Electronic', 'Seed B', 2022, false, 190,
        0.85, 0.90, 0.03, 0.05, 0.00, 0.05, 0.85);
INSERT INTO track_genres (track_id, genre_id) VALUES
('f6a68f1f-8e95-457a-8f9b-38f842b3bc1f', '838e9073-a909-41f0-b862-185aafadc922');

-- Seed S3: Chill Jazz (for B4/B5 with U4)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('083ec8bb-0e41-4e7d-89c0-39d0c81f5fd7', 'Seed Chill Jazz', 'Seed C', 2018, false, 230,
        0.30, 0.25, 0.04, 0.60, 0.00, 0.10, 0.30);
INSERT INTO track_genres (track_id, genre_id) VALUES
('083ec8bb-0e41-4e7d-89c0-39d0c81f5fd7', '9745f7e8-8a02-45e1-97bd-177f4ce8845e');

-- ---------- Candidates focused on U1 (Rock/Pop) ----------
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('100ee75d-87d7-4fb9-879e-e80738e730a7', 'U1 Track Rock+Pop', 'A1', 2020, false, 210,
        0.62, 0.72, 0.03, 0.12, 0.00, 0.10, 0.70);
INSERT INTO track_genres (track_id, genre_id) VALUES
('100ee75d-87d7-4fb9-879e-e80738e730a7', '9e99b769-b159-4661-8dd6-f86b9c6082a4'),
('100ee75d-87d7-4fb9-879e-e80738e730a7', '42baf15d-aed4-4d7d-be7b-153ac16475dd');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('8315a9a4-881a-4e90-b498-6b46d7987ee0', 'U1 Track RockOnly', 'A2', 2019, false, 190,
        0.55, 0.65, 0.03, 0.15, 0.00, 0.08, 0.60);
INSERT INTO track_genres (track_id, genre_id) VALUES
('8315a9a4-881a-4e90-b498-6b46d7987ee0', '9e99b769-b159-4661-8dd6-f86b9c6082a4');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('b6626350-017c-4d5e-acde-7a4f32c5c46f', 'U1 Track RockPopMetal', 'A3', 2020, false, 205,
        0.58, 0.70, 0.04, 0.12, 0.00, 0.08, 0.65);
INSERT INTO track_genres (track_id, genre_id) VALUES
('b6626350-017c-4d5e-acde-7a4f32c5c46f', '9e99b769-b159-4661-8dd6-f86b9c6082a4'),
('b6626350-017c-4d5e-acde-7a4f32c5c46f', '42baf15d-aed4-4d7d-be7b-153ac16475dd'),
('b6626350-017c-4d5e-acde-7a4f32c5c46f', 'c6f21f77-2d4a-49c4-98a5-43affe231166');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('4cccc436-b1c0-4425-843e-f5e67f36e2f8', 'U1 Track Electronic', 'A4', 2022, false, 180,
        0.80, 0.88, 0.02, 0.05, 0.00, 0.02, 0.88);
INSERT INTO track_genres (track_id, genre_id) VALUES
('4cccc436-b1c0-4425-843e-f5e67f36e2f8', '838e9073-a909-41f0-b862-185aafadc922');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('39279a24-b3e2-4fe3-afbe-b912ae00213d', 'U1 Track Jazz', 'A5', 2018, false, 230,
        0.30, 0.20, 0.05, 0.60, 0.00, 0.20, 0.20);
INSERT INTO track_genres (track_id, genre_id) VALUES
('39279a24-b3e2-4fe3-afbe-b912ae00213d', '9745f7e8-8a02-45e1-97bd-177f4ce8845e');

-- ---------- Candidates focused on U3 (Electronic) ----------
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('589d7917-cad8-4fd4-aaa1-d8f5a8377c54', 'U3 Electronic Perfect', 'C1', 2023, false, 182,
        0.86, 0.91, 0.03, 0.05, 0.00, 0.05, 0.88);
INSERT INTO track_genres (track_id, genre_id) VALUES
('589d7917-cad8-4fd4-aaa1-d8f5a8377c54', '838e9073-a909-41f0-b862-185aafadc922');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('2337680c-d2ca-43a8-b931-494d8f18aaee', 'U3 ElectroPop', 'C2', 2021, false, 188,
        0.80, 0.85, 0.03, 0.08, 0.00, 0.10, 0.80);
INSERT INTO track_genres (track_id, genre_id) VALUES
('2337680c-d2ca-43a8-b931-494d8f18aaee', '838e9073-a909-41f0-b862-185aafadc922'),
('2337680c-d2ca-43a8-b931-494d8f18aaee', '42baf15d-aed4-4d7d-be7b-153ac16475dd');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('b36e2def-23e2-4ee8-b226-916259c13c6f', 'U3 Rock (mismatch)', 'C3', 2020, false, 200,
        0.55, 0.60, 0.04, 0.15, 0.00, 0.10, 0.55);
INSERT INTO track_genres (track_id, genre_id) VALUES
('b36e2def-23e2-4ee8-b226-916259c13c6f', '9e99b769-b159-4661-8dd6-f86b9c6082a4');

-- ---------- Candidates focused on U4 (Chill) ----------
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('a7bac5e4-9a5d-4a74-bbac-41db1780d6cd', 'U4 Jazz Ballad', 'D1', 2017, false, 235,
        0.28, 0.22, 0.04, 0.62, 0.00, 0.10, 0.28);
INSERT INTO track_genres (track_id, genre_id) VALUES
('a7bac5e4-9a5d-4a74-bbac-41db1780d6cd', '9745f7e8-8a02-45e1-97bd-177f4ce8845e');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('e6bd710f-afed-4e8c-b428-38248aa903ab', 'U4 Classical Piece', 'D2', 2015, false, 260,
        0.20, 0.15, 0.03, 0.70, 0.00, 0.08, 0.20);
INSERT INTO track_genres (track_id, genre_id) VALUES
('e6bd710f-afed-4e8c-b428-38248aa903ab', '0f6f8834-1373-4b40-b32e-619fba151e68');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('4d0dcab6-f649-46d2-bdb8-53e3a645af17', 'U4 Jazz+Class', 'D3', 2019, false, 240,
        0.25, 0.25, 0.04, 0.65, 0.00, 0.08, 0.25);
INSERT INTO track_genres (track_id, genre_id) VALUES
('4d0dcab6-f649-46d2-bdb8-53e3a645af17', '9745f7e8-8a02-45e1-97bd-177f4ce8845e'),
('4d0dcab6-f649-46d2-bdb8-53e3a645af17', '0f6f8834-1373-4b40-b32e-619fba151e68');

-- ---------- General/Mixed extra candidates ----------
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('ec777d55-3340-459e-9317-924e65cddb2c', 'Hip Hop Banger', 'E1', 2021, false, 185,
        0.75, 0.65, 0.10, 0.20, 0.00, 0.12, 0.60);
INSERT INTO track_genres (track_id, genre_id) VALUES
('ec777d55-3340-459e-9317-924e65cddb2c', 'b2aea5f0-1890-4df3-93b5-ddacc01a8d04');

INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('c7ad185d-3085-46fc-8c5a-24c94a42bf20', 'Crossover Rocktronica', 'E2', 2020, false, 195,
        0.70, 0.80, 0.04, 0.10, 0.00, 0.10, 0.75);
INSERT INTO track_genres (track_id, genre_id) VALUES
('c7ad185d-3085-46fc-8c5a-24c94a42bf20', '9e99b769-b159-4661-8dd6-f86b9c6082a4'),
('c7ad185d-3085-46fc-8c5a-24c94a42bf20', '838e9073-a909-41f0-b862-185aafadc922');

-- ======================================================
-- SUGGESTED MANUAL TESTS (scoring only; filters neutralized)
-- Conventions used below (you can adapt to your exact rule math):
--   B1 (User Affinity): score = SUM(user_pref[g]) for g ∈ (track_genres ∩ user_prefs)
--   B2 (Profile↔Genre): score = 1.0 if track contains any genre implied by active profile, else 0.0
--   B3 (Profile Features): similarity ∈ [0,1] from (1 - mean absolute diff over features)
--   B4 (Seed Genre): Jaccard(track_genres, seed_genres) ∈ [0,1]
--   B5 (Seed Features): similarity ∈ [0,1] from (1 - mean absolute diff over features)
--   A1 (Aggregation): final = Σ (w_i * B_i), using ScoringSpecification(w1..w5)
--
-- NOTE: All tracks here have explicit=false and we're ignoring library/recent filters.
-- ======================================================

-- ------------------------------------------------------
-- T1: B1 ONLY (User Genre Affinity) for U1 (Rock/Pop)
-- Endpoint: /score/1 already hardcodes ScoringSpecification(1.0,0.0,0.0,0.0,0.0)
-- Facts: user=U1, candidates = [A1..A5 below]
-- User U1 prefs: Rock=0.90, Pop=0.50
-- Candidates:
--   A1 'U1 Track Rock+Pop'      100ee75d-87d7-4fb9-879e-e80738e730a7  genres={Rock,Pop}
--   A2 'U1 Track RockOnly'       8315a9a4-881a-4e90-b498-6b46d7987ee0  genres={Rock}
--   A3 'U1 Track RockPopMetal'   b6626350-017c-4d5e-acde-7a4f32c5c46f  genres={Rock,Pop,Metal}
--   A4 'U1 Track Electronic'     4cccc436-b1c0-4425-843e-f5e67f36e2f8  genres={Electronic}
--   A5 'U1 Track Jazz'           39279a24-b3e2-4fe3-afbe-b912ae00213d  genres={Jazz}
--
-- Expected B1 scores (SUM over matched prefs):
--   A1: 0.90 + 0.50 = 1.40
--   A2: 0.90
--   A3: 0.90 + 0.50 = 1.40       -- Metal not in prefs; ignored
--   A4: 0.00
--   A5: 0.00
-- Expected ranking (desc): A1≈A3 (tie on 1.40), then A2 (0.90), then A4=A5 (0.00)
-- If your engine breaks ties deterministically, expect [A3,A1,A2,A4,A5] or [A1,A3,A2,A4,A5].

-- HOW TO TRIGGER:
-- POST /score/1 (as implemented)
-- Expect TrackCandidate scores to reflect B1 above.

-- ------------------------------------------------------
-- T2: B4 ONLY (Seed↔Genre similarity) for U1 with Seed S1
-- Use same 5 candidates as T1, but set ScoringSpecification(0.0,0.0,0.0,1.0,0.0).
-- Seed S1 'Seed RockPop' a230ad26-e58d-4313-9d9c-346eacacf9dd  genres={Rock,Pop}
-- B4 = Jaccard(track_genres, {Rock,Pop})
--   A1 {Rock,Pop}           → 2/2   = 1.00
--   A2 {Rock}               → 1/2   = 0.50
--   A3 {Rock,Pop,Metal}     → 2/3   ≈ 0.6667
--   A4 {Electronic}         → 0/3?  = 0.00       -- union {Rock,Pop,Electronic} but intersection=0
--   A5 {Jazz}               → 0/3?  = 0.00
-- Expected ranking: A1 (1.00), A3 (~0.667), A2 (0.50), A4=A5 (0.00)

-- ------------------------------------------------------
-- T3: B5 ONLY (Seed↔Feature similarity) for U1 with Seed S1
-- ScoringSpecification(0.0,0.0,0.0,0.0,1.0).
-- Seed S1 features: d=0.60,e=0.70,s=0.04,a=0.10,i=0.00,l=0.10,v=0.65
-- Similarity = 1 - mean(|x_track - x_seed|)
--   A1 (0.62,0.72,0.03,0.12,0.00,0.10,0.70):
--       diffs sum=0.12 → mean≈0.0171 → B5≈0.9829
--   A2 (0.55,0.65,0.03,0.15,0.00,0.08,0.60):
--       sum=0.23 → mean≈0.0329 → B5≈0.9671
--   A3 (0.58,0.70,0.04,0.12,0.00,0.08,0.65):
--       sum=0.06 → mean≈0.0086 → B5≈0.9914
--   A4 (0.80,0.88,0.02,0.05,0.00,0.02,0.88):
--       sum=0.76 → mean≈0.1086 → B5≈0.8914
--   A5 (0.30,0.20,0.05,0.60,0.00,0.20,0.20):
--       sum=1.86 → mean≈0.2657 → B5≈0.7343
-- Expected ranking: A3 (≈0.991), A1 (≈0.983), A2 (≈0.967), A4 (≈0.891), A5 (≈0.734)

-- ------------------------------------------------------
-- T4: A1 AGGREGATION of B4+B5 for U1 with Seed S1
-- ScoringSpecification(0.0,0.0,0.0,0.5,0.5)  -- equal weight genres vs features
-- Use B4 from T2 and B5 from T3:
--   A1: 0.5*1.0000 + 0.5*0.9829 ≈ 0.9915
--   A2: 0.5*0.5000 + 0.5*0.9671 ≈ 0.7336
--   A3: 0.5*0.6667 + 0.5*0.9914 ≈ 0.8291
--   A4: 0.5*0.0000 + 0.5*0.8914 ≈ 0.4457
--   A5: 0.5*0.0000 + 0.5*0.7343 ≈ 0.3671
-- Expected ranking: A1 (≈0.992) > A3 (≈0.829) > A2 (≈0.734) > A4 (≈0.446) > A5 (≈0.367)

-- ------------------------------------------------------
-- T5: B1 ONLY for U3 (Electronic fan)
-- ScoringSpecification(1.0,0.0,0.0,0.0,0.0)
-- User U3 prefs: Electronic=0.70
-- Candidates (Electronic focus):
--   C1 'U3 Electronic Perfect'  589d7917-cad8-4fd4-aaa1-d8f5a8377c54  {Electronic}
--   C2 'U3 ElectroPop'          2337680c-d2ca-43a8-b931-494d8f18aaee  {Electronic,Pop}
--   C3 'U3 Rock (mismatch)'     b36e2def-23e2-4ee8-b226-916259c13c6f  {Rock}
-- B1:
--   C1: 0.70
--   C2: 0.70       -- Pop not in prefs
--   C3: 0.00
-- Expected: C1≈C2 (0.70), then C3 (0.00). Tie-breaker per engine.

-- ------------------------------------------------------
-- T6: B4 ONLY for U3 with Seed S2 (Electronic)
-- ScoringSpecification(0.0,0.0,0.0,1.0,0.0)
-- Seed S2 'Seed Electronic' f6a68f1f-8e95-457a-8f9b-38f842b3bc1f genres={Electronic}
-- B4 Jaccard w/ {Electronic}:
--   C1 {Electronic}         → 1/1 = 1.00
--   C2 {Electronic,Pop}     → 1/2 = 0.50
--   C3 {Rock}               → 0/2 = 0.00
-- Expected: C1 > C2 > C3

-- ------------------------------------------------------
-- T7: B5 ONLY for U3 with Seed S2 (Electronic)
-- ScoringSpecification(0.0,0.0,0.0,0.0,1.0)
-- Seed S2 features: d=0.85,e=0.90,s=0.03,a=0.05,i=0.00,l=0.05,v=0.85
--   C1 (0.86,0.91,0.03,0.05,0.00,0.05,0.88):
--       diffs sum=0.05 → mean≈0.0071 → B5≈0.9929
--   C2 (0.80,0.85,0.03,0.08,0.00,0.10,0.80):
--       sum=0.20 → mean≈0.0286 → B5≈0.9714
--   C3 (0.55,0.60,0.04,0.15,0.00,0.10,0.55):
--       sum=0.95 → mean≈0.1357 → B5≈0.8643
-- Expected: C1 > C2 > C3

-- ------------------------------------------------------
-- T8: A1 AGGREGATION for U3 with Seed S2 (balanced B4+B5)
-- ScoringSpecification(0.0,0.0,0.0,0.5,0.5)
--   C1: 0.5*1.0000 + 0.5*0.9929 ≈ 0.9965
--   C2: 0.5*0.5000 + 0.5*0.9714 ≈ 0.7357
--   C3: 0.5*0.0000 + 0.5*0.8643 ≈ 0.4321
-- Expected: C1 > C2 > C3

-- ------------------------------------------------------
-- T9: B2 ONLY (Profile↔Genre) using Profile 'Dance' (implies Electronic)
-- ScoringSpecification(0.0,1.0,0.0,0.0,0.0)
-- Active profile: 'Profile Dance' 94865de9-163d-4391-accf-0e7270afed9e
-- Trait→Genre implies Electronic via 'Dance'
-- Candidates: reuse A1..A5 (U1 set) or C1..C3 (U3 set)
-- Expect any track with {Electronic} to get 1.0, others 0.0:
--   Electronic tracks: A4, C1, C2, E2 (if included) → 1.0
--   Non-electronic     → 0.0

-- ------------------------------------------------------
-- T10: B3 ONLY (Profile Feature Similarity) for Profile 'Chill'
-- ScoringSpecification(0.0,0.0,1.0,0.0,0.0)
-- If you have profile_target_features (commented section), use:
--   'Profile Chill' 0a501e8b-6e9f-4599-9d1b-397bb136f74b targets:
--      d=0.30, e=0.30, s=0.04, a=0.60, i=0.00, l=0.10, v=0.30
-- Candidates (U4-set):
--   D1 'U4 Jazz Ballad'       a7bac5e4-9a5d-4a74-bbac-41db1780d6cd  (0.28,0.22,0.04,0.62,0,0.10,0.28)
--   D2 'U4 Classical Piece'   e6bd710f-afed-4e8c-b428-38248aa903ab  (0.20,0.15,0.03,0.70,0,0.08,0.20)
--   D3 'U4 Jazz+Class'        4d0dcab6-f649-46d2-bdb8-53e3a645af17  (0.25,0.25,0.04,0.65,0,0.08,0.25)
-- Compute B3=1-mean(|track - target|):
--   D1 diffs sum≈0.09 → mean≈0.0129 → B3≈0.9871 (closest)
--   D2 sum≈0.29 → mean≈0.0414 → B3≈0.9586
--   D3 sum≈0.17 → mean≈0.0243 → B3≈0.9757
-- Expected: D1 > D3 > D2

-- ------------------------------------------------------
-- T11: FULL A1 for U4 with Seed S3 (Chill Jazz), balanced B4+B5 and light B1
-- ScoringSpecification(0.2,0.0,0.0,0.4,0.4)
-- User U4 prefs: Jazz=0.80, Classical=0.60
-- Seed S3 'Seed Chill Jazz' 083ec8bb-0e41-4e7d-89c0-39d0c81f5fd7 genres={Jazz}
-- Candidates: D1 (Jazz), D2 (Classical), D3 (Jazz,Classical)
-- B1:
--   D1: 0.80       D2: 0.60       D3: 0.80+0.60=1.40
-- B4 (Jaccard w/ {Jazz}):
--   D1: 1.00       D2: 0.00       D3: 1/2=0.50
-- B5 (features vs S3: 0.30,0.25,0.04,0.60,0,0.10,0.30)
--   D1 (0.28,0.22,0.04,0.62,0,0.10,0.28): sum=0.06 → mean≈0.0086 → 0.9914
--   D2 (0.20,0.15,0.03,0.70,0,0.08,0.20): sum=0.29 → mean≈0.0414 → 0.9586
--   D3 (0.25,0.25,0.04,0.65,0,0.08,0.25): sum=0.17 → mean≈0.0243 → 0.9757
-- A1 = 0.2*B1 + 0.4*B4 + 0.4*B5:
--   D1: 0.2*0.80 + 0.4*1.00 + 0.4*0.9914 ≈ 0.9586
--   D2: 0.2*0.60 + 0.4*0.00 + 0.4*0.9586 ≈ 0.6234
--   D3: 0.2*1.40 + 0.4*0.50 + 0.4*0.9757 ≈ 0.879
-- Expected: D1 (≈0.959) > D3 (≈0.879) > D2 (≈0.623)

-- ------------------------------------------------------
-- T12: Sanity for Mixed set (shows cross-signal ranking)
-- ScoringSpecification(0.3,0.0,0.0,0.35,0.35), U1 + Seed S1
-- Add "E2 Crossover Rocktronica" c7ad185d-3085-46fc-8c5a-24c94a42bf20 genres={Rock,Electronic}
-- B1(U1): Rock=0.90 → E2=0.90
-- B4 vs {Rock,Pop}: Jaccard({Rock,Electronic},{Rock,Pop})=1/3≈0.3333
-- B5 vs S1 (0.70,0.80,0.04,0.10,0,0.10,0.75): diffs sum=0.22 → mean≈0.0314 → 0.9686
-- A1=0.3*0.90 + 0.35*0.3333 + 0.35*0.9686 ≈ 0.696
-- Expect E2 to slot between A2 and A3 in T4 depending on your tie-breakers.