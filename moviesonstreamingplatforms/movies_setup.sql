-- ============================================================================
-- MOVIES ON STREAMING PLATFORMS — DATA SETUP
-- ============================================================================
-- Tables and views for the Movies on Streaming Platforms project.
-- Run in order: raw table → cleaned table → column comments → views.
-- ============================================================================


-- ============================================================================
-- 1. RAW TABLE (from CSV upload)
-- ============================================================================
-- The CSV was loaded via Databricks file upload into a UC table.
-- Equivalent SQL if loading from a volume or external location:

/*
CREATE OR REPLACE TABLE workspace.default.movies_on_streaming_platforms_raw
COMMENT 'Raw ingest of MoviesOnStreamingPlatforms.csv'
AS
SELECT
  _c0 AS row_index,
  ID,
  Title,
  Year,
  Age,
  `Rotten Tomatoes`,
  Netflix,
  Hulu,
  `Prime Video`,
  `Disney+`,
  Type
FROM read_files(
  '/Volumes/workspace/default/<volume>/MoviesOnStreamingPlatforms.csv',
  format => 'csv',
  header => true
);
*/

-- Raw table columns (uncleaned types):
--   ID (int), Title (string), Year (int), Age (string),
--   Rotten Tomatoes (string, e.g. '98/100'),
--   Netflix (int 0/1), Hulu (int 0/1), Prime Video (int 0/1),
--   Disney+ (int 0/1), Type (int 0/1)


-- ============================================================================
-- 2. CLEANED TABLE
-- ============================================================================
-- Proper types: booleans for streaming flags, integer RT score,
-- snake_case column names, column comments for Genie metadata.

CREATE OR REPLACE TABLE workspace.default.movies_on_streaming_platforms
COMMENT 'Cleaned movies on streaming platforms dataset. Source: MoviesOnStreamingPlatforms.csv'
AS
SELECT
  ID               AS movie_id,
  Title            AS title,
  Year             AS release_year,
  CASE
    WHEN Age = 'all' THEN 'All Ages'
    WHEN Age IS NULL THEN NULL
    ELSE Age
  END              AS age_rating,
  CAST(SPLIT(`Rotten Tomatoes`, '/')[0] AS INT) AS rotten_tomatoes_score,
  CAST(Netflix     AS BOOLEAN) AS on_netflix,
  CAST(Hulu        AS BOOLEAN) AS on_hulu,
  CAST(`Prime Video` AS BOOLEAN) AS on_prime_video,
  CAST(`Disney+`   AS BOOLEAN) AS on_disney_plus,
  Type             AS content_type   -- 0 = movie, 1 = TV show
FROM workspace.default.movies_on_streaming_platforms_raw;

-- Column comments (Genie uses these for natural language understanding)
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN movie_id              COMMENT 'Unique movie identifier';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN title                 COMMENT 'Movie title';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN release_year          COMMENT 'Year of release';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN age_rating            COMMENT 'Age rating: 7+, 13+, 16+, 18+, All Ages, or NULL';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN rotten_tomatoes_score COMMENT 'Rotten Tomatoes score (0-100)';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN on_netflix           COMMENT 'Available on Netflix (true/false)';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN on_hulu              COMMENT 'Available on Hulu (true/false)';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN on_prime_video       COMMENT 'Available on Prime Video (true/false)';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN on_disney_plus       COMMENT 'Available on Disney+ (true/false)';
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN content_type         COMMENT 'Content type: 0 = movie, 1 = TV show';


-- ============================================================================
-- 3. ANALYTICAL VIEWS
-- ============================================================================
-- These views power the AI/BI Dashboard widgets and provide
-- pre-aggregated datasets for Genie natural language queries.

-- View 3.1: Platform summary (movie count & avg score per platform)
CREATE OR REPLACE VIEW workspace.default.v_platform_summary
COMMENT 'Summary of movie counts and average scores by streaming platform'
AS
SELECT 'Netflix'     AS platform, COUNT(*) AS movie_count, AVG(rotten_tomatoes_score) AS avg_score
  FROM workspace.default.movies_on_streaming_platforms WHERE on_netflix
UNION ALL
SELECT 'Hulu',        COUNT(*), AVG(rotten_tomatoes_score)
  FROM workspace.default.movies_on_streaming_platforms WHERE on_hulu
UNION ALL
SELECT 'Prime Video', COUNT(*), AVG(rotten_tomatoes_score)
  FROM workspace.default.movies_on_streaming_platforms WHERE on_prime_video
UNION ALL
SELECT 'Disney+',     COUNT(*), AVG(rotten_tomatoes_score)
  FROM workspace.default.movies_on_streaming_platforms WHERE on_disney_plus;

-- View 3.2: Movies by release year
CREATE OR REPLACE VIEW workspace.default.v_movies_by_year
COMMENT 'Movie count and average Rotten Tomatoes score by release year'
AS
SELECT
  release_year,
  COUNT(*) AS movie_count,
  ROUND(AVG(rotten_tomatoes_score), 1) AS avg_rt_score
FROM workspace.default.movies_on_streaming_platforms
GROUP BY release_year
ORDER BY release_year;

-- View 3.3: Age rating distribution across platforms
CREATE OR REPLACE VIEW workspace.default.v_age_rating_distribution
COMMENT 'Movie count by age rating across platforms'
AS
SELECT
  COALESCE(age_rating, 'Unrated') AS age_rating,
  SUM(CAST(on_netflix      AS INT)) AS netflix_count,
  SUM(CAST(on_hulu         AS INT)) AS hulu_count,
  SUM(CAST(on_prime_video  AS INT)) AS prime_video_count,
  SUM(CAST(on_disney_plus  AS INT)) AS disney_plus_count,
  COUNT(*)                    AS total_count
FROM workspace.default.movies_on_streaming_platforms
GROUP BY age_rating
ORDER BY total_count DESC;

-- View 3.4: Top 100 rated movies with platform availability
CREATE OR REPLACE VIEW workspace.default.v_top_rated_movies
COMMENT 'Top 100 highest-rated movies with streaming platform availability'
AS
SELECT
  title,
  release_year,
  age_rating,
  rotten_tomatoes_score,
  on_netflix,
  on_hulu,
  on_prime_video,
  on_disney_plus
FROM workspace.default.movies_on_streaming_platforms
WHERE rotten_tomatoes_score IS NOT NULL
ORDER BY rotten_tomatoes_score DESC
LIMIT 100;