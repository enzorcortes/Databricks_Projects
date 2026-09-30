-- ============================================================================
-- MOVIES ON STREAMING PLATFORMS — UNITY CATALOG GOVERNANCE (RBAC)
-- ============================================================================
-- Governs access to the movies streaming datasets via:
--   1. Governed tags for data classification
--   2. GRANT statements for role-based access (data_engineers, data_analysts, business_viewers)
--   3. Row-level security via row filter functions
--   4. Column-level masking via mask functions
--
-- NOTE: Some statements (CREATE FUNCTION, SET ROW FILTER, SET MASK) require
-- MANAGE privilege on the table or schema ownership. Governed tag creation
-- requires account admin, which may not be available on Free Edition.
-- ============================================================================


-- ============================================================================
-- 1. GOVERNED TAGS (DATA CLASSIFICATION)
-- ============================================================================

-- Create governed tags (requires account admin)
/*
CREATE TAG IF NOT EXISTS content_rating;
CREATE TAG IF NOT EXISTS quality_score;
*/

-- Apply tags to columns
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN rotten_tomatoes_score SET TAGS ('quality_score');

ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN age_rating SET TAGS ('content_rating');


-- ============================================================================
-- 2. ROLE-BASED GRANT STATEMENTS
-- ============================================================================
-- Privileges are granted to users/groups directly (no CREATE ROLE needed).

-- Role: Data Engineer / Admin
--   Full access: create tables, modify data, manage permissions
GRANT USE SCHEMA   ON SCHEMA workspace.default TO `data_engineers`;
GRANT USE CATALOG  ON CATALOG workspace         TO `data_engineers`;
GRANT SELECT, MODIFY ON ALL TABLES  IN SCHEMA workspace.default TO `data_engineers`;
GRANT SELECT        ON ALL VIEWS   IN SCHEMA workspace.default TO `data_engineers`;
GRANT CREATE TABLE  ON SCHEMA workspace.default TO `data_engineers`;
GRANT CREATE FUNCTION ON SCHEMA workspace.default TO `data_engineers`;

-- Role: Data Analyst
--   Read access to all tables and views (can see all data)
GRANT USE SCHEMA  ON SCHEMA workspace.default TO `data_analysts`;
GRANT USE CATALOG ON CATALOG workspace        TO `data_analysts`;
GRANT SELECT ON ALL TABLES IN SCHEMA workspace.default TO `data_analysts`;
GRANT SELECT ON ALL VIEWS  IN SCHEMA workspace.default TO `data_analysts`;

-- Role: Business Viewer (restricted)
--   Read access to views only, not raw tables.
--   Row-level security and column masks applied below restrict what
--   they can actually see.
GRANT USE SCHEMA  ON SCHEMA workspace.default TO `business_viewers`;
GRANT USE CATALOG ON CATALOG workspace        TO `business_viewers`;
GRANT SELECT ON VIEW  workspace.default.v_platform_summary          TO `business_viewers`;
GRANT SELECT ON VIEW  workspace.default.v_movies_by_year            TO `business_viewers`;
GRANT SELECT ON VIEW  workspace.default.v_age_rating_distribution   TO `business_viewers`;
GRANT SELECT ON VIEW  workspace.default.v_top_rated_movies           TO `business_viewers`;

-- Note: To grant on the cleaned table with row filters/masks applied:
-- GRANT SELECT ON TABLE workspace.default.movies_on_streaming_platforms TO `business_viewers`;


-- ============================================================================
-- 3. ROW-LEVEL SECURITY (ROW FILTER FUNCTIONS)
-- ============================================================================
-- Business viewers can only see movies rated 'All Ages' and '7+'
-- (family-friendly content). Analysts and engineers see everything.

CREATE OR REPLACE FUNCTION workspace.default.rf_age_rating_filter(
  age_rating_col STRING
) RETURNS BOOLEAN
COMMENT 'Row filter: restricts rows by age rating. Returns TRUE for authorized users.'
LANGUAGE SQL
RETURN
  -- If the current user is in an analyst/engineer group, show everything
  is_member('data_analysts')
  OR is_member('data_engineers')
  -- Business viewers only see family-friendly content
  OR (is_member('business_viewers')
      AND age_rating_col IN ('All Ages', '7+'));

-- Apply the row filter to the cleaned table
ALTER TABLE workspace.default.movies_on_streaming_platforms
  SET ROW FILTER workspace.default.rf_age_rating_filter(age_rating);

-- To remove the row filter later:
-- ALTER TABLE workspace.default.movies_on_streaming_platforms DROP ROW FILTER;


-- ============================================================================
-- 4. COLUMN-LEVEL MASKING (MASK FUNCTIONS)
-- ============================================================================
-- Business viewers see NULL for Rotten Tomatoes scores
-- (the score is considered sensitive/internal).
-- Analysts and engineers see the real value.

CREATE OR REPLACE FUNCTION workspace.default.mask_rt_score(
  score_col INT
) RETURNS INT
COMMENT 'Column mask: hides Rotten Tomatoes score for business_viewers.'
LANGUAGE SQL
RETURN
  CASE
    WHEN is_member('data_analysts')  THEN score_col
    WHEN is_member('data_engineers') THEN score_col
    ELSE NULL  -- business_viewers and others see NULL
  END;

-- Apply the column mask to the cleaned table
ALTER TABLE workspace.default.movies_on_streaming_platforms
  ALTER COLUMN rotten_tomatoes_score SET MASK workspace.default.mask_rt_score;

-- To remove the column mask later:
-- ALTER TABLE workspace.default.movies_on_streaming_platforms
--   ALTER COLUMN rotten_tomatoes_score DROP MASK;


-- ============================================================================
-- 5. VIEW-LEVEL SECURITY NOTE
-- ============================================================================
-- Views in Unity Catalog inherit the underlying table's row filters and
-- column masks. So v_top_rated_movies will automatically respect the
-- age_rating row filter and RT score column mask applied to the base table.
--
-- This means business_viewers querying v_top_rated_movies will:
--   - Only see movies with age_rating IN ('All Ages', '7+')
--   - See NULL for rotten_tomatoes_score
--
-- The v_platform_summary and v_movies_by_year views use aggregations
-- (COUNT, AVG) — these also respect row filters, so business_viewers
-- will see counts/averages computed only over the rows they can access.