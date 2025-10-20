-- ========================================
-- MINIMAL DATASET: TEST SCENARIO 1 (Explicit filter)
-- Keeps ONLY users, genres (Rock/Pop), tracks t001–t004, their genres, one profile,
-- and minimal user_genre_preferences so clean tracks get a score > 0.
-- ========================================

-- Clean up
DELETE FROM profile_traits;
DELETE FROM profiles;
DELETE FROM user_genre_preferences;
DELETE FROM user_library_tracks;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- Users
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
                                                                                       ('11111111-1111-1111-1111-111111111111', 'Clean Listener', 25, false, false, false), -- explicit OFF
                                                                                       ('22222222-2222-2222-2222-222222222222', 'Explicit Fan',   28, true,  true,  true);  -- explicit ON

-- Genres (only what we need)
INSERT INTO genres (id, name) VALUES
                                  ('10000000-0000-0000-0000-000000000001', 'Rock'),
                                  ('10000000-0000-0000-0000-000000000002', 'Pop');

-- Tracks: t001–t004 only
-- t001: Clean (Rock)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000001', 'Clean Song 1', 'Artist A', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
    ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001');

-- t002: Explicit (Rock)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000002', 'Explicit Song 1', 'Artist B', 2020, true, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
    ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001');

-- t003: Clean (Pop)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000003', 'Clean Song 2', 'Artist C', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
    ('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002');

-- t004: Explicit (Pop)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000004', 'Explicit Song 2', 'Artist D', 2020, true, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres (track_id, genre_id) VALUES
    ('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002');

-- Minimal profile to trigger profile-based rules
INSERT INTO profiles (id, name, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('40000000-0000-0000-0000-000000000001', 'Energetic Rock Profile', 0.6, 0.7, 0.05, 0.2, 0.1, 0.15, 0.6);

-- Give both users taste for Rock/Pop so clean tracks receive a positive score
INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
                                                                       ('11111111-1111-1111-1111-111111111111', '10000000-0000-0000-0000-000000000001', 0.8),
                                                                       ('11111111-1111-1111-1111-111111111111', '10000000-0000-0000-0000-000000000002', 0.8),
                                                                       ('22222222-2222-2222-2222-222222222222', '10000000-0000-0000-0000-000000000001', 0.8),
                                                                       ('22222222-2222-2222-2222-222222222222', '10000000-0000-0000-0000-000000000002', 0.8);

COMMIT;