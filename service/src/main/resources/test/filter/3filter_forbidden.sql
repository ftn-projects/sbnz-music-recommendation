-- ================================
-- MINIMAL DATASET: TEST 3 (FORBIDDEN)
-- Focus: library/recent exclusion behavior
-- ================================

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
-- U1: exclude owned & recent
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Clean Listener', 25, true,  false, false);

-- U2: include owned & recent
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
    ('22222222-2222-2222-2222-222222222222', 'Explicit Fan', 28, true, true,  true);

-- U3: exclude owned, include recent
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
    ('33333333-3333-3333-3333-333333333333', 'Library Keeper', 30, true, false, true);

-- Genres (only Rock needed)
INSERT INTO genres (id, name) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Rock');

-- Tracks (all Rock so taste scoring applies)
-- t020, t021: in U1's library
-- t022: to be treated as "recent" for U1 via service mock
-- t023: in U3's library (NOT in U1's)
-- t024: free track
-- t030: explicit + in U1's library (double-filter for U1)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
                                                                                                                                                                   ('30000000-0000-0000-0000-000000000020', 'In Library 1',            'Artist J', 2020, false, 200, 0.5, 0.6, 0.05, 0.4, 0.0, 0.1, 0.5),
                                                                                                                                                                   ('30000000-0000-0000-0000-000000000021', 'In Library 2',            'Artist K', 2020, false, 200, 0.5, 0.6, 0.05, 0.4, 0.0, 0.1, 0.5),
                                                                                                                                                                   ('30000000-0000-0000-0000-000000000022', 'Recently Played',         'Artist L', 2020, false, 200, 0.5, 0.6, 0.05, 0.4, 0.0, 0.1, 0.5),
                                                                                                                                                                   ('30000000-0000-0000-0000-000000000023', 'In Library 3',            'Artist M', 2020, false, 200, 0.5, 0.6, 0.05, 0.4, 0.0, 0.1, 0.5),
                                                                                                                                                                   ('30000000-0000-0000-0000-000000000024', 'Free Track',              'Artist N', 2020, false, 200, 0.5, 0.6, 0.05, 0.4, 0.0, 0.1, 0.5),
                                                                                                                                                                   ('30000000-0000-0000-0000-000000000030', 'Explicit & In Library',   'Artist O', 2020, true,  200, 0.5, 0.6, 0.05, 0.4, 0.0, 0.1, 0.5);

INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('30000000-0000-0000-0000-000000000020', '10000000-0000-0000-0000-000000000001'),
                                                  ('30000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000001'),
                                                  ('30000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000001'),
                                                  ('30000000-0000-0000-0000-000000000023', '10000000-0000-0000-0000-000000000001'),
                                                  ('30000000-0000-0000-0000-000000000024', '10000000-0000-0000-0000-000000000001'),
                                                  ('30000000-0000-0000-0000-000000000030', '10000000-0000-0000-0000-000000000001');

-- Libraries
-- U1 owns: t020, t021, t030
INSERT INTO user_library_tracks (user_id, track_id) VALUES
                                                        ('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000020'),
                                                        ('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000021'),
                                                        ('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000030');

-- U3 owns: t023
INSERT INTO user_library_tracks VALUES
    ('33333333-3333-3333-3333-333333333333', '30000000-0000-0000-0000-000000000023');

-- Minimal taste so tracks can get score > 0
INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
                                                                       ('11111111-1111-1111-1111-111111111111', '10000000-0000-0000-0000-000000000001', 0.8),
                                                                       ('22222222-2222-2222-2222-222222222222', '10000000-0000-0000-0000-000000000001', 0.8),
                                                                       ('33333333-3333-3333-3333-333333333333', '10000000-0000-0000-0000-000000000001', 0.8);

-- Minimal profile to drive profile-based flow
INSERT INTO profiles (id, name, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('40000000-0000-0000-0000-000000000001', 'Forbidden Filter Profile', 0.6, 0.7, 0.05, 0.2, 0.1, 0.15, 0.6);

COMMIT;
