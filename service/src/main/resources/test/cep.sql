-- CEP Test Data Setup SQL
-- This script creates all necessary data for testing CEP rules in cep.drl

-- ============================================================================
-- CLEANUP
-- ============================================================================
DELETE FROM user_genre_preferences;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- ============================================================================
-- USERS
-- ============================================================================
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
    ('11111111-1111-1111-1111-111111111111', 'test_user_1', 25, true, true, true),
    ('22222222-2222-2222-2222-222222222222', 'test_user_2', 30, true, true, true),
    ('33333333-3333-3333-3333-333333333333', 'test_user_3', 28, true, true, true);

-- ============================================================================
-- GENRES (for all test cases)
-- ============================================================================
INSERT INTO genres (id, name) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Genre A - Rock'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Genre B - Pop'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Genre C - Jazz'),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Genre D - Electronic'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Genre E - Hip Hop'),
    ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'Genre F - Classical'),
    ('10101010-1010-1010-1010-101010101010', 'Genre G - Metal'),
    ('20202020-2020-2020-2020-202020202020', 'Genre H - Indie'),
    ('30303030-3030-3030-3030-303030303030', 'Genre I - Alternative'),
    ('40404040-4040-4040-4040-404040404040', 'Genre J - Reggae'),
    ('50505050-5050-5050-5050-505050505050', 'Genre K - Blues');

-- ============================================================================
-- TRACKS (for all test cases)
-- ============================================================================
-- Test Case 1: Three Listens Trigger Track Liked
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000001-0000-0000-0000-000000000001', 'Test Track 1', 'Artist A', 2023, false, 180, 0.65, 0.75, 0.04, 0.15, 0.00, 0.10, 0.70);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000001-0000-0000-0000-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Test Case 2: Like Event Creates Track Liked
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000002-0000-0000-0000-000000000002', 'Test Track 2', 'Artist B', 2022, false, 200, 0.70, 0.80, 0.04, 0.12, 0.00, 0.10, 0.75);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000002-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

-- Test Case 3: Like After Recent Listen Gets Bonus
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000003-0000-0000-0000-000000000003', 'Test Track 3', 'Artist C', 2021, false, 210, 0.60, 0.85, 0.03, 0.10, 0.00, 0.10, 0.80);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000003-0000-0000-0000-000000000003', 'cccccccc-cccc-cccc-cccc-cccccccccccc');

-- Test Case 4: Skip Event (Early Skip) Triggers Dislike
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000004-0000-0000-0000-000000000004', 'Test Track 4', 'Artist D', 2020, false, 200, 0.55, 0.70, 0.04, 0.20, 0.00, 0.10, 0.65);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000004-0000-0000-0000-000000000004', 'dddddddd-dddd-dddd-dddd-dddddddddddd');

-- Test Case 5: Skip Event (Late Skip) Only Base Rule
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000005-0000-0000-0000-000000000005', 'Test Track 5', 'Artist E', 2019, false, 180, 0.50, 0.65, 0.05, 0.25, 0.00, 0.12, 0.60);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000005-0000-0000-0000-000000000005', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee');

-- Test Case 6: Positive Genre Affinity → GenreLikedEvent
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000006-0000-0000-0000-000000000006', 'Test Track 6', 'Artist F', 2023, false, 240, 0.30, 0.90, 0.03, 0.60, 0.00, 0.10, 0.40);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000006-0000-0000-0000-000000000006', 'ffffffff-ffff-ffff-ffff-ffffffffffff');

-- Test Case 7: Negative Genre Affinity → GenreDislikedEvent
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000007-0000-0000-0000-000000000007', 'Test Track 7', 'Artist G', 2022, false, 190, 0.40, 0.60, 0.04, 0.30, 0.00, 0.15, 0.50);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000007-0000-0000-0000-000000000007', '10101010-1010-1010-1010-101010101010');

-- Test Case 8: Complex Scenario - Mixed Events (multi-genre track)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000008-0000-0000-0000-000000000008', 'Test Track 8', 'Artist H', 2023, false, 240, 0.75, 0.95, 0.03, 0.08, 0.00, 0.10, 0.85);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000008-0000-0000-0000-000000000008', '20202020-2020-2020-2020-202020202020'),
    ('00000008-0000-0000-0000-000000000008', '30303030-3030-3030-3030-303030303030');

-- Test Case 9: Window Expiry
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000009-0000-0000-0000-000000000009', 'Test Track 9', 'Artist I', 2021, false, 220, 0.68, 0.72, 0.04, 0.18, 0.00, 0.12, 0.68);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000009-0000-0000-0000-000000000009', '40404040-4040-4040-4040-404040404040');

-- Test Case 10: Duplicate Prevention - GenreLikedEvent Within 1 Hour
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000010-0000-0000-0000-000000000010', 'Test Track 10', 'Artist J', 2020, false, 230, 0.45, 0.88, 0.03, 0.22, 0.00, 0.10, 0.78);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000010-0000-0000-0000-000000000010', '50505050-5050-5050-5050-505050505050');

-- ============================================================================
-- ADDITIONAL TRACKS FOR COMPREHENSIVE TESTING
-- ============================================================================
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('00000011-0000-0000-0000-000000000011', 'Repeated Listen Track', 'Artist K', 2023, false, 180, 0.62, 0.78, 0.04, 0.14, 0.00, 0.10, 0.72),
    ('00000012-0000-0000-0000-000000000012', 'Explicit Track', 'Artist L', 2022, true, 200, 0.70, 0.82, 0.08, 0.10, 0.00, 0.12, 0.75),
    ('00000013-0000-0000-0000-000000000013', 'Short Track', 'Artist M', 2021, false, 30, 0.55, 0.70, 0.03, 0.20, 0.00, 0.10, 0.60),
    ('00000014-0000-0000-0000-000000000014', 'Long Track', 'Artist N', 2020, false, 600, 0.50, 0.68, 0.03, 0.25, 0.00, 0.08, 0.55);

INSERT INTO track_genres (track_id, genre_id) VALUES
    ('00000011-0000-0000-0000-000000000011', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    ('00000012-0000-0000-0000-000000000012', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
    ('00000013-0000-0000-0000-000000000013', 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
    ('00000014-0000-0000-0000-000000000014', 'dddddddd-dddd-dddd-dddd-dddddddddddd');

-- ============================================================================
-- INITIAL GENRE PREFERENCES (for baseline testing)
-- ============================================================================
INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
    -- User 1 preferences
    ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 0.5),
    ('11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 0.3),
    ('11111111-1111-1111-1111-111111111111', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 0.2),

    -- User 2 preferences
    ('22222222-2222-2222-2222-222222222222', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 0.7),
    ('22222222-2222-2222-2222-222222222222', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 0.4),

    -- User 3 preferences
    ('33333333-3333-3333-3333-333333333333', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 0.6),
    ('33333333-3333-3333-3333-333333333333', '10101010-1010-1010-1010-101010101010', 0.1);