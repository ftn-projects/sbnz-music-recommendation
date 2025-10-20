-- ========================================
-- FILTER RULES TEST DATA
-- ========================================
-- This dataset is designed to test ALL filtering rules comprehensively
--
-- Test Scenarios Covered:
-- 1. Explicit Content Filter
-- 2. Genre Difference Filter (Jaccard distance)
-- 3. Forbidden Tracks Filter (library + recent)
--
-- ========================================

-- Clean up existing data
DELETE FROM profile_traits;
DELETE FROM profiles;
DELETE FROM user_genre_preferences;
DELETE FROM user_library_tracks;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- ========================================
-- TEST USERS
-- ========================================

-- User 1: "Clean Listener" - No explicit content allowed, excludes owned & recent
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
('11111111-1111-1111-1111-111111111111', 'Clean Listener', 25, false, false, false);

-- User 2: "Explicit Fan" - Allows explicit content, includes owned & recent
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
('22222222-2222-2222-2222-222222222222', 'Explicit Fan', 28, true, true, true);

-- User 3: "Library Keeper" - Allows explicit, excludes owned, includes recent
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
('33333333-3333-3333-3333-333333333333', 'Library Keeper', 30, true, false, true);

-- ========================================
-- TEST GENRES (for genre distance testing)
-- ========================================

INSERT INTO genres (id, name) VALUES
('10000000-0000-0000-0000-000000000001', 'Rock'),
('10000000-0000-0000-0000-000000000002', 'Pop'),
('10000000-0000-0000-0000-000000000003', 'Jazz'),
('10000000-0000-0000-0000-000000000004', 'Electronic'),
('10000000-0000-0000-0000-000000000005', 'Metal'),
('10000000-0000-0000-0000-000000000006', 'Hip Hop'),
('10000000-0000-0000-0000-000000000007', 'Classical');

-- ========================================
-- TEST TRACKS
-- ========================================

-- SEED TRACK: Rock + Pop (genres: Rock, Pop)
-- This will be used as seed for genre distance testing
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('20000000-0000-0000-0000-000000000000', 'SEED - Rock Pop Mix', 'Test Artist', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);

INSERT INTO track_genres (track_id, genre_id) VALUES
('20000000-0000-0000-0000-000000000000', '10000000-0000-0000-0000-000000000001'), -- Rock
('20000000-0000-0000-0000-000000000000', '10000000-0000-0000-0000-000000000002'); -- Pop

-- ========================================
-- EXPLICIT CONTENT TEST TRACKS
-- ========================================

-- Track 1: Clean track
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000001', 'Clean Song 1', 'Artist A', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001'); -- Rock

-- Track 2: Explicit track
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000002', 'Explicit Song 1', 'Artist B', 2020, true, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001'); -- Rock

-- Track 3: Another clean track
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000003', 'Clean Song 2', 'Artist C', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002'); -- Pop

-- Track 4: Another explicit track
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000004', 'Explicit Song 2', 'Artist D', 2020, true, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002'); -- Pop

-- ========================================
-- GENRE DISTANCE TEST TRACKS
-- ========================================
-- SEED has genres: [Rock, Pop]
-- Testing Jaccard distance threshold of 0.8

-- Track 10: EXACT MATCH - genres: [Rock, Pop]
-- Jaccard distance = 0.0 (perfect match) -> PASS (< 0.8)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000010', 'Exact Match Track', 'Artist E', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000001'), -- Rock
('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002'); -- Pop

-- Track 11: PARTIAL OVERLAP - genres: [Rock]
-- Jaccard distance = 1 - (1/2) = 0.5 -> PASS (< 0.8)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000011', 'Partial Overlap Track', 'Artist F', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001'); -- Rock only

-- Track 12: CLOSE MATCH - genres: [Rock, Pop, Metal]
-- Jaccard distance = 1 - (2/3) = 0.333 -> PASS (< 0.8)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000012', 'Close Match Track', 'Artist G', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001'), -- Rock
('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000002'), -- Pop
('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000005'); -- Metal

-- Track 13: BORDERLINE - genres: [Rock, Metal, Hip Hop, Jazz, Electronic]
-- Jaccard distance = 1 - (1/6) = 0.833 -> FILTERED (>= 0.8)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000013', 'Borderline Track', 'Artist H', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001'), -- Rock (overlap)
('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000005'), -- Metal
('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000006'), -- Hip Hop
('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000003'), -- Jazz
('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000004'); -- Electronic

-- Track 14: COMPLETELY DIFFERENT - genres: [Jazz, Classical]
-- Jaccard distance = 1 - (0/4) = 1.0 -> FILTERED (>= 0.8)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000014', 'Completely Different Track', 'Artist I', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000003'), -- Jazz
('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000007'); -- Classical

-- ========================================
-- FORBIDDEN TRACKS TEST
-- ========================================

-- Track 20: In User1's Library
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000020', 'In Library 1', 'Artist J', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000020', '10000000-0000-0000-0000-000000000001');

-- Track 21: In User1's Library
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000021', 'In Library 2', 'Artist K', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000001');

-- Track 22: Recently played by User1 (but not in library)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000022', 'Recently Played', 'Artist L', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000001');

-- Track 23: In User3's Library
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000023', 'In Library 3', 'Artist M', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000023', '10000000-0000-0000-0000-000000000001');

-- Track 24: NOT in any library/recent (should always pass)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000024', 'Free Track', 'Artist N', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000024', '10000000-0000-0000-0000-000000000001');

-- ========================================
-- COMBINED TEST TRACKS
-- ========================================

-- Track 30: Explicit + In Library (double filter test)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000030', 'Explicit & In Library', 'Artist O', 2020, true, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000030', '10000000-0000-0000-0000-000000000001');

-- Track 31: Clean + Not in library + Good genre match (should always pass)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('30000000-0000-0000-0000-000000000031', 'Perfect Track', 'Artist P', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
('30000000-0000-0000-0000-000000000031', '10000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000031', '10000000-0000-0000-0000-000000000002');

-- ========================================
-- USER LIBRARY SETUP
-- ========================================

-- User 1: Clean Listener - Library tracks
INSERT INTO user_library_tracks (user_id, track_id) VALUES
('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000020'),
('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000021'),
('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000030');

-- User 3: Library Keeper - Library tracks
INSERT INTO user_library_tracks (user_id, track_id) VALUES
('33333333-3333-3333-3333-333333333333', '30000000-0000-0000-0000-000000000023');

-- ========================================
-- USER GENRE PREFERENCES (for completeness)
-- ========================================
INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
('11111111-1111-1111-1111-111111111111', '10000000-0000-0000-0000-000000000001', 0.8), -- Rock
('22222222-2222-2222-2222-222222222222', '10000000-0000-0000-0000-000000000001', 0.8), -- Rock
('33333333-3333-3333-3333-333333333333', '10000000-0000-0000-0000-000000000001', 0.8); -- Rock

-- ========================================
-- TEST PROFILES
-- ========================================

-- Profile 1: "Energetic Rock Profile" - For profile-based recommendations
-- Target features: moderate-high energy, moderate danceability, low acousticness
INSERT INTO profiles (id, name, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
('40000000-0000-0000-0000-000000000001', 'Energetic Rock Profile', 0.6, 0.7, 0.05, 0.2, 0.1, 0.15, 0.6);

-- Profile traits (optional - can be empty if not needed for filter tests)
-- INSERT INTO profile_traits (profile_id, trait_id) VALUES
-- ('40000000-0000-0000-0000-000000000001', 'some-trait-id-here');

-- ========================================
-- TEST SCENARIOS SUMMARY
-- ========================================

/*
===========================================
TEST SCENARIO 1: EXPLICIT CONTENT FILTER
===========================================

Input: User 1 (Clean Listener) - Profile-based recommendation
- User setting: explicit_content = false
- Available tracks: t001, t002, t003, t004

Expected Output:
✅ PASS: t001 (Clean Song 1) - clean
✅ PASS: t003 (Clean Song 2) - clean
❌ FILTERED: t002 (Explicit Song 1) - explicit
❌ FILTERED: t004 (Explicit Song 2) - explicit

Input: User 2 (Explicit Fan) - Profile-based recommendation
- User setting: explicit_content = true
- Available tracks: t001, t002, t003, t004

Expected Output:
✅ PASS: All tracks (t001, t002, t003, t004) - explicit allowed

===========================================
TEST SCENARIO 2: GENRE DISTANCE FILTER
===========================================

Input: Any User - Seed track recommendation with SEED track (genres: Rock, Pop)
- contextGenreMaxDifference = 0.8
- SEED genres: [Rock, Pop]

Expected Output:
✅ PASS: t010 (Exact Match) - distance = 0.0
✅ PASS: t011 (Partial Overlap) - distance = 0.5
✅ PASS: t012 (Close Match) - distance = 0.333
❌ FILTERED: t013 (Borderline) - distance = 0.833 (>= 0.8)
❌ FILTERED: t014 (Completely Different) - distance = 1.0 (>= 0.8)

===========================================
TEST SCENARIO 3: FORBIDDEN TRACKS FILTER
===========================================

Input: User 1 (Clean Listener) - Profile-based recommendation
- User settings: include_owned = false, include_recent = false
- Library tracks: [t020, t021, t030]
- Recent tracks: [t022] (simulated via UserActivityService)

Expected Output:
❌ FILTERED: t020 (In Library 1) - in library
❌ FILTERED: t021 (In Library 2) - in library
❌ FILTERED: t022 (Recently Played) - in recent
❌ FILTERED: t030 (Explicit & In Library) - in library
✅ PASS: t023 (In Library 3) - not in THIS user's library
✅ PASS: t024 (Free Track) - not in library or recent

Input: User 2 (Explicit Fan) - Profile-based recommendation
- User settings: include_owned = true, include_recent = true
- Library tracks: [] (empty)

Expected Output:
✅ PASS: All tracks - includes owned and recent

Input: User 3 (Library Keeper) - Profile-based recommendation
- User settings: include_owned = false, include_recent = true
- Library tracks: [t023]
- Recent tracks: [t022]

Expected Output:
❌ FILTERED: t023 (In Library 3) - in THIS user's library
✅ PASS: t022 (Recently Played) - recent allowed
✅ PASS: t020, t021, t024 - not in library

===========================================
TEST SCENARIO 4: COMBINED FILTERS
===========================================

Input: User 1 (Clean Listener) - Seed track recommendation with SEED
- explicit_content = false
- include_owned = false
- include_recent = false
- Library: [t020, t021, t030]
- Recent: [t022]
- SEED genres: [Rock, Pop]
- contextGenreMaxDifference = 0.8

Expected Output:
✅ PASS: t010 (Exact Match) - clean, good genre match, not forbidden
✅ PASS: t011 (Partial Overlap) - clean, good genre match, not forbidden
✅ PASS: t012 (Close Match) - clean, good genre match, not forbidden
✅ PASS: t024 (Free Track) - clean, not forbidden (genre doesn't matter in this subset)
✅ PASS: t031 (Perfect Track) - clean, good genre match, not forbidden
❌ FILTERED: t002, t004 - explicit
❌ FILTERED: t013, t014 - genre distance >= 0.8
❌ FILTERED: t020, t021, t030 - in library
❌ FILTERED: t022 - in recent

===========================================
HOW TO TEST
===========================================

1. Load this SQL file into your database
2. Mock UserActivityService.getRecentTrackIds() to return [t022] for User 1
3. Test each scenario by calling:
   - recommendForProfile(userId, profileId) for profile-based
   - recommendForTrack(userId, seedTrackId='s0000...0000', yearDeltaMax) for seed-based
4. Verify filtered tracks are NOT in results
5. Verify passed tracks ARE in results (with score > 0)

*/
