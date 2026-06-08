/* ============================================================
   NETFLIX ETL PROJECT
   Working Table: netflix_staging

   Current Phase:
   - Standardization
   - Rating data-quality fix
   - Country data-quality fix
   - Date conversion
   ============================================================ */


/* ============================================================
   STEP 1: REVIEW STAGING DATA
   Purpose:
   - Quickly inspect the working table before cleaning.
   ============================================================ */

SELECT *
FROM netflix_staging
ORDER BY show_id
LIMIT 10;


/* ============================================================
   STEP 2: STANDARDIZE TYPE COLUMN
   Purpose:
   - Check unique type values.
   - Remove leading/trailing spaces if any exist.
   ============================================================ */

SELECT DISTINCT `type`
FROM netflix_staging;

SELECT `type`,
       TRIM(`type`) AS trimmed_type
FROM netflix_staging;

UPDATE netflix_staging
SET `type` = TRIM(`type`);


/* ============================================================
   STEP 3: REVIEW AND CLEAN RATING COLUMN
   Purpose:
   - Rating should contain values like TV-MA, PG, R, etc.
   - Values like '66 min', '74 min', and '84 min' belong
     in duration, not rating.
   ============================================================ */

SELECT DISTINCT rating
FROM netflix_staging
ORDER BY rating;


/* Find rows where duration values were placed in rating */
SELECT *
FROM netflix_staging
WHERE rating LIKE '%min%';


/* Manually fix the 3 affected records */
UPDATE netflix_staging
SET duration = '66 min',
    rating = NULL
WHERE show_id = 's5814';

UPDATE netflix_staging
SET duration = '74 min',
    rating = NULL
WHERE show_id = 's5542';

UPDATE netflix_staging
SET duration = '84 min',
    rating = NULL
WHERE show_id = 's5795';


/* Verify rating/duration fixes */
SELECT *
FROM netflix_staging
WHERE show_id IN ('s5814', 's5795', 's5542');


/* Recheck rating values after cleaning */
SELECT DISTINCT rating
FROM netflix_staging
ORDER BY rating;


/* ============================================================
   STEP 4: REVIEW AND CLEAN COUNTRY COLUMN
   Purpose:
   - Country can contain one or multiple countries.
   - Investigate values that start with a comma, because
     they may indicate missing/incomplete country information.
   ============================================================ */

SELECT DISTINCT country
FROM netflix_staging
ORDER BY country;


/* Find country values with a leading comma */
SELECT *
FROM netflix_staging
WHERE country LIKE ',%';


/*
   Based on manual research/validation:
   - show_id s194 should be South Korea
   - show_id s366 should be Palestine, France, Algeria
*/

UPDATE netflix_staging
SET country = 'South Korea'
WHERE show_id = 's194';

UPDATE netflix_staging
SET country = 'Palestine, France, Algeria'
WHERE show_id = 's366';


/* Verify country fixes */
SELECT *
FROM netflix_staging
WHERE show_id IN ('s194', 's366');


/* Recheck country values after cleaning */
SELECT DISTINCT country
FROM netflix_staging
ORDER BY country;


/* ============================================================
   STEP 5: REVIEW DIRECTOR COLUMN
   Purpose:
   - Director has many unique values.
   - Main issue appears to be blank values, not standardization.
   ============================================================ */

SELECT DISTINCT director
FROM netflix_staging
ORDER BY director;


/* Count blank director values */
SELECT COUNT(*) AS blank_director_count
FROM netflix_staging
WHERE director = '';


/* ============================================================
   STEP 6: CONVERT DATE_ADDED COLUMN
   Purpose:
   - date_added is imported as TEXT.
   - Convert values like 'September 21, 2020' into DATE format.
   ============================================================ */

/* Review distinct date values */
SELECT DISTINCT date_added
FROM netflix_staging;


/* Test date conversion before updating */
SELECT date_added,
       STR_TO_DATE(date_added, '%M %d, %Y') AS converted_date
FROM netflix_staging
LIMIT 10;


/* Check for NULL or blank date values */
SELECT *
FROM netflix_staging
WHERE date_added IS NULL
   OR date_added = '';


/* Convert blank dates to NULL */
UPDATE netflix_staging
SET date_added = NULL
WHERE date_added = '';


/* Convert text dates to MySQL date format */
UPDATE netflix_staging
SET date_added = STR_TO_DATE(date_added, '%M %d, %Y');


/* Verify converted date values */
SELECT date_added
FROM netflix_staging;


/* Change date_added datatype from TEXT to DATE */
ALTER TABLE netflix_staging
MODIFY COLUMN date_added DATE;


/* ============================================================
   STEP 7: REVIEW DURATION COLUMN
   Purpose:
   - Check distinct duration values after rating cleanup.
   - Movies usually use minutes, TV Shows usually use seasons.
   ============================================================ */

SELECT DISTINCT duration
FROM netflix_staging
ORDER BY duration;


/* ============================================================
   CURRENT CLEANING STATUS
   Completed:
   - type standardized
   - rating cleaned
   - misplaced duration values fixed
   - country issues fixed
   - date_added converted to DATE

   Next:
   - Missing value review
   - Final datatype checks
   - Final validation before EDA
   ============================================================ */