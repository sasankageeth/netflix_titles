/* ============================================================
   NETFLIX DATA CLEANING PROJECT
   Working Table: netflix_staging

   Cleaning Steps:
   1. Check missing values
   2. Convert blank values to NULL
   3. Fill missing ratings
   4. Fix data types
   5. Drop unnecessary columns
   6. Create final cleaned table
   ============================================================ */


-- ============================================================
-- STEP 1: VIEW RAW STAGING DATA
-- ============================================================

SELECT *
FROM netflix_staging;


-- ============================================================
-- STEP 2: CHECK MISSING VALUES
-- Purpose:
-- Count NULL and blank values in important columns.
-- ============================================================

SELECT
    SUM(CASE WHEN director IS NULL OR director = '' THEN 1 ELSE 0 END) AS director_missing,
    SUM(CASE WHEN m_s_cast IS NULL OR m_s_cast = '' THEN 1 ELSE 0 END) AS cast_missing,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS country_missing,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_missing,
    SUM(CASE WHEN rating IS NULL OR rating = '' THEN 1 ELSE 0 END) AS rating_missing,
    SUM(CASE WHEN duration IS NULL OR duration = '' THEN 1 ELSE 0 END) AS duration_missing
FROM netflix_staging;


-- ============================================================
-- STEP 3: CONVERT BLANK VALUES TO NULL
-- Purpose:
-- Standardize missing values so blanks are stored as NULL.
-- ============================================================

UPDATE netflix_staging
SET director = NULL
WHERE director = '';

UPDATE netflix_staging
SET m_s_cast = NULL
WHERE m_s_cast = '';

UPDATE netflix_staging
SET rating = NULL
WHERE rating = '';


-- ============================================================
-- STEP 4: VERIFY BLANK TO NULL CONVERSION
-- ============================================================

SELECT
    SUM(CASE WHEN director = '' THEN 1 ELSE 0 END) AS director_blank,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_null,
    SUM(CASE WHEN m_s_cast = '' THEN 1 ELSE 0 END) AS cast_blank,
    SUM(CASE WHEN m_s_cast IS NULL THEN 1 ELSE 0 END) AS cast_null,
    SUM(CASE WHEN rating = '' THEN 1 ELSE 0 END) AS rating_blank,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_null
FROM netflix_staging;


-- ============================================================
-- STEP 5: FILL MISSING RATING VALUES
-- Purpose:
-- Manually update missing ratings using verified title information.
-- ============================================================

UPDATE netflix_staging
SET rating = 'TV-MA'
WHERE show_id IN ('s5795', 's5814');

UPDATE netflix_staging
SET rating = 'TV-PG'
WHERE show_id IN ('s5990', 's6828');

UPDATE netflix_staging
SET rating = 'PG-13'
WHERE show_id = 's7538';

UPDATE netflix_staging
SET rating = 'TV-Y'
WHERE show_id = 's7313';


-- ============================================================
-- STEP 6: VERIFY UPDATED RATINGS
-- ============================================================

SELECT show_id,
       title,
       rating
FROM netflix_staging
WHERE show_id IN ('s5795', 's5814', 's5990', 's6828', 's7538', 's7313');


-- ============================================================
-- STEP 7: FINAL RATING VALIDATION
-- Purpose:
-- Confirm there are no NULL or blank rating values.
-- ============================================================

SELECT
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
    SUM(CASE WHEN rating = '' THEN 1 ELSE 0 END) AS rating_blanks
FROM netflix_staging;


-- ============================================================
-- STEP 8: CHECK FINAL ROW COUNT
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM netflix_staging;


-- ============================================================
-- STEP 9: REVIEW TABLE STRUCTURE
-- ============================================================

DESCRIBE netflix_staging;


-- ============================================================
-- STEP 10: VALIDATE RELEASE YEAR VALUES
-- Purpose:
-- Make sure release_year only contains numeric values.
-- ============================================================

SELECT MIN(release_year) AS earliest_release_year,
       MAX(release_year) AS latest_release_year
FROM netflix_staging;

SELECT release_year
FROM netflix_staging
WHERE release_year NOT REGEXP '^[0-9]+$';


-- ============================================================
-- STEP 11: CONVERT RELEASE YEAR DATA TYPE
-- Purpose:
-- Convert release_year from TEXT to INT for analysis.
-- ============================================================

ALTER TABLE netflix_staging
MODIFY COLUMN release_year INT;


-- ============================================================
-- STEP 12: DROP UNNECESSARY COLUMN
-- Purpose:
-- Remove description column because it is not needed for SQL EDA.
-- ============================================================

ALTER TABLE netflix_staging
DROP COLUMN m_s_description;


-- ============================================================
-- STEP 13: PREVIEW CLEANED DATA
-- ============================================================

SELECT *
FROM netflix_staging
LIMIT 10;


-- ============================================================
-- STEP 14: CREATE FINAL CLEANED DATASET TABLE
-- Purpose:
-- Create a clean final table for analysis.
-- ============================================================

CREATE TABLE netflix_cleaned_dataset
LIKE netflix_staging;


-- ============================================================
-- STEP 15: INSERT CLEANED DATA INTO FINAL TABLE
-- ============================================================

INSERT INTO netflix_cleaned_dataset
SELECT *
FROM netflix_staging;


-- ============================================================
-- STEP 16: VERIFY FINAL CLEANED TABLE
-- ============================================================

SELECT COUNT(*) AS cleaned_total_rows
FROM netflix_cleaned_dataset;

DESCRIBE netflix_cleaned_dataset;


-- ============================================================
-- DATA CLEANING COMPLETE
-- Final Table: netflix_cleaned_dataset
-- Ready for EDA
-- ============================================================