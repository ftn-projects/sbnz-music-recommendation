
-- Insert sample users
INSERT INTO users (id, name, username, age, explicit_content, include_owned, include_recent)
VALUES ('b6f9d86a-7f2e-4b31-bf5a-8e36e2b1c211', 'Alice Johnson', 'ana', 25, TRUE, TRUE, FALSE),
       ('d3a6b20f-9830-4e17-9c38-91e7f22f5b88', 'Bob Smith', 'dimitrije', 31, FALSE, TRUE, TRUE),
       ('8c61a543-50c3-4d1a-9110-9c2c1e0c1142', 'Carla Nguyen', 'masa', 28, TRUE, FALSE, TRUE),
       ('af26df30-27f8-44e1-8a65-2e5e2e3fa3cb', 'David Ivanov', 'jovan', 22, FALSE, FALSE, FALSE);

-- ======================
-- ROOT LEVEL (8)
-- ======================
INSERT INTO genres (id, name, parent_id)
VALUES ('8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01', 'Pop', NULL),
       ('d5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02', 'Hip-Hop / Rap', NULL),
       ('3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03', 'Electronic', NULL),
       ('a12b34cd-56ef-47ab-9a10-22b33c44dd04', 'Rock', NULL),
       ('5f4e3d2c-1b0a-49a8-8f7e-6d5c4b3a2a05', 'Latin', NULL),
       ('b7c6a5d4-e3f2-4b1a-8c9d-0e1f2a3b4c06', 'Afrobeats', NULL),
       ('90ab12cd-34ef-45a6-9b78-cd12ef34ab07', 'R&B / Soul', NULL),
       ('6e5d4c3b-2a1f-40e9-8d7c-5b4a3c2d1e08', 'Country', NULL);

-- ======================
-- INTERMEDIATE LEVEL (10)
-- ======================
-- Pop
INSERT INTO genres (id, name, parent_id)
VALUES ('f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109', 'K-Pop', '8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
       ('0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1', 'Indie Pop', '8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01');

-- Hip-Hop / Rap
INSERT INTO genres (id, name, parent_id)
VALUES ('11aa22bb-33cc-44dd-85ee-66ff77889911', 'Trap', 'd5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02');

-- Electronic
INSERT INTO genres (id, name, parent_id)
VALUES ('55ee66ff-77aa-88bb-99cc-00ddeeffaa15', 'House', '3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
       ('77aa88bb-99cc-00dd-eeff-11aabbccdd17', 'Drum & Bass', '3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03');

-- Rock
INSERT INTO genres (id, name, parent_id)
VALUES ('88bb99cc-00dd-eeff-11aa-bbccddeeff18', 'Alternative Rock', 'a12b34cd-56ef-47ab-9a10-22b33c44dd04');

-- Latin
INSERT INTO genres (id, name, parent_id)
VALUES ('bb22cc33-dd44-ee55-ff66-778899aabb20', 'Regional Mexican', '5f4e3d2c-1b0a-49a8-8f7e-6d5c4b3a2a05');

-- Afrobeats
INSERT INTO genres (id, name, parent_id)
VALUES ('dd44ee55-ff66-7788-99aa-bbccddeeff22', 'Amapiano', 'b7c6a5d4-e3f2-4b1a-8c9d-0e1f2a3b4c06');

-- R&B / Soul
INSERT INTO genres (id, name, parent_id)
VALUES ('ee55ff66-7788-99aa-bbcc-ddeeff001123', 'Contemporary R&B', '90ab12cd-34ef-45a6-9b78-cd12ef34ab07');

-- Country
INSERT INTO genres (id, name, parent_id)
VALUES ('ff667788-99aa-bbcc-ddee-ff0011223344', 'Country Pop', '6e5d4c3b-2a1f-40e9-8d7c-5b4a3c2d1e08');

-- ======================
-- LEAF LEVEL (12)
-- ======================
-- Pop → K-Pop
INSERT INTO genres (id, name, parent_id)
VALUES ('10111213-1415-1617-1819-1a1b1c1d1e01', 'Girl Group Pop', 'f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
       ('20212223-2425-2627-2829-2a2b2c2d2e02', 'Boy Group Pop', 'f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109');

-- Pop → Indie Pop
INSERT INTO genres (id, name, parent_id)
VALUES ('30313233-3435-3637-3839-3a3b3c3d3e03', 'Bedroom Pop', '0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1');

-- Hip-Hop / Rap → Trap
INSERT INTO genres (id, name, parent_id)
VALUES ('40414243-4445-4647-4849-4a4b4c4d4e04', 'Melodic Trap', '11aa22bb-33cc-44dd-85ee-66ff77889911');

-- Electronic → House
INSERT INTO genres (id, name, parent_id)
VALUES ('50515253-5455-5657-5859-5a5b5c5d5e05', 'Tech House', '55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
       ('60616263-6465-6667-6869-6a6b6c6d6e06', 'Deep House', '55ee66ff-77aa-88bb-99cc-00ddeeffaa15');

-- Electronic → Drum & Bass
INSERT INTO genres (id, name, parent_id)
VALUES ('70717273-7475-7677-7879-7a7b7c7d7e07', 'Liquid Drum & Bass', '77aa88bb-99cc-00dd-eeff-11aabbccdd17');

-- Rock → Alternative Rock
INSERT INTO genres (id, name, parent_id)
VALUES ('80818283-8485-8687-8889-8a8b8c8d8e08', 'Indie Rock', '88bb99cc-00dd-eeff-11aa-bbccddeeff18');

-- Latin → Regional Mexican
INSERT INTO genres (id, name, parent_id)
VALUES ('90919293-9495-9697-9899-9a9b9c9d9e09', 'Corridos Tumbados', 'bb22cc33-dd44-ee55-ff66-778899aabb20'),
       ('a0a1a2a3-a4a5-a6a7-a8a9-aaabacadae0a', 'Sierreño', 'bb22cc33-dd44-ee55-ff66-778899aabb20');

-- Afrobeats → Amapiano
INSERT INTO genres (id, name, parent_id)
VALUES ('b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0', 'Private School Amapiano', 'dd44ee55-ff66-7788-99aa-bbccddeeff22');

-- R&B / Soul → Contemporary R&B

-- Country → Country Pop
INSERT INTO genres (id, name, parent_id)
VALUES ('c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c', 'Bro-Country', 'ff667788-99aa-bbcc-ddee-ff0011223344');


-- Insert sample profiles with target audio features
INSERT INTO profiles (id, name)
VALUES ('0a6b1f0c-1d3e-4f1a-8b3a-2b7f8f9c3a01', 'Chill'),
       ('1b7c2e1d-2e4f-5a2b-9c4b-3c8a9fab4b02', 'Party / Night Out'),
       ('2c8d3f2e-3f50-6b3c-ad5c-4d9bafbc5c03', 'Focus / Study'),
       ('3d9e4a3f-4051-7c4d-be6d-5e0cbcbd6d04', 'Workout / High-Intensity'),
       ('4eaf5b40-5162-8d5e-cf7e-6f1dccce7e05', 'Road Trip / Feel-Good');

-- Chill: low energy, warm & relaxed, mildly positive
UPDATE profiles
SET danceability     = 0.45,
    energy           = 0.30,
    speechiness      = 0.05,
    acousticness     = 0.70,
    instrumentalness = 0.35,
    liveness         = 0.15,
    valence          = 0.55
WHERE id = '0a6b1f0c-1d3e-4f1a-8b3a-2b7f8f9c3a01';

-- Party / Night Out: club-leaning, high energy & danceability, bright mood
UPDATE profiles
SET danceability     = 0.85,
    energy           = 0.90,
    speechiness      = 0.10,
    acousticness     = 0.05,
    instrumentalness = 0.10,
    liveness         = 0.35,
    valence          = 0.80
WHERE id = '1b7c2e1d-2e4f-5a2b-9c4b-3c8a9fab4b02';

-- Focus / Study: steady, unobtrusive, mostly instrumental
UPDATE profiles
SET danceability     = 0.50,
    energy           = 0.35,
    speechiness      = 0.03,
    acousticness     = 0.55,
    instrumentalness = 0.75,
    liveness         = 0.10,
    valence          = 0.45
WHERE id = '2c8d3f2e-3f50-6b3c-ad5c-4d9bafbc5c03';

-- Workout / High-Intensity: fast, driving, motivational
UPDATE profiles
SET danceability     = 0.80,
    energy           = 0.95,
    speechiness      = 0.08,
    acousticness     = 0.05,
    instrumentalness = 0.05,
    liveness         = 0.20,
    valence          = 0.70
WHERE id = '3d9e4a3f-4051-7c4d-be6d-5e0cbcbd6d04';

-- Road Trip / Feel-Good: sing-along, mid energy, very positive
UPDATE profiles
SET danceability     = 0.65,
    energy           = 0.60,
    speechiness      = 0.06,
    acousticness     = 0.25,
    instrumentalness = 0.20,
    liveness         = 0.18,
    valence          = 0.85
WHERE id = '4eaf5b40-5162-8d5e-cf7e-6f1dccce7e05';

-- ===== BASE TRAITS (attach these to profiles) =====
INSERT INTO traits (id, name, parent_id)
VALUES ('10000000-0000-0000-0000-000000000001', 'Calm', NULL),
       ('10000000-0000-0000-0000-000000000002', 'Energetic', NULL),
       ('10000000-0000-0000-0000-000000000003', 'Danceable', NULL),
       ('10000000-0000-0000-0000-000000000004', 'Bass-Heavy', NULL),
       ('10000000-0000-0000-0000-000000000005', 'Melodic', NULL),
       ('10000000-0000-0000-0000-000000000006', 'Atmospheric', NULL),
       ('10000000-0000-0000-0000-000000000007', 'Acoustic / Organic', NULL),
       ('10000000-0000-0000-0000-000000000008', 'Urban / Street', NULL),
       ('10000000-0000-0000-0000-000000000009', 'Romantic', NULL),
       ('10000000-0000-0000-0000-00000000000a', 'Nostalgic', NULL),
       ('10000000-0000-0000-0000-00000000000b', 'Uplifting / Feel-Good', NULL),
       ('10000000-0000-0000-0000-00000000000c', 'Experimental / Leftfield', NULL);

-- ===== LEAF TRAITS (link these to genres via trait_genres) =====
-- Under Danceable
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000001', 'Four-on-the-Floor Groove', '10000000-0000-0000-0000-000000000003'),
       ('20000000-0000-0000-0000-000000000002', 'Syncopated Basslines', '10000000-0000-0000-0000-000000000003'),
       ('20000000-0000-0000-0000-000000000003', 'Choreo-Ready Hooks', '10000000-0000-0000-0000-000000000003');

-- Under Bass-Heavy
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000004', '808 Sub-Bass & Hi-Hat Rolls', '10000000-0000-0000-0000-000000000004'),
       ('20000000-0000-0000-0000-000000000005', 'Log-Drum Bounce', '10000000-0000-0000-0000-000000000004');

-- Under Energetic
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000006', 'Anthemic Choruses', '10000000-0000-0000-0000-000000000002'),
       ('20000000-0000-0000-0000-000000000007', 'Fast Breakbeats', '10000000-0000-0000-0000-000000000002');

-- Under Calm
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000008', 'Lo-Fi Textures', '10000000-0000-0000-0000-000000000001'),
       ('20000000-0000-0000-0000-000000000009', 'Warm Pads & Soft Keys', '10000000-0000-0000-0000-000000000001');

-- Under Melodic
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-00000000000a', 'Hook-Driven Choruses', '10000000-0000-0000-0000-000000000005'),
       ('20000000-0000-0000-0000-00000000000b', 'Auto-Tuned Melodies', '10000000-0000-0000-0000-000000000005');

-- Under Atmospheric
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-00000000000c', 'Dreamy / Ethereal', '10000000-0000-0000-0000-000000000006'),
       ('20000000-0000-0000-0000-00000000000d', 'Liquid / Ambient Layers', '10000000-0000-0000-0000-000000000006');

-- Under Acoustic / Organic
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-00000000000e', 'Acoustic Strings & Guitars', '10000000-0000-0000-0000-000000000007'),
       ('20000000-0000-0000-0000-00000000000f', 'Storytelling Songcraft', '10000000-0000-0000-0000-000000000007');

-- Under Urban / Street
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000010', 'Street Swagger & Bounce', '10000000-0000-0000-0000-000000000008'),
       ('20000000-0000-0000-0000-000000000011', 'Grime/Drill Cadence', '10000000-0000-0000-0000-000000000008');

-- Under Romantic
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000012', 'Smooth Vocals & Harmonies', '10000000-0000-0000-0000-000000000009'),
       ('20000000-0000-0000-0000-000000000013', 'Slow-Jam Groove', '10000000-0000-0000-0000-000000000009');

-- Under Nostalgic
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000014', 'Throwback Hooks', '10000000-0000-0000-0000-00000000000a'),
       ('20000000-0000-0000-0000-000000000015', 'Retro Aesthetics', '10000000-0000-0000-0000-00000000000a');

-- Under Uplifting / Feel-Good
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000016', 'Sunny / Feel-Good Vibe', '10000000-0000-0000-0000-00000000000b'),
       ('20000000-0000-0000-0000-000000000017', 'Sing-Along Choruses', '10000000-0000-0000-0000-00000000000b');

-- Under Experimental / Leftfield
INSERT INTO traits (id, name, parent_id)
VALUES ('20000000-0000-0000-0000-000000000018', 'Minimal / Hypnotic', '10000000-0000-0000-0000-00000000000c'),
       ('20000000-0000-0000-0000-000000000019', 'Leftfield Sound Design', '10000000-0000-0000-0000-00000000000c');


-- ===== POP → K-Pop + subgenres =====
-- K-Pop
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000003', 'f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'), -- Choreo-Ready Hooks
       ('20000000-0000-0000-0000-00000000000a', 'f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'), -- Hook-Driven Choruses
       ('20000000-0000-0000-0000-000000000003', '10111213-1415-1617-1819-1a1b1c1d1e01'), -- Girl Group Pop
       ('20000000-0000-0000-0000-00000000000a', '10111213-1415-1617-1819-1a1b1c1d1e01'),
       ('20000000-0000-0000-0000-000000000003', '20212223-2425-2627-2829-2a2b2c2d2e02'), -- Boy Group Pop
       ('20000000-0000-0000-0000-00000000000a', '20212223-2425-2627-2829-2a2b2c2d2e02');

-- Pop → Indie Pop + Bedroom Pop
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000008', '0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'), -- Lo-Fi Textures
       ('20000000-0000-0000-0000-00000000000c', '0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'), -- Dreamy / Ethereal
       ('20000000-0000-0000-0000-000000000008', '30313233-3435-3637-3839-3a3b3c3d3e03'),  -- Bedroom Pop
       ('20000000-0000-0000-0000-00000000000c', '30313233-3435-3637-3839-3a3b3c3d3e03'),
       ('20000000-0000-0000-0000-00000000000d', '30313233-3435-3637-3839-3a3b3c3d3e03');
-- Liquid / Ambient Layers

-- ===== HIP-HOP / RAP → Trap + Melodic Trap =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000004',
        '11aa22bb-33cc-44dd-85ee-66ff77889911'),                                         -- 808 Sub-Bass & Hi-Hat Rolls (Trap)
       ('20000000-0000-0000-0000-000000000010', '11aa22bb-33cc-44dd-85ee-66ff77889911'), -- Street Swagger & Bounce
       ('20000000-0000-0000-0000-00000000000b',
        '40414243-4445-4647-4849-4a4b4c4d4e04'),                                         -- Auto-Tuned Melodies (Melodic Trap)
       ('20000000-0000-0000-0000-000000000004', '40414243-4445-4647-4849-4a4b4c4d4e04');

-- ===== ELECTRONIC → House (+Tech/Deep) =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000001', '55ee66ff-77aa-88bb-99cc-00ddeeffaa15'), -- Four-on-the-Floor Groove
       ('20000000-0000-0000-0000-000000000002', '55ee66ff-77aa-88bb-99cc-00ddeeffaa15'), -- Syncopated Basslines
       ('20000000-0000-0000-0000-000000000018',
        '50515253-5455-5657-5859-5a5b5c5d5e05'),                                         -- Minimal / Hypnotic (Tech House)
       ('20000000-0000-0000-0000-000000000002', '50515253-5455-5657-5859-5a5b5c5d5e05'),
       ('20000000-0000-0000-0000-000000000001',
        '60616263-6465-6667-6869-6a6b6c6d6e06'),                                         -- Four-on-the-Floor (Deep House)
       ('20000000-0000-0000-0000-000000000009', '60616263-6465-6667-6869-6a6b6c6d6e06');
-- Warm Pads & Soft Keys

-- ===== ELECTRONIC → Drum & Bass (+Liquid) =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000007', '77aa88bb-99cc-00dd-eeff-11aabbccdd17'), -- Fast Breakbeats
       ('20000000-0000-0000-0000-00000000000d', '70717273-7475-7677-7879-7a7b7c7d7e07');
-- Liquid / Ambient Layers (Liquid DnB)

-- ===== ROCK → Alternative Rock (+Indie Rock) =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000006', '88bb99cc-00dd-eeff-11aa-bbccddeeff18'), -- Anthemic Choruses
       ('20000000-0000-0000-0000-00000000000e',
        '88bb99cc-00dd-eeff-11aa-bbccddeeff18'),                                         -- Acoustic Strings & Guitars (unplugged crossovers)
       ('20000000-0000-0000-0000-000000000006', '80818283-8485-8687-8889-8a8b8c8d8e08'), -- Indie Rock
       ('20000000-0000-0000-0000-000000000015', '80818283-8485-8687-8889-8a8b8c8d8e08');
-- Retro Aesthetics (garage/retro indie)

-- ===== LATIN → Regional Mexican (+Corridos, Sierreño) =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-00000000000f',
        'bb22cc33-dd44-ee55-ff66-778899aabb20'),                                         -- Storytelling Songcraft (Regional Mexican)
       ('20000000-0000-0000-0000-00000000000e', 'bb22cc33-dd44-ee55-ff66-778899aabb20'), -- Acoustic Strings & Guitars
       ('20000000-0000-0000-0000-00000000000f',
        '90919293-9495-9697-9899-9a9b9c9d9e09'),                                         -- Storytelling (Corridos Tumbados)
       ('20000000-0000-0000-0000-000000000010',
        '90919293-9495-9697-9899-9a9b9c9d9e09'),                                         -- Street Swagger (urban corridos influence)
       ('20000000-0000-0000-0000-00000000000e', 'a0a1a2a3-a4a5-a6a7-a8a9-aaabacadae0a');
-- Acoustic Strings (Sierreño trio)

-- ===== AFROBEATS → Amapiano (+Private School) =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000005', 'dd44ee55-ff66-7788-99aa-bbccddeeff22'), -- Log-Drum Bounce
       ('20000000-0000-0000-0000-000000000001',
        'dd44ee55-ff66-7788-99aa-bbccddeeff22'),                                         -- Four-on-the-Floor Groove (Amapiano dance variants)
       ('20000000-0000-0000-0000-000000000012',
        'b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0'),                                         -- Smooth Vocals & Harmonies (Private School)
       ('20000000-0000-0000-0000-000000000016', 'b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0');
-- Sunny / Feel-Good Vibe

-- ===== R&B / SOUL → Contemporary R&B =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000012', 'ee55ff66-7788-99aa-bbcc-ddeeff001123'), -- Smooth Vocals & Harmonies
       ('20000000-0000-0000-0000-000000000013', 'ee55ff66-7788-99aa-bbcc-ddeeff001123'), -- Slow-Jam Groove
       ('20000000-0000-0000-0000-000000000014', 'ee55ff66-7788-99aa-bbcc-ddeeff001123');
-- Throwback Hooks (90s/00s stylings)

-- ===== COUNTRY → Country Pop (+Bro-Country) =====
INSERT INTO trait_genres (trait_id, genre_id)
VALUES ('20000000-0000-0000-0000-000000000017',
        'ff667788-99aa-bbcc-ddee-ff0011223344'),                                         -- Sing-Along Choruses (Country Pop)
       ('20000000-0000-0000-0000-00000000000f', 'ff667788-99aa-bbcc-ddee-ff0011223344'), -- Storytelling Songcraft
       ('20000000-0000-0000-0000-000000000006',
        'c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c'),                                         -- Anthemic Choruses (Bro-Country)
       ('20000000-0000-0000-0000-000000000016', 'c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c');

-- ===========================================
-- USER GENRE PREFERENCES (user_id, genre_id -> preference)
-- ===========================================
-- Alice Johnson (ana) – Pop/Electronic leaning, some R&B
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('b6f9d86a-7f2e-4b31-bf5a-8e36e2b1c211', 'f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109', 0.90),  -- K-Pop
       ('b6f9d86a-7f2e-4b31-bf5a-8e36e2b1c211', '0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1', 0.75), -- Indie Pop
       ('b6f9d86a-7f2e-4b31-bf5a-8e36e2b1c211', '55ee66ff-77aa-88bb-99cc-00ddeeffaa15', 0.4),   -- House
       ('b6f9d86a-7f2e-4b31-bf5a-8e36e2b1c211', 'ee55ff66-7788-99aa-bbcc-ddeeff001123', 0.72),  -- Contemporary R&B
       ('b6f9d86a-7f2e-4b31-bf5a-8e36e2b1c211', '10111213-1415-1617-1819-1a1b1c1d1e01', 0.82);
-- Girl Group Pop

-- Bob Smith (dimitrije) – Hip-hop/Latin/Electronic
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('d3a6b20f-9830-4e17-9c38-91e7f22f5b88', '11aa22bb-33cc-44dd-85ee-66ff77889911', 0.88), -- Trap
       ('d3a6b20f-9830-4e17-9c38-91e7f22f5b88', '40414243-4445-4647-4849-4a4b4c4d4e04', 0.80), -- Melodic Trap
       ('d3a6b20f-9830-4e17-9c38-91e7f22f5b88', '55ee66ff-77aa-88bb-99cc-00ddeeffaa15', 0.60), -- House
       ('d3a6b20f-9830-4e17-9c38-91e7f22f5b88', 'bb22cc33-dd44-ee55-ff66-778899aabb20', 0.70), -- Regional Mexican
       ('d3a6b20f-9830-4e17-9c38-91e7f22f5b88', 'dd44ee55-ff66-7788-99aa-bbccddeeff22', 0.2);
-- Amapiano

-- Carla Nguyen (masa) – Indie/Alt + Liquid DnB + Bedroom Pop
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('8c61a543-50c3-4d1a-9110-9c2c1e0c1142', '88bb99cc-00dd-eeff-11aa-bbccddeeff18', 0.78), -- Alternative Rock
       ('8c61a543-50c3-4d1a-9110-9c2c1e0c1142', '80818283-8485-8687-8889-8a8b8c8d8e08', 0.81), -- Indie Rock
       ('8c61a543-50c3-4d1a-9110-9c2c1e0c1142', '30313233-3435-3637-3839-3a3b3c3d3e03', 0.3),  -- Bedroom Pop
       ('8c61a543-50c3-4d1a-9110-9c2c1e0c1142', '70717273-7475-7677-7879-7a7b7c7d7e07', 0.83);
-- Liquid Drum & Bass

-- David Ivanov (jovan) – Country/R&B + some Latin
INSERT INTO user_genre_preferences (user_id, genre_id, preference)
VALUES ('af26df30-27f8-44e1-8a65-2e5e2e3fa3cb', 'ff667788-99aa-bbcc-ddee-ff0011223344', 0.84), -- Country Pop
       ('af26df30-27f8-44e1-8a65-2e5e2e3fa3cb', 'c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c', 0.3),  -- Bro-Country
       ('af26df30-27f8-44e1-8a65-2e5e2e3fa3cb', 'ee55ff66-7788-99aa-bbcc-ddeeff001123', 0.63), -- Contemporary R&B
       ('af26df30-27f8-44e1-8a65-2e5e2e3fa3cb', 'bb22cc33-dd44-ee55-ff66-778899aabb20', 0.58);
-- Regional Mexican

INSERT INTO tracks (
    id, title, artist, release_year, explicit, duration,
    danceability, energy, speechiness, acousticness, instrumentalness, liveness, valence
) VALUES
-- ==== K-POP / GIRL GROUP POP / BOY GROUP POP ====
('11111111-1111-4111-8111-111111111101','Butter','BTS',2021,FALSE,164,0.81,0.82,0.04,0.03,0.00,0.10,0.95),
('11111111-1111-4111-8111-111111111102','Kill This Love','BLACKPINK',2019,FALSE,252,0.73,0.90,0.05,0.02,0.00,0.15,0.67),
('11111111-1111-4111-8111-111111111103','Ditto','NewJeans',2022,FALSE,209,0.69,0.45,0.03,0.28,0.00,0.12,0.74),
('11111111-1111-4111-8111-111111111104','Alcohol-Free','TWICE',2021,FALSE,174,0.78,0.58,0.04,0.20,0.00,0.10,0.66),
('11111111-1111-4111-8111-111111111105','MANIAC','Stray Kids',2022,TRUE,153,0.85,0.88,0.05,0.03,0.00,0.11,0.82),

-- ==== INDIE POP / BEDROOM POP ====
('22222222-2222-4222-8222-222222222201','Bags','Clairo',2019,FALSE,225,0.57,0.30,0.04,0.45,0.00,0.10,0.36),
('22222222-2222-4222-8222-222222222202','Loving Is Easy','Rex Orange County',2017,FALSE,187,0.62,0.58,0.04,0.30,0.00,0.12,0.75),
('22222222-2222-4222-8222-222222222203','Motion Sickness','Phoebe Bridgers',2017,FALSE,230,0.38,0.26,0.03,0.56,0.00,0.08,0.24),
('22222222-2222-4222-8222-222222222204','Sofia','Clairo',2019,FALSE,215,0.60,0.45,0.04,0.40,0.00,0.11,0.59),

-- ==== TRAP / MELODIC TRAP ====
('33333333-3333-4333-8333-333333333301','The Box','Roddy Ricch',2020,TRUE,231,0.72,0.66,0.40,0.03,0.00,0.12,0.43),
('33333333-3333-4333-8333-333333333302','Goosebumps','Travis Scott',2016,TRUE,251,0.62,0.54,0.31,0.02,0.00,0.10,0.36),
('33333333-3333-4333-8333-333333333303','Rockstar','DaBaby feat. Roddy Ricch',2020,TRUE,181,0.66,0.59,0.33,0.03,0.00,0.15,0.48),
('33333333-3333-4333-8333-333333333304','SICKO MODE','Travis Scott',2018,TRUE,312,0.60,0.85,0.18,0.01,0.00,0.20,0.55),
('33333333-3333-4333-8333-333333333305','Life Is Good','Future & Drake',2020,TRUE,296,0.58,0.65,0.39,0.02,0.00,0.11,0.41),

-- ==== HOUSE (TECH / DEEP) ====
('44444444-4444-4444-8444-444444444401','Innerbloom','RÜFÜS DU SOL',2015,FALSE,1014,0.32,0.45,0.03,0.62,0.12,0.16,0.28),
('44444444-4444-4444-8444-444444444402','Cola','CamelPhat & Elderbrook',2017,FALSE,238,0.75,0.70,0.04,0.08,0.00,0.13,0.54),
('44444444-4444-4444-8444-444444444403','Promises','Calvin Harris & Sam Smith',2018,FALSE,242,0.71,0.68,0.04,0.06,0.00,0.12,0.50),
('44444444-4444-4444-8444-444444444404','Opus','Eric Prydz',2016,FALSE,514,0.48,0.90,0.02,0.01,0.45,0.05,0.44),
('44444444-4444-4444-8444-444444444405','Turn On Me','RÜFÜS DU SOL',2023,FALSE,217,0.68,0.60,0.03,0.20,0.00,0.11,0.42),

-- ==== DRUM & BASS (LIQUID) ====
('55555555-5555-4555-8555-555555555501','Come Alive','Netsky',2012,FALSE,240,0.72,0.78,0.03,0.06,0.05,0.18,0.68),
('55555555-5555-4555-8555-555555555502','Memory Lane','Netsky',2012,FALSE,255,0.70,0.76,0.03,0.08,0.04,0.17,0.64),
('55555555-5555-4555-8555-555555555503','If We Ever','High Contrast',2010,FALSE,210,0.69,0.82,0.03,0.07,0.00,0.19,0.66),
('55555555-5555-4555-8555-555555555504','We Can Only Live Today (Puppy)','Netsky & Brigts',2012,FALSE,195,0.74,0.80,0.03,0.05,0.03,0.16,0.70),

-- ==== ALTERNATIVE ROCK / INDIE ROCK ====
('66666666-6666-4666-8666-666666666601','Mr. Brightside','The Killers',2003,FALSE,222,0.60,0.78,0.04,0.12,0.00,0.14,0.68),
('66666666-6666-4666-8666-666666666602','Do I Wanna Know?','Arctic Monkeys',2013,FALSE,272,0.53,0.70,0.05,0.15,0.00,0.17,0.34),
('66666666-6666-4666-8666-666666666603','Polaroid Storm','Cathedral Kids',2020,FALSE,248,0.58,0.62,0.04,0.32,0.06,0.15,0.60),
('66666666-6666-4666-8666-666666666604','The Less I Know The Better','Tame Impala',2015,FALSE,217,0.64,0.42,0.04,0.28,0.00,0.12,0.55),

-- ==== REGIONAL MEXICAN (CORRIDOS TUMBADOS / SIERREÑO) ====
('77777777-7777-4777-8777-777777777701','Ella Baila Sola','Eslabon Armado & Peso Pluma',2023,FALSE,176,0.46,0.40,0.05,0.58,0.00,0.10,0.42),
('77777777-7777-4777-8777-777777777702','Que Onda','Peso Pluma',2023,TRUE,158,0.48,0.46,0.06,0.55,0.00,0.11,0.44),
('77777777-7777-4777-8777-777777777703','Ella','Eslabon Armado',2021,FALSE,185,0.43,0.38,0.05,0.62,0.00,0.09,0.36),
('77777777-7777-4777-8777-777777777704','Tumbado de Madrugada','Los Crisantemos',2022,TRUE,212,0.48,0.56,0.07,0.58,0.00,0.13,0.49),

-- ==== AMAPIANO (PRIVATE SCHOOL) ====
('88888888-8888-4888-8888-888888888801','Jerusalema','Master KG feat. Nomcebo',2019,FALSE,229,0.78,0.58,0.03,0.20,0.00,0.18,0.85),
('88888888-8888-4888-8888-888888888802','Abalele','Kabza De Small & DJ Maphorisa feat. Ami Faku',2021,FALSE,255,0.82,0.50,0.04,0.22,0.00,0.14,0.79),
('88888888-8888-4888-8888-888888888803','Soweto Baby','DJ Maphorisa & Wizkid',2018,FALSE,198,0.80,0.62,0.04,0.18,0.00,0.16,0.77),
('88888888-8888-4888-8888-888888888804','Umsebenzi','Busta 929 & Mpura',2020,FALSE,210,0.84,0.60,0.04,0.19,0.00,0.17,0.80),

-- ==== CONTEMPORARY R&B ====
('99999999-9999-4999-8999-999999999901','Leave The Door Open','Silk Sonic',2021,FALSE,242,0.47,0.35,0.06,0.50,0.00,0.14,0.60),
('99999999-9999-4999-8999-999999999902','Heartbreak Anniversary','Giveon',2020,FALSE,208,0.39,0.28,0.05,0.60,0.00,0.10,0.30),
('99999999-9999-4999-8999-999999999903','Die For You','The Weeknd',2016,TRUE,240,0.58,0.55,0.05,0.13,0.00,0.12,0.49),
('99999999-9999-4999-8999-999999999904','Slow Motion','Trey Songz',2015,TRUE,306,0.42,0.30,0.06,0.55,0.00,0.16,0.28),

-- ==== COUNTRY POP / BRO-COUNTRY ====
('aaaaaaa1-aaaa-4aaa-8aaa-aaaaaaaaaaa1','Die A Happy Man','Thomas Rhett',2015,FALSE,254,0.36,0.28,0.04,0.66,0.00,0.10,0.85),
('aaaaaaa2-aaaa-4aaa-8aaa-aaaaaaaaaaa2','The Bones','Maren Morris',2019,FALSE,216,0.53,0.60,0.04,0.21,0.00,0.12,0.70),
('aaaaaaa3-aaaa-4aaa-8aaa-aaaaaaaaaaa3','Need You Now','Lady A',2009,FALSE,236,0.62,0.45,0.04,0.40,0.00,0.11,0.58),
('aaaaaaa4-aaaa-4aaa-8aaa-aaaaaaaaaaa4','Body Like A Back Road','Sam Hunt',2017,FALSE,233,0.71,0.38,0.05,0.33,0.00,0.09,0.78),

-- ==== HOUSE (GENERIC CLUB) / ELECTRONIC ====
('bbbbbbb1-bbbb-4bbb-8bbb-bbbbbbbbbbb1','Titanium','David Guetta feat. Sia',2011,FALSE,245,0.62,0.92,0.05,0.02,0.00,0.20,0.66),
('bbbbbbb2-bbbb-4bbb-8bbb-bbbbbbbbbbb2','Animals','Martin Garrix',2013,FALSE,285,0.49,0.98,0.02,0.00,0.65,0.03,0.29),

-- ==== EXTRA K-POP FLAVORS ====
('ccccccc1-cccc-4ccc-8ccc-ccccccccccc1','Candy','Baekhyun',2020,FALSE,192,0.75,0.68,0.04,0.12,0.00,0.11,0.67),
('ccccccc2-cccc-4ccc-8ccc-ccccccccccc2','Runaway','TXT',2019,FALSE,203,0.70,0.60,0.04,0.18,0.00,0.10,0.58),

-- ==== EXTRA INDIE ROCK / ALT ====
('ddddddd1-dddd-4ddd-8ddd-ddddddddddd1','Sit Next to Me','Foster The People',2017,FALSE,207,0.75,0.68,0.04,0.10,0.00,0.12,0.72),
('ddddddd2-dddd-4ddd-8ddd-ddddddddddd2','The Less I Know The Better','Tame Impala',2015,FALSE,217,0.64,0.42,0.04,0.28,0.00,0.12,0.55),

-- ==== EXTRA LIQUID DNB ====
('eeeeeee1-eeee-4eee-8eee-eeeeeeeeeee1','Rio','Netsky',2012,FALSE,243,0.71,0.79,0.03,0.07,0.04,0.17,0.66),
('eeeeeee2-eeee-4eee-8eee-eeeeeeeeeee2','If We Ever','High Contrast',2010,FALSE,210,0.69,0.82,0.03,0.07,0.00,0.19,0.66);

-- ====== K-POP / GIRL-BOY GROUPS ======
INSERT INTO track_genres (track_id, genre_id) VALUES
-- Neon Skyline
('11111111-1111-4111-8111-111111111101','10111213-1415-1617-1819-1a1b1c1d1e01'), -- Girl Group Pop
('11111111-1111-4111-8111-111111111101','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'), -- K-Pop
('11111111-1111-4111-8111-111111111101','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'), -- Pop
('11111111-1111-4111-8111-111111111101','ee55ff66-7788-99aa-bbcc-ddeeff001123'), -- Contemporary R&B (crossover)

-- Sugar Rush Hour
('11111111-1111-4111-8111-111111111102','10111213-1415-1617-1819-1a1b1c1d1e01'),
('11111111-1111-4111-8111-111111111102','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
('11111111-1111-4111-8111-111111111102','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('11111111-1111-4111-8111-111111111102','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'), -- Indie Pop edge

-- Flashcard Love
('11111111-1111-4111-8111-111111111103','20212223-2425-2627-2829-2a2b2c2d2e02'), -- Boy Group Pop
('11111111-1111-4111-8111-111111111103','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
('11111111-1111-4111-8111-111111111103','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('11111111-1111-4111-8111-111111111103','ee55ff66-7788-99aa-bbcc-ddeeff001123'),

-- Mirror, Mirror
('11111111-1111-4111-8111-111111111104','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
('11111111-1111-4111-8111-111111111104','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('11111111-1111-4111-8111-111111111104','10111213-1415-1617-1819-1a1b1c1d1e01'),
('11111111-1111-4111-8111-111111111104','20212223-2425-2627-2829-2a2b2c2d2e02'),

-- Zero Gravity
('11111111-1111-4111-8111-111111111105','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
('11111111-1111-4111-8111-111111111105','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('11111111-1111-4111-8111-111111111105','10111213-1415-1617-1819-1a1b1c1d1e01'),
('11111111-1111-4111-8111-111111111105','ee55ff66-7788-99aa-bbcc-ddeeff001123');

-- ====== INDIE POP / BEDROOM POP ======
INSERT INTO track_genres (track_id, genre_id) VALUES
-- Soft Focus
('22222222-2222-4222-8222-222222222201','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),
('22222222-2222-4222-8222-222222222201','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('22222222-2222-4222-8222-222222222201','30313233-3435-3637-3839-3a3b3c3d3e03'),
('22222222-2222-4222-8222-222222222201','80818283-8485-8687-8889-8a8b8c8d8e08'), -- Indie Rock tint

-- Half-Light
('22222222-2222-4222-8222-222222222202','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),
('22222222-2222-4222-8222-222222222202','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('22222222-2222-4222-8222-222222222202','30313233-3435-3637-3839-3a3b3c3d3e03'),
('22222222-2222-4222-8222-222222222202','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),

-- Faded Posters
('22222222-2222-4222-8222-222222222203','30313233-3435-3637-3839-3a3b3c3d3e03'),
('22222222-2222-4222-8222-222222222203','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),
('22222222-2222-4222-8222-222222222203','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('22222222-2222-4222-8222-222222222203','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),

-- Blue Hoodie Season
('22222222-2222-4222-8222-222222222204','30313233-3435-3637-3839-3a3b3c3d3e03'),
('22222222-2222-4222-8222-222222222204','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),
('22222222-2222-4222-8222-222222222204','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
('22222222-2222-4222-8222-222222222204','80818283-8485-8687-8889-8a8b8c8d8e08');

-- ====== TRAP / MELODIC TRAP ======
INSERT INTO track_genres (track_id, genre_id) VALUES
-- Night Runner
('33333333-3333-4333-8333-333333333301','11aa22bb-33cc-44dd-85ee-66ff77889911'), -- Trap
('33333333-3333-4333-8333-333333333301','d5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02'), -- Hip-Hop/Rap (root)
('33333333-3333-4333-8333-333333333301','40414243-4445-4647-4849-4a4b4c4d4e04'), -- Melodic Trap
('33333333-3333-4333-8333-333333333301','ee55ff66-7788-99aa-bbcc-ddeeff001123'), -- Contemp. R&B crossover

-- Late Texts
('33333333-3333-4333-8333-333333333302','40414243-4445-4647-4849-4a4b4c4d4e04'),
('33333333-3333-4333-8333-333333333302','11aa22bb-33cc-44dd-85ee-66ff77889911'),
('33333333-3333-4333-8333-333333333302','d5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02'),
('33333333-3333-4333-8333-333333333302','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'), -- Pop hooks

-- Driveway Lights
('33333333-3333-4333-8333-333333333303','11aa22bb-33cc-44dd-85ee-66ff77889911'),
('33333333-3333-4333-8333-333333333303','40414243-4445-4647-4849-4a4b4c4d4e04'),
('33333333-3333-4333-8333-333333333303','d5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02'),
('33333333-3333-4333-8333-333333333303','ee55ff66-7788-99aa-bbcc-ddeeff001123'),

-- Pour Up Again
('33333333-3333-4333-8333-333333333304','40414243-4445-4647-4849-4a4b4c4d4e04'),
('33333333-3333-4333-8333-333333333304','11aa22bb-33cc-44dd-85ee-66ff77889911'),
('33333333-3333-4333-8333-333333333304','d5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02'),
('33333333-3333-4333-8333-333333333304','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),

-- VVS Memories
('33333333-3333-4333-8333-333333333305','11aa22bb-33cc-44dd-85ee-66ff77889911'),
('33333333-3333-4333-8333-333333333305','40414243-4445-4647-4849-4a4b4c4d4e04'),
('33333333-3333-4333-8333-333333333305','d5f12e6c-5b2e-4c4e-9d2c-8f2f9c9a7a02'),
('33333333-3333-4333-8333-333333333305','ee55ff66-7788-99aa-bbcc-ddeeff001123');

-- ====== HOUSE / TECH / DEEP ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('44444444-4444-4444-8444-444444444401','50515253-5455-5657-5859-5a5b5c5d5e05'),
                                                  ('44444444-4444-4444-8444-444444444401','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('44444444-4444-4444-8444-444444444401','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'), -- Electronic root
                                                  ('44444444-4444-4444-8444-444444444401','60616263-6465-6667-6869-6a6b6c6d6e06'),

                                                  ('44444444-4444-4444-8444-444444444402','50515253-5455-5657-5859-5a5b5c5d5e05'),
                                                  ('44444444-4444-4444-8444-444444444402','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('44444444-4444-4444-8444-444444444402','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('44444444-4444-4444-8444-444444444402','60616263-6465-6667-6869-6a6b6c6d6e06'),

                                                  ('44444444-4444-4444-8444-444444444403','60616263-6465-6667-6869-6a6b6c6d6e06'),
                                                  ('44444444-4444-4444-8444-444444444403','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('44444444-4444-4444-8444-444444444403','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('44444444-4444-4444-8444-444444444403','50515253-5455-5657-5859-5a5b5c5d5e05'),

                                                  ('44444444-4444-4444-8444-444444444404','60616263-6465-6667-6869-6a6b6c6d6e06'),
                                                  ('44444444-4444-4444-8444-444444444404','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('44444444-4444-4444-8444-444444444404','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('44444444-4444-4444-8444-444444444404','50515253-5455-5657-5859-5a5b5c5d5e05'),

                                                  ('44444444-4444-4444-8444-444444444405','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('44444444-4444-4444-8444-444444444405','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('44444444-4444-4444-8444-444444444405','50515253-5455-5657-5859-5a5b5c5d5e05'),
                                                  ('44444444-4444-4444-8444-444444444405','60616263-6465-6667-6869-6a6b6c6d6e06');

-- ====== DRUM & BASS / LIQUID ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('55555555-5555-4555-8555-555555555501','77aa88bb-99cc-00dd-eeff-11aabbccdd17'),
                                                  ('55555555-5555-4555-8555-555555555501','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('55555555-5555-4555-8555-555555555501','70717273-7475-7677-7879-7a7b7c7d7e07'),
                                                  ('55555555-5555-4555-8555-555555555501','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),

                                                  ('55555555-5555-4555-8555-555555555502','70717273-7475-7677-7879-7a7b7c7d7e07'),
                                                  ('55555555-5555-4555-8555-555555555502','77aa88bb-99cc-00dd-eeff-11aabbccdd17'),
                                                  ('55555555-5555-4555-8555-555555555502','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('55555555-5555-4555-8555-555555555502','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),

                                                  ('55555555-5555-4555-8555-555555555503','77aa88bb-99cc-00dd-eeff-11aabbccdd17'),
                                                  ('55555555-5555-4555-8555-555555555503','70717273-7475-7677-7879-7a7b7c7d7e07'),
                                                  ('55555555-5555-4555-8555-555555555503','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('55555555-5555-4555-8555-555555555503','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),

                                                  ('55555555-5555-4555-8555-555555555504','70717273-7475-7677-7879-7a7b7c7d7e07'),
                                                  ('55555555-5555-4555-8555-555555555504','77aa88bb-99cc-00dd-eeff-11aabbccdd17'),
                                                  ('55555555-5555-4555-8555-555555555504','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('55555555-5555-4555-8555-555555555504','55ee66ff-77aa-88bb-99cc-00ddeeffaa15');

-- ====== ALT / INDIE ROCK ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('66666666-6666-4666-8666-666666666601','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),
                                                  ('66666666-6666-4666-8666-666666666601','a12b34cd-56ef-47ab-9a10-22b33c44dd04'), -- Rock root
                                                  ('66666666-6666-4666-8666-666666666601','80818283-8485-8687-8889-8a8b8c8d8e08'),
                                                  ('66666666-6666-4666-8666-666666666601','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),

                                                  ('66666666-6666-4666-8666-666666666602','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),
                                                  ('66666666-6666-4666-8666-666666666602','a12b34cd-56ef-47ab-9a10-22b33c44dd04'),
                                                  ('66666666-6666-4666-8666-666666666602','80818283-8485-8687-8889-8a8b8c8d8e08'),
                                                  ('66666666-6666-4666-8666-666666666602','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),

                                                  ('66666666-6666-4666-8666-666666666603','80818283-8485-8687-8889-8a8b8c8d8e08'),
                                                  ('66666666-6666-4666-8666-666666666603','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),
                                                  ('66666666-6666-4666-8666-666666666603','a12b34cd-56ef-47ab-9a10-22b33c44dd04'),
                                                  ('66666666-6666-4666-8666-666666666603','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),

                                                  ('66666666-6666-4666-8666-666666666604','80818283-8485-8687-8889-8a8b8c8d8e08'),
                                                  ('66666666-6666-4666-8666-666666666604','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),
                                                  ('66666666-6666-4666-8666-666666666604','a12b34cd-56ef-47ab-9a10-22b33c44dd04'),
                                                  ('66666666-6666-4666-8666-666666666604','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1');

-- ====== REGIONAL MEXICAN ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('77777777-7777-4777-8777-777777777701','bb22cc33-dd44-ee55-ff66-778899aabb20'),
                                                  ('77777777-7777-4777-8777-777777777701','5f4e3d2c-1b0a-49a8-8f7e-6d5c4b3a2a05'), -- Latin root
                                                  ('77777777-7777-4777-8777-777777777701','90919293-9495-9697-9899-9a9b9c9d9e09'),
                                                  ('77777777-7777-4777-8777-777777777701','a0a1a2a3-a4a5-a6a7-a8a9-aaabacadae0a'),

                                                  ('77777777-7777-4777-8777-777777777702','a0a1a2a3-a4a5-a6a7-a8a9-aaabacadae0a'),
                                                  ('77777777-7777-4777-8777-777777777702','bb22cc33-dd44-ee55-ff66-778899aabb20'),
                                                  ('77777777-7777-4777-8777-777777777702','5f4e3d2c-1b0a-49a8-8f7e-6d5c4b3a2a05'),
                                                  ('77777777-7777-4777-8777-777777777702','90919293-9495-9697-9899-9a9b9c9d9e09'),

                                                  ('77777777-7777-4777-8777-777777777703','90919293-9495-9697-9899-9a9b9c9d9e09'),
                                                  ('77777777-7777-4777-8777-777777777703','bb22cc33-dd44-ee55-ff66-778899aabb20'),
                                                  ('77777777-7777-4777-8777-777777777703','5f4e3d2c-1b0a-49a8-8f7e-6d5c4b3a2a05'),
                                                  ('77777777-7777-4777-8777-777777777703','a0a1a2a3-a4a5-a6a7-a8a9-aaabacadae0a'),

                                                  ('77777777-7777-4777-8777-777777777704','90919293-9495-9697-9899-9a9b9c9d9e09'),
                                                  ('77777777-7777-4777-8777-777777777704','bb22cc33-dd44-ee55-ff66-778899aabb20'),
                                                  ('77777777-7777-4777-8777-777777777704','5f4e3d2c-1b0a-49a8-8f7e-6d5c4b3a2a05'),
                                                  ('77777777-7777-4777-8777-777777777704','a0a1a2a3-a4a5-a6a7-a8a9-aaabacadae0a');

-- ====== AMAPIANO / PRIVATE SCHOOL ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('88888888-8888-4888-8888-888888888801','b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0'), -- Private School
                                                  ('88888888-8888-4888-8888-888888888801','dd44ee55-ff66-7788-99aa-bbccddeeff22'), -- Amapiano
                                                  ('88888888-8888-4888-8888-888888888801','b7c6a5d4-e3f2-4b1a-8c9d-0e1f2a3b4c06'), -- Afrobeats root
                                                  ('88888888-8888-4888-8888-888888888801','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'), -- House crossover

                                                  ('88888888-8888-4888-8888-888888888802','b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0'),
                                                  ('88888888-8888-4888-8888-888888888802','dd44ee55-ff66-7788-99aa-bbccddeeff22'),
                                                  ('88888888-8888-4888-8888-888888888802','b7c6a5d4-e3f2-4b1a-8c9d-0e1f2a3b4c06'),
                                                  ('88888888-8888-4888-8888-888888888802','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),

                                                  ('88888888-8888-4888-8888-888888888803','b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0'),
                                                  ('88888888-8888-4888-8888-888888888803','dd44ee55-ff66-7788-99aa-bbccddeeff22'),
                                                  ('88888888-8888-4888-8888-888888888803','b7c6a5d4-e3f2-4b1a-8c9d-0e1f2a3b4c06'),
                                                  ('88888888-8888-4888-8888-888888888803','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),

                                                  ('88888888-8888-4888-8888-888888888804','dd44ee55-ff66-7788-99aa-bbccddeeff22'),
                                                  ('88888888-8888-4888-8888-888888888804','b0b1b2b3-b4b5-b6b7-b8b9-babbbcbdbeb0'),
                                                  ('88888888-8888-4888-8888-888888888804','b7c6a5d4-e3f2-4b1a-8c9d-0e1f2a3b4c06'),
                                                  ('88888888-8888-4888-8888-888888888804','55ee66ff-77aa-88bb-99cc-00ddeeffaa15');

-- ====== CONTEMPORARY R&B ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('99999999-9999-4999-8999-999999999901','ee55ff66-7788-99aa-bbcc-ddeeff001123'),
                                                  ('99999999-9999-4999-8999-999999999901','90ab12cd-34ef-45a6-9b78-cd12ef34ab07'), -- R&B/Soul root
                                                  ('99999999-9999-4999-8999-999999999901','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'), -- Pop crossover
                                                  ('99999999-9999-4999-8999-999999999901','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'), -- Indie Pop tint

                                                  ('99999999-9999-4999-8999-999999999902','ee55ff66-7788-99aa-bbcc-ddeeff001123'),
                                                  ('99999999-9999-4999-8999-999999999902','90ab12cd-34ef-45a6-9b78-cd12ef34ab07'),
                                                  ('99999999-9999-4999-8999-999999999902','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
                                                  ('99999999-9999-4999-8999-999999999902','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),

                                                  ('99999999-9999-4999-8999-999999999903','ee55ff66-7788-99aa-bbcc-ddeeff001123'),
                                                  ('99999999-9999-4999-8999-999999999903','90ab12cd-34ef-45a6-9b78-cd12ef34ab07'),
                                                  ('99999999-9999-4999-8999-999999999903','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
                                                  ('99999999-9999-4999-8999-999999999903','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),

                                                  ('99999999-9999-4999-8999-999999999904','ee55ff66-7788-99aa-bbcc-ddeeff001123'),
                                                  ('99999999-9999-4999-8999-999999999904','90ab12cd-34ef-45a6-9b78-cd12ef34ab07'),
                                                  ('99999999-9999-4999-8999-999999999904','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
                                                  ('99999999-9999-4999-8999-999999999904','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1');

-- ====== COUNTRY POP / BRO-COUNTRY ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('aaaaaaa1-aaaa-4aaa-8aaa-aaaaaaaaaaa1','ff667788-99aa-bbcc-ddee-ff0011223344'),
                                                  ('aaaaaaa1-aaaa-4aaa-8aaa-aaaaaaaaaaa1','6e5d4c3b-2a1f-40e9-8d7c-5b4a3c2d1e08'), -- Country root
                                                  ('aaaaaaa1-aaaa-4aaa-8aaa-aaaaaaaaaaa1','c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c'),
                                                  ('aaaaaaa1-aaaa-4aaa-8aaa-aaaaaaaaaaa1','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),

                                                  ('aaaaaaa2-aaaa-4aaa-8aaa-aaaaaaaaaaa2','ff667788-99aa-bbcc-ddee-ff0011223344'),
                                                  ('aaaaaaa2-aaaa-4aaa-8aaa-aaaaaaaaaaa2','6e5d4c3b-2a1f-40e9-8d7c-5b4a3c2d1e08'),
                                                  ('aaaaaaa2-aaaa-4aaa-8aaa-aaaaaaaaaaa2','c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c'),
                                                  ('aaaaaaa2-aaaa-4aaa-8aaa-aaaaaaaaaaa2','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),

                                                  ('aaaaaaa3-aaaa-4aaa-8aaa-aaaaaaaaaaa3','c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c'),
                                                  ('aaaaaaa3-aaaa-4aaa-8aaa-aaaaaaaaaaa3','6e5d4c3b-2a1f-40e9-8d7c-5b4a3c2d1e08'),
                                                  ('aaaaaaa3-aaaa-4aaa-8aaa-aaaaaaaaaaa3','ff667788-99aa-bbcc-ddee-ff0011223344'),
                                                  ('aaaaaaa3-aaaa-4aaa-8aaa-aaaaaaaaaaa3','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),

                                                  ('aaaaaaa4-aaaa-4aaa-8aaa-aaaaaaaaaaa4','ff667788-99aa-bbcc-ddee-ff0011223344'),
                                                  ('aaaaaaa4-aaaa-4aaa-8aaa-aaaaaaaaaaa4','6e5d4c3b-2a1f-40e9-8d7c-5b4a3c2d1e08'),
                                                  ('aaaaaaa4-aaaa-4aaa-8aaa-aaaaaaaaaaa4','c0c1c2c3-c4c5-c6c7-c8c9-cacbcccdce0c'),
                                                  ('aaaaaaa4-aaaa-4aaa-8aaa-aaaaaaaaaaa4','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01');

-- ====== EXTRA HOUSE (GENERIC CLUB) ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('bbbbbbb1-bbbb-4bbb-8bbb-bbbbbbbbbbb1','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('bbbbbbb1-bbbb-4bbb-8bbb-bbbbbbbbbbb1','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('bbbbbbb1-bbbb-4bbb-8bbb-bbbbbbbbbbb1','50515253-5455-5657-5859-5a5b5c5d5e05'),
                                                  ('bbbbbbb1-bbbb-4bbb-8bbb-bbbbbbbbbbb1','60616263-6465-6667-6869-6a6b6c6d6e06'),

                                                  ('bbbbbbb2-bbbb-4bbb-8bbb-bbbbbbbbbbb2','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),
                                                  ('bbbbbbb2-bbbb-4bbb-8bbb-bbbbbbbbbbb2','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('bbbbbbb2-bbbb-4bbb-8bbb-bbbbbbbbbbb2','50515253-5455-5657-5859-5a5b5c5d5e05'),
                                                  ('bbbbbbb2-bbbb-4bbb-8bbb-bbbbbbbbbbb2','60616263-6465-6667-6869-6a6b6c6d6e06');

-- ====== EXTRA K-POP ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('ccccccc1-cccc-4ccc-8ccc-ccccccccccc1','10111213-1415-1617-1819-1a1b1c1d1e01'),
                                                  ('ccccccc1-cccc-4ccc-8ccc-ccccccccccc1','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
                                                  ('ccccccc1-cccc-4ccc-8ccc-ccccccccccc1','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
                                                  ('ccccccc1-cccc-4ccc-8ccc-ccccccccccc1','ee55ff66-7788-99aa-bbcc-ddeeff001123'),

                                                  ('ccccccc2-cccc-4ccc-8ccc-ccccccccccc2','20212223-2425-2627-2829-2a2b2c2d2e02'),
                                                  ('ccccccc2-cccc-4ccc-8ccc-ccccccccccc2','f1a2b3c4-d5e6-47f8-9a01-b2c3d4e5f109'),
                                                  ('ccccccc2-cccc-4ccc-8ccc-ccccccccccc2','8a3e7b7e-2e6c-4f7a-9e9d-0b1c8a5f1a01'),
                                                  ('ccccccc2-cccc-4ccc-8ccc-ccccccccccc2','ee55ff66-7788-99aa-bbcc-ddeeff001123');

-- ====== EXTRA INDIE ROCK / ALT ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('ddddddd1-dddd-4ddd-8ddd-ddddddddddd1','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),
                                                  ('ddddddd1-dddd-4ddd-8ddd-ddddddddddd1','a12b34cd-56ef-47ab-9a10-22b33c44dd04'),
                                                  ('ddddddd1-dddd-4ddd-8ddd-ddddddddddd1','80818283-8485-8687-8889-8a8b8c8d8e08'),
                                                  ('ddddddd1-dddd-4ddd-8ddd-ddddddddddd1','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1'),

                                                  ('ddddddd2-dddd-4ddd-8ddd-ddddddddddd2','80818283-8485-8687-8889-8a8b8c8d8e08'),
                                                  ('ddddddd2-dddd-4ddd-8ddd-ddddddddddd2','88bb99cc-00dd-eeff-11aa-bbccddeeff18'),
                                                  ('ddddddd2-dddd-4ddd-8ddd-ddddddddddd2','a12b34cd-56ef-47ab-9a10-22b33c44dd04'),
                                                  ('ddddddd2-dddd-4ddd-8ddd-ddddddddddd2','0a1b2c3d-4e5f-46a7-8b90-a1b2c3d4e5f1');

-- ====== EXTRA LIQUID DNB ======
INSERT INTO track_genres (track_id, genre_id) VALUES
                                                  ('eeeeeee1-eeee-4eee-8eee-eeeeeeeeeee1','70717273-7475-7677-7879-7a7b7c7d7e07'),
                                                  ('eeeeeee1-eeee-4eee-8eee-eeeeeeeeeee1','77aa88bb-99cc-00dd-eeff-11aabbccdd17'),
                                                  ('eeeeeee1-eeee-4eee-8eee-eeeeeeeeeee1','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('eeeeeee1-eeee-4eee-8eee-eeeeeeeeeee1','55ee66ff-77aa-88bb-99cc-00ddeeffaa15'),

                                                  ('eeeeeee2-eeee-4eee-8eee-eeeeeeeeeee2','77aa88bb-99cc-00dd-eeff-11aabbccdd17'),
                                                  ('eeeeeee2-eeee-4eee-8eee-eeeeeeeeeee2','70717273-7475-7677-7879-7a7b7c7d7e07'),
                                                  ('eeeeeee2-eeee-4eee-8eee-eeeeeeeeeee2','3c6a9d21-0c3f-4f4a-9f31-8e1c5c5f3a03'),
                                                  ('eeeeeee2-eeee-4eee-8eee-eeeeeeeeeee2','55ee66ff-77aa-88bb-99cc-00ddeeffaa15');
