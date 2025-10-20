
-- ========================================
-- SCENARIO 4: COMBINED FILTERS (MINIMAL, SEED-BASED)
-- User: Clean Listener (explicit OFF, include_owned OFF, include_recent OFF)
-- Seed genres: Rock, Pop
-- Expected pass:    t010, t011, t012, t024, t031
-- Expected filtered: t002, t004 (explicit), t013, t014 (distance >= 0.8),
--                    t020, t021, t030 (in library), t022 (recent)
-- ========================================

BEGIN;

-- Clean up (FK-safe order)
DELETE FROM user_library_tracks;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- =======================
-- USER
-- =======================
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Clean Listener', 25, false, false, false);

-- =======================
-- GENRES (only those needed)
-- =======================
INSERT INTO genres (id, name) VALUES
                                  ('10000000-0000-0000-0000-000000000001', 'Rock'),
                                  ('10000000-0000-0000-0000-000000000002', 'Pop'),
                                  ('10000000-0000-0000-0000-000000000003', 'Jazz'),
                                  ('10000000-0000-0000-0000-000000000004', 'Electronic'),
                                  ('10000000-0000-0000-0000-000000000005', 'Metal'),
                                  ('10000000-0000-0000-0000-000000000006', 'Hip Hop'),
                                  ('10000000-0000-0000-0000-000000000007', 'Classical');

-- =======================
-- SEED TRACK (Rock + Pop)
-- =======================
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('20000000-0000-0000-0000-000000000000', 'SEED - Rock Pop Mix', 'Test Artist', 2020,
     false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);

INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('20000000-0000-0000-0000-000000000000', '10000000-0000-0000-0000-000000000001'),
                                                  ('20000000-0000-0000-0000-000000000000', '10000000-0000-0000-0000-000000000002');

-- =======================
-- EXPLICIT TRACKS (should be filtered for User 1)
-- =======================
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
                       ('30000000-0000-0000-0000-000000000002', 'Explicit Song 1', 'Artist B', 2020, true,
                        200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000004', 'Explicit Song 2', 'Artist D', 2020, true,
                        200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);

INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002');

-- =======================
-- GENRE DISTANCE SET
-- =======================
-- t010: Exact match [Rock, Pop] -> PASS
-- t011: Partial overlap [Rock]   -> PASS
-- t012: Close match [Rock, Pop, Metal] -> PASS
-- t013: Borderline (>=0.8)       -> FILTER
-- t014: Completely different     -> FILTER
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
                       ('30000000-0000-0000-0000-000000000010', 'Exact Match Track',    'Artist E', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000011', 'Partial Overlap Track','Artist F', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000012', 'Close Match Track',    'Artist G', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000013', 'Borderline Track',     'Artist H', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000014', 'Completely Different', 'Artist I', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);

INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002'),

                             ('30000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001'),

                             ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000002'),
                             ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000005'),

                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000005'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000006'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000003'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000004'),

                             ('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000003'),
                             ('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000007');

-- =======================
-- FORBIDDEN / LIBRARY / RECENT
-- =======================
-- Library: t020, t021, t030 (explicit)
-- Recent: t022 (mock via service) — SAME ATTRIBUTES + GENRES AS SEED, different ID
-- Free passer: t024
-- Perfect passer: t031 (Rock + Pop)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
                       ('30000000-0000-0000-0000-000000000020', 'In Library 1',          'Artist J', 2020, false, 200, 0.5, 0.6, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000021', 'In Library 2',          'Artist K', 2020, false, 200, 0.5, 0.6, 0.05, 0.5, 0.0, 0.1, 0.5),
-- Recent twin of SEED (identical features/genres, different id)
                       ('30000000-0000-0000-0000-000000000022', 'Recently Played (Seed Twin)', 'Test Artist', 2020,
                        false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000030', 'Explicit & In Library', 'Artist O', 2020, true,  200, 0.5, 0.6, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000024', 'Free Track',            'Artist N', 2020, false, 200, 0.5, 0.6, 0.05, 0.5, 0.0, 0.1, 0.5),
                       ('30000000-0000-0000-0000-000000000031', 'Perfect Track',         'Artist P', 2020, false, 200, 0.5, 0.6, 0.05, 0.5, 0.0, 0.1, 0.5);

INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000020', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000001'),

-- recent twin shares Rock+Pop like the seed
                             ('30000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000002'),

                             ('30000000-0000-0000-0000-000000000030', '10000000-0000-0000-0000-000000000001'),

                             ('30000000-0000-0000-0000-000000000024', '10000000-0000-0000-0000-000000000001'),

                             ('30000000-0000-0000-0000-000000000031', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000031', '10000000-0000-0000-0000-000000000002');

-- User 1 library (forbidden)
INSERT INTO user_library_tracks (user_id, track_id) VALUES
                                                        ('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000020'),
                                                        ('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000021'),
                                                        ('11111111-1111-1111-1111-111111111111', '30000000-0000-0000-0000-000000000030');

COMMIT;
