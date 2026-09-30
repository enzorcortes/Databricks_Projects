-- ============================================================================
-- MOVIES ON STREAMING PLATFORMS — GENIE SPACE
-- ============================================================================
-- The Genie Space is created in the Databricks UI or via the createAsset API.
-- This file documents the Genie Space configuration and the instructions
-- to paste into the Genie Space settings for best natural language results.
-- ============================================================================


-- ============================================================================
-- GENIE SPACE CONFIGURATION
-- ============================================================================
-- Name: Movies on Streaming Platforms - Genie
-- ID:   01f1bb9219541440ae851b68b9eeacd6
--
-- Tables registered in the Genie Space:
--   1. workspace.default.movies_on_streaming_platforms  (cleaned base table)
--   2. workspace.default.v_platform_summary              (movie count & avg score per platform)
--   3. workspace.default.v_movies_by_year                (movie count & avg RT score by year)
--   4. workspace.default.v_age_rating_distribution       (movie count by age rating per platform)
--   5. workspace.default.v_top_rated_movies              (top 100 highest-rated movies)


-- ============================================================================
-- GENIE SPACE INSTRUCTIONS
-- ============================================================================
-- Paste the text below into the Genie Space's Instructions field
-- (Genie Space > Settings > Instructions).

/*
This Genie Space covers movies available on streaming platforms
(Netflix, Hulu, Prime Video, Disney+).

Key definitions:
- 'on_netflix', 'on_hulu', 'on_prime_video', 'on_disney_plus' are
  boolean columns indicating availability on that platform.
- 'rotten_tomatoes_score' is a 0-100 integer rating.
- 'age_rating' values: '7+', '13+', '16+', '18+', 'All Ages', or NULL.
- 'content_type': 0 = movie, 1 = TV show (all rows are movies in this dataset).
- When a user asks 'best movies', sort by rotten_tomatoes_score DESC.
- When a user asks 'how many on X', count WHERE on_<platform> = true.

Registered tables:
- movies_on_streaming_platforms: the main cleaned table with all movie details.
- v_platform_summary: pre-aggregated movie count and average RT score per platform.
- v_movies_by_year: pre-aggregated movie count and average RT score by release year.
- v_age_rating_distribution: movie count by age rating, split by platform.
- v_top_rated_movies: top 100 highest-rated movies with platform availability flags.
*/


-- ============================================================================
-- EXAMPLE QUESTIONS THE GENIE SPACE CAN ANSWER
-- ============================================================================
/*
- "How many movies are on Netflix?"
- "What is the average Rotten Tomatoes score for Disney+ movies?"
- "Show me top-rated movies from 2020 available on Hulu"
- "Which platform has the most movies rated 18+?"
- "How many movies were released in 2019?"
- "What is the highest rated movie on Prime Video?"
*/