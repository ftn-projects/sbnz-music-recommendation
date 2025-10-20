-- ================================
-- MINIMAL DATASET: TEST 2 (GENRE DISTANCE)
-- Focus: Seed-based recommendation with Jaccard distance threshold 0.8
-- ================================

-- Clean up
DELETE FROM user_genre_preferences;
DELETE FROM user_library_tracks;
DELETE FROM track_genres;
DELETE FROM tracks;
DELETE FROM genres;
DELETE FROM users;

-- One test user: allow everything else so only genre distance matters
INSERT INTO users (id, name, age, explicit_content, include_owned, include_recent) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Genre Tester', 26, true, true, true);

-- Only the genres we actually use in this scenario
INSERT INTO genres (id, name) VALUES
                                  ('10000000-0000-0000-0000-000000000001', 'Rock'),
                                  ('10000000-0000-0000-0000-000000000002', 'Pop'),
                                  ('10000000-0000-0000-0000-000000000003', 'Jazz'),
                                  ('10000000-0000-0000-0000-000000000004', 'Electronic'),
                                  ('10000000-0000-0000-0000-000000000005', 'Metal'),
                                  ('10000000-0000-0000-0000-000000000006', 'Hip Hop'),
                                  ('10000000-0000-0000-0000-000000000007', 'Classical');

-- Seed track: Rock + Pop (used for contextGenreIds)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('20000000-0000-0000-0000-000000000000', 'SEED - Rock Pop Mix', 'Test Artist', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);

INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('20000000-0000-0000-0000-000000000000', '10000000-0000-0000-0000-000000000001'), -- Rock
                                                  ('20000000-0000-0000-0000-000000000000', '10000000-0000-0000-0000-000000000002'); -- Pop

-- Candidates (t010–t014), all non-explicit to avoid explicit filtering
-- t010: EXACT MATCH [Rock, Pop]  => distance 0.0 (PASS)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000010', 'Exact Match Track', 'Artist E', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002');

-- t011: PARTIAL OVERLAP [Rock]     => distance 0.5 (PASS)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000011', 'Partial Overlap Track', 'Artist F', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres VALUES
    ('30000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001');

-- t012: CLOSE MATCH [Rock, Pop, Metal] => distance 1 - (2/3) = 0.333 (PASS)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000012', 'Close Match Track', 'Artist G', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000002'),
                             ('30000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000005');

-- t013: BORDERLINE [Rock, Metal, Hip Hop, Jazz, Electronic] => distance 1 - (1/6)=0.833 (FILTERED)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000013', 'Borderline Track', 'Artist H', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000005'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000006'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000003'),
                             ('30000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000004');

-- t014: COMPLETELY DIFFERENT [Jazz, Classical] => distance 1.0 (FILTERED)
INSERT INTO tracks (id, title, artist, release_year, explicit, duration, danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence) VALUES
    ('30000000-0000-0000-0000-000000000014', 'Completely Different Track', 'Artist I', 2020, false, 200, 0.5, 0.5, 0.05, 0.5, 0.0, 0.1, 0.5);
INSERT INTO track_genres VALUES
                             ('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000003'),
                             ('30000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000007');

-- Minimal user taste so PASS tracks get score > 0 (B1 rule)
INSERT INTO user_genre_preferences (user_id, genre_id, preference) VALUES
                                                                       ('11111111-1111-1111-1111-111111111111', '10000000-0000-0000-0000-000000000001', 0.8), -- Rock
                                                                       ('11111111-1111-1111-1111-111111111111', '10000000-0000-0000-0000-000000000002', 0.8); -- Pop

COMMIT;
