/* ============================================================
   NETFLIX TITLES ETL PROJECT
   Purpose:
   - Import Netflix CSV data into MySQL
   - Create a staging table
   - Begin data cleaning by checking duplicates
   ============================================================ */


/* ============================================================
   STEP 1: SELECT DATABASE
   ============================================================ */

SHOW DATABASES;

USE netflix_titles;

SELECT DATABASE();


/* ============================================================
   STEP 2: CREATE RAW TABLE
   Purpose:
   - Store the original CSV data.
   - Keep all columns as TEXT during import to avoid datatype
     errors while loading the CSV.
   ============================================================ */

DROP TABLE IF EXISTS netflix_raw;

CREATE TABLE netflix_raw (
    show_id TEXT,
    type TEXT,
    title TEXT,
    director TEXT,
    m_s_cast TEXT,
    country TEXT,
    date_added TEXT,
    release_year TEXT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    m_s_description TEXT
);


/* ============================================================
   STEP 3: ENABLE LOCAL FILE IMPORT
   Purpose:
   - Allows MySQL to load a local CSV file using
     LOAD DATA LOCAL INFILE.
   ============================================================ */

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';


/* ============================================================
   STEP 4: LOAD CSV INTO RAW TABLE
   Purpose:
   - Import netflix_titles.csv into netflix_raw.
   - IGNORE 1 ROWS skips the header row.
   ============================================================ */

LOAD DATA LOCAL INFILE '/Users/sasankageetanathgorthi/Desktop/MySQL/netflix_titles/netflix_titles.csv'
INTO TABLE netflix_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


/* Verify raw table row count */
SELECT COUNT(*) AS raw_row_count
FROM netflix_raw;


/* Preview raw data */
SELECT *
FROM netflix_raw
LIMIT 10;


/* ============================================================
   STEP 5: CREATE STAGING TABLE
   Purpose:
   - Do not clean the raw table directly.
   - Use netflix_staging as the working table.
   ============================================================ */

DROP TABLE IF EXISTS netflix_staging;

CREATE TABLE netflix_staging
LIKE netflix_raw;


/* Copy raw data into staging table */
INSERT INTO netflix_staging
SELECT *
FROM netflix_raw;


/* Verify staging table row count matches raw table */
SELECT COUNT(*) AS raw_row_count
FROM netflix_raw;

SELECT COUNT(*) AS staging_row_count
FROM netflix_staging;


/* Preview staging data */
SELECT *
FROM netflix_staging
LIMIT 10;


/* ============================================================
   STEP 6: CHECK DUPLICATES USING show_id
   Purpose:
   - show_id appears to be the unique identifier.
   - Check whether any show_id appears more than once.
   ============================================================ */

SELECT show_id,
       COUNT(*) AS show_id_count
FROM netflix_staging
GROUP BY show_id
HAVING COUNT(*) > 1;


/* ============================================================
   ETL SETUP COMPLETE
   Current Status:
   - CSV imported
   - Raw table created
   - Staging table created
   - Duplicate check completed

   Next Step:
   - Standardization
   ============================================================ */