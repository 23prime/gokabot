-- Test seed data for integration tests
-- Run: psql $DATABASE_URL -f db/seeds/test.sql

TRUNCATE gokabot.animes, gokabot.cities, gokabot.gokabous RESTART IDENTITY;

-- =============================================================================
-- Cities (Weather answerer)
-- =============================================================================
-- Weather answerer searches by `name` OR `jp_name`
-- Default city is '東京'

INSERT INTO gokabot.cities (id, name, jp_name) VALUES
-- Tokyo: default city, searchable by both 'tokyo' and '東京'
(1850147, 'tokyo', '東京'),
-- Osaka: another major city
(1853909, 'osaka', '大阪'),
-- Tsukuba: test duplicate English name with different jp_name
(2110683, 'tsukuba', '筑波'),
(2110681, 'tsukuba', 'つくば'),
-- Kofu: test city with NULL jp_name (search by English name only)
(1859100, 'kofu', NULL),
-- Sapporo: test hiragana search
(2128295, 'sapporo', 'さっぽろ');

-- =============================================================================
-- Animes (Anime answerer)
-- =============================================================================
-- Season: winter (Jan-Mar), spring (Apr-Jun), summer (Jul-Sep), fall (Oct-Dec)
-- Day: Sun, Mon, Tue, Wed, Thu, Fri, Sat
-- Time: 24-hour format like '24:00', '25:30' (late night = next day early morning)
--
-- Test cases:
--   1. 今期のアニメ -> all animes in current season (2026 winter)
--   2. 今期のおすすめ -> recommend=true in current season
--   3. 来期のアニメ -> all animes in next season (2026 spring)
--   4. 月曜のアニメ -> animes on specific day
--   5. 月曜のおすすめ -> recommend=true on specific day
--   6. Empty result -> returns error message

INSERT INTO gokabot.animes (year, season, day, time, station, title, recommend) VALUES
-- 2026 Winter (current season) - Multiple days, mixed recommend
-- Monday
(2026, 'winter', 'Mon', '23:00', 'TOKYO MX', 'Winter Anime A', true),
(2026, 'winter', 'Mon', '24:00', 'BS11', 'Winter Anime B', false),
(2026, 'winter', 'Mon', '25:30', 'AT-X', 'Winter Anime C', true),
-- Tuesday
(2026, 'winter', 'Tue', '22:00', 'TOKYO MX', 'Winter Anime D', false),
(2026, 'winter', 'Tue', '24:30', 'TBS', 'Winter Anime E', true),
-- Wednesday
(2026, 'winter', 'Wed', '23:30', 'Fuji TV', 'Winter Anime F', false),
-- Thursday (no recommend)
(2026, 'winter', 'Thu', '21:00', 'NHK', 'Winter Anime G', false),
-- Friday
(2026, 'winter', 'Fri', '25:00', 'TOKYO MX', 'Winter Anime H', true),
-- Saturday (multiple for sort test)
(2026, 'winter', 'Sat', '24:00', 'TOKYO MX', 'Winter Anime I', true),
(2026, 'winter', 'Sat', '22:00', 'BS11', 'Winter Anime J', false),
(2026, 'winter', 'Sat', '26:00', 'AT-X', 'Winter Anime K', true),
-- Sunday
(2026, 'winter', 'Sun', '17:00', 'TBS', 'Winter Anime L', false),

-- 2026 Spring (next season) - Fewer entries to differentiate from winter
(2026, 'spring', 'Mon', '23:00', 'TOKYO MX', 'Spring Anime A', true),
(2026, 'spring', 'Wed', '24:00', 'BS11', 'Spring Anime B', false),
(2026, 'spring', 'Fri', '25:00', 'AT-X', 'Spring Anime C', true),

-- 2025 Fall (previous season) - Should NOT appear in current/next queries
(2025, 'fall', 'Mon', '23:00', 'TOKYO MX', 'Old Anime', true);

-- =============================================================================
-- Gokabous (Gokabou answerer - Markov chain)
-- =============================================================================
-- Markov chain needs multiple sentences with overlapping words to create chains
-- Format: 3-gram blocks like [word1, word2, word3]
-- Sentences should share some words to enable chain connections

INSERT INTO gokabot.gokabous (reg_date, sentence) VALUES
-- Basic sentences for Markov chain
('2026-01-01', '今日はいい天気ですね'),
('2026-01-02', '天気がいいので散歩します'),
('2026-01-03', '散歩は健康にいいですよ'),
('2026-01-04', '健康のために運動しましょう'),
('2026-01-05', '運動した後はご飯が美味しい'),
('2026-01-06', 'ご飯を食べたら眠くなる'),
('2026-01-07', '眠いけど仕事があるから頑張る'),
('2026-01-08', '仕事が終わったらゲームしよう'),
('2026-01-09', 'ゲームは楽しいですね'),
('2026-01-10', '楽しい時間はあっという間'),
-- Longer sentences for better chains
('2026-01-11', 'プログラミングは楽しいけど難しいこともある'),
('2026-01-12', '難しい問題を解けると嬉しい'),
('2026-01-13', '嬉しいことがあると一日中幸せ'),
('2026-01-14', '幸せな気分で過ごしたい'),
('2026-01-15', '過ごしやすい季節になってきた');
