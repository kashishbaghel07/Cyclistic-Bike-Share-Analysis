/*=============================================================================
CYCLISTIC BIKE-SHARE CASE STUDY — BEGINNER-FRIENDLY SQL PROJECT
Database: cyclistic_analysis
Table: cyclistic_rides
Goal: Compare casual riders and annual members.

REPORTING PERIOD: 1 September 2025 through 31 August 2026
The date filter includes 2025-09-01 and excludes 2026-09-01.

HOW TO USE THIS FILE
1. Read the comments before each query.
2. Run one query at a time in MySQL Workbench.
3. The CSV import and CREATE INDEX statements are optional and commented out.
4. Do not import the CSV again if the table already contains the data.
5. Python performed the initial data cleaning; these SQL queries validate and
   analyze the cleaned data. They do not automatically change or delete rows.
=============================================================================*/

/*=============================================================================
SECTION 1 — CREATE THE DATABASE AND TABLE
Run CREATE TABLE only for a fresh setup. Existing tables are not overwritten.
=============================================================================*/

CREATE DATABASE IF NOT EXISTS cyclistic_analysis;
USE cyclistic_analysis;

CREATE TABLE IF NOT EXISTS cyclistic_rides (
    ride_id VARCHAR(50),
    rideable_type VARCHAR(30),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(100),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(100),
    start_lat DECIMAL(10,7),
    start_lng DECIMAL(10,7),
    end_lat DECIMAL(10,7),
    end_lng DECIMAL(10,7),
    member_casual VARCHAR(20),
    ride_length DECIMAL(10,4),
    day_of_week VARCHAR(15),
    start_hour INT,
    month VARCHAR(15),
    day_type VARCHAR(10)
);

-- 1.1 Confirm the selected database and table.
SELECT DATABASE() AS selected_database;
SHOW TABLES FROM cyclistic_analysis;

-- 1.2 Check the columns and their data types.
DESCRIBE cyclistic_analysis.cyclistic_rides;


/*=============================================================================
SECTION 2 — LOAD THE CLEANED CSV CREATED IN PYTHON
Run this block ONLY if you are setting up a fresh, empty table.
Update the file path first. Do not run it again on your populated table.
=============================================================================*/

/*
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/YOUR/PATH/cyclistic_cleaned.csv'
INTO TABLE cyclistic_analysis.cyclistic_rides
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual,
    ride_length,
    day_of_week,
    start_hour,
    month,
    day_type
);

SELECT COUNT(*) AS imported_rows
FROM cyclistic_analysis.cyclistic_rides;
*/


/*=============================================================================
SECTION 3 — UNDERSTAND THE IMPORTED DATA

These queries check the FULL imported table, not just the reporting period.

The full table contains 6,115,918 rides, including 268 rides from August 2025.

The main analysis covers 1 September 2025 through 31 August 2026,
so those 268 August rides are excluded from the main analysis.

Therefore, the full-table counts in this section will differ from the
reporting-period counts in later sections.

=============================================================================*/

-- 3.1 Count all rows in the table.
SELECT COUNT(*) AS all_imported_rows
FROM cyclistic_analysis.cyclistic_rides;

-- 3.2 Find the first and last ride timestamps.
SELECT
    MIN(started_at) AS first_ride,
    MAX(started_at) AS last_ride
FROM cyclistic_analysis.cyclistic_rides;

-- 3.3 Count rides by month to check which months are present.
SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
GROUP BY DATE_FORMAT(started_at, '%Y-%m')
ORDER BY ride_month;

-- 3.4 Check the rider-type labels.
SELECT member_casual, COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
GROUP BY member_casual
ORDER BY total_rides DESC;
/*
EXPLANATION:

The full table contains 268 additional rides from August 2025.

40 member rides and 228 casual rides fall outside the selected
reporting period.

These records remain in the database, but the main analysis excludes
them using the date filter in Section 4.
*/
-- 3.5 Check rides outside the selected reporting period.

SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at < '2025-09-01'
   OR started_at >= '2026-09-01'
GROUP BY
    DATE_FORMAT(started_at, '%Y-%m'),
    member_casual
ORDER BY ride_month, member_casual;

-- 3.6 Check the bike-type labels.
SELECT
    rideable_type,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
GROUP BY rideable_type
ORDER BY rideable_type;


/*=============================================================================
SECTION 4 — VALIDATE THE REPORTING PERIOD
All main analysis queries below use September 2025 through August 2026.
=============================================================================*/

-- 4.1 Count rides in the selected 12-month reporting period.
SELECT COUNT(*) AS reporting_period_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01';

-- 4.2 Count rides by month inside the reporting period.
SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY DATE_FORMAT(started_at, '%Y-%m')
ORDER BY ride_month;


/*=============================================================================
SECTION 5 — CHECK DATA QUALITY
These queries identify possible issues; they do not delete or modify data.
=============================================================================*/

-- 5.1 Check missing important values across the full table.
-- Do not filter on started_at here, because that would hide missing start times.
SELECT
    COUNT(*) AS all_rows,
    SUM(ride_id IS NULL) AS missing_ride_ids,
    SUM(started_at IS NULL) AS missing_start_times,
    SUM(ended_at IS NULL) AS missing_end_times,
    SUM(member_casual IS NULL) AS missing_rider_types,
    SUM(ride_length IS NULL) AS missing_ride_lengths,
    SUM(rideable_type IS NULL) AS missing_bike_types
FROM cyclistic_analysis.cyclistic_rides;

-- 5.2 Check missing or blank station names and IDs in the reporting period.
SELECT
    SUM(start_station_name IS NULL OR TRIM(start_station_name) = '') AS missing_start_station_names,
    SUM(end_station_name IS NULL OR TRIM(end_station_name) = '') AS missing_end_station_names,
    SUM(start_station_id IS NULL OR TRIM(start_station_id) = '') AS missing_start_station_ids,
    SUM(end_station_id IS NULL OR TRIM(end_station_id) = '') AS missing_end_station_ids
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01';

-- 5.3 Check null, zero/negative, and longer-than-60-minute durations.
SELECT
    COUNT(*) AS reporting_period_rows,
    SUM(ride_length IS NULL) AS null_durations,
    SUM(ride_length <= 0) AS nonpositive_durations,
    SUM(ride_length > 60) AS rides_over_60_minutes
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01';

-- 5.4 Check whether any end time is earlier than its start time.
SELECT COUNT(*) AS end_before_start_rows
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND ended_at < started_at;

-- 5.5 Check duplicate ride-ID groups in the reporting period.
-- A result of zero means no repeated non-null ride IDs were found.
SELECT COUNT(*) AS duplicate_ride_id_groups
FROM (
    SELECT ride_id
    FROM cyclistic_analysis.cyclistic_rides
    WHERE started_at >= '2025-09-01'
      AND started_at <  '2026-09-01'
      AND ride_id IS NOT NULL
    GROUP BY ride_id
    HAVING COUNT(*) > 1
) AS duplicate_ids;

-- 5.6 Inspect day_type for hidden characters. CHAR(13) means carriage return.
SELECT
    CONCAT('[', day_type, ']') AS day_type_label,
    LENGTH(day_type) AS label_length,
    HEX(day_type) AS hex_value,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY day_type, LENGTH(day_type), HEX(day_type)
ORDER BY total_rides DESC;


/*=============================================================================
SECTION 6 — REVIEW INDEXES
Check existing indexes before creating any new ones. Indexes can improve some
queries but use storage and can slow down data imports.
=============================================================================*/

-- 6.1 List indexes already on the table.
SHOW INDEX FROM cyclistic_analysis.cyclistic_rides;

-- 6.2 Optional indexes. Uncomment only if equivalent indexes do not exist.
/*
CREATE INDEX idx_started_at
ON cyclistic_analysis.cyclistic_rides (started_at);

CREATE INDEX idx_rider_type
ON cyclistic_analysis.cyclistic_rides (member_casual);

CREATE INDEX idx_day_rider
ON cyclistic_analysis.cyclistic_rides (day_of_week, member_casual);
*/


/*=============================================================================
SECTION 7 — COMPARE CASUAL RIDERS AND MEMBERS
=============================================================================*/

-- 7.1 Count rides and calculate each rider group's share of all rides.
SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM cyclistic_analysis.cyclistic_rides
         WHERE started_at >= '2025-09-01'
           AND started_at <  '2026-09-01'),
        2
    ) AS ride_percentage
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY member_casual
ORDER BY total_rides DESC;

-- 7.2 Compare average ride duration. Only positive durations are averaged.
SELECT
    member_casual,
    COUNT(*) AS positive_duration_rides,
    ROUND(AVG(ride_length), 2) AS avg_ride_minutes
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND ride_length > 0
GROUP BY member_casual
ORDER BY avg_ride_minutes DESC;

-- 7.3 Compare average duration for each weekday and rider group.
SELECT
    day_of_week,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(CASE WHEN ride_length > 0 THEN ride_length END), 2) AS avg_ride_minutes
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY day_of_week, member_casual
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), member_casual;

-- 7.4 Show each weekday's percentage of that rider group's rides.
SELECT
    day_of_week,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM cyclistic_analysis.cyclistic_rides AS all_rides
         WHERE all_rides.member_casual = daily_rides.member_casual
           AND all_rides.started_at >= '2025-09-01'
           AND all_rides.started_at <  '2026-09-01'),
        2
    ) AS pct_of_rider_type
FROM cyclistic_analysis.cyclistic_rides AS daily_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY day_of_week, member_casual
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), member_casual;


/*=============================================================================
SECTION 8 — MONTHLY, SEASONAL, AND HOURLY PATTERNS
=============================================================================*/

-- 8.1 Monthly ride counts by rider group. The year is included in each month.
SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY DATE_FORMAT(started_at, '%Y-%m'), member_casual
ORDER BY ride_month, member_casual;


-- 8.2 Percentage of rides in each month from each rider group.

SELECT
    DATE_FORMAT(r.started_at, '%Y-%m') AS ride_month,
    r.member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        COUNT(*) * 100.0 / monthly_total.total_rides, 2) AS pct_of_month
FROM cyclistic_analysis.cyclistic_rides AS r
JOIN (
    SELECT
        DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
        COUNT(*) AS total_rides
    FROM cyclistic_analysis.cyclistic_rides
    WHERE started_at >= '2025-09-01'
      AND started_at < '2026-09-01'
    GROUP BY DATE_FORMAT(started_at, '%Y-%m')
) AS monthly_total
    ON DATE_FORMAT(r.started_at, '%Y-%m') = monthly_total.ride_month
WHERE r.started_at >= '2025-09-01'
  AND r.started_at < '2026-09-01'
GROUP BY
    DATE_FORMAT(r.started_at, '%Y-%m'),
    r.member_casual,
    monthly_total.total_rides
ORDER BY
    ride_month,
    r.member_casual;


-- 8.3 Average ride duration by month and rider group.
SELECT
    DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
    member_casual,
    COUNT(*) AS positive_duration_rides,
    ROUND(AVG(ride_length), 2) AS avg_ride_minutes
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND ride_length > 0
GROUP BY DATE_FORMAT(started_at, '%Y-%m'), member_casual
ORDER BY ride_month, member_casual;

-- 8.4 Count rides by hour of day and rider group.
SELECT
    start_hour,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY start_hour, member_casual
ORDER BY start_hour, member_casual;


/*=============================================================================
SECTION 9 — BIKE-TYPE ANALYSIS
=============================================================================*/

-- 9.1 Count rides by bike type and rider group.
SELECT
    rideable_type,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY rideable_type, member_casual
ORDER BY rideable_type, member_casual;

-- 9.2 Calculate each bike type's percentage within each rider group.
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM cyclistic_analysis.cyclistic_rides AS rider_rides
         WHERE rider_rides.member_casual = bike_rides.member_casual
           AND rider_rides.started_at >= '2025-09-01'
           AND rider_rides.started_at <  '2026-09-01'),
        2
    ) AS pct_of_rider_type
FROM cyclistic_analysis.cyclistic_rides AS bike_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_rides DESC;

-- 9.3 Average duration by bike type and rider group.
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS positive_duration_rides,
    ROUND(AVG(ride_length), 2) AS avg_ride_minutes
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND ride_length > 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual, avg_ride_minutes DESC;


/*=============================================================================
SECTION 10 — WEEKDAY VERSUS WEEKEND
The stored day_type values end with CHAR(13), so remove it before comparing.
=============================================================================*/

-- 10.1 Count weekday and weekend rides by rider group.
SELECT
    TRIM(REPLACE(day_type, CHAR(13), '')) AS cleaned_day_type,
    member_casual,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY TRIM(REPLACE(day_type, CHAR(13), '')), member_casual
ORDER BY cleaned_day_type, member_casual;

-- 10.2 Calculate weekend rides and weekend share for each rider group.
SELECT
    member_casual,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN TRIM(REPLACE(day_type, CHAR(13), '')) = 'Weekend' THEN 1 ELSE 0 END) AS weekend_rides,
    ROUND(
        100.0 * SUM(CASE WHEN TRIM(REPLACE(day_type, CHAR(13), '')) = 'Weekend' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS weekend_ride_pct
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY member_casual
ORDER BY member_casual;

-- 10.3 Cross-check overall weekday and weekend counts.
SELECT
    TRIM(REPLACE(day_type, CHAR(13), '')) AS cleaned_day_type,
    COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY TRIM(REPLACE(day_type, CHAR(13), ''));


/*=============================================================================
SECTION 11 — STARTING-STATION ANALYSIS
Blank station names are excluded from station rankings.
=============================================================================*/

-- 11.1 Top 10 starting stations for casual riders.
SELECT start_station_name, COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND member_casual = 'casual'
  AND start_station_name IS NOT NULL
  AND TRIM(start_station_name) <> ''
GROUP BY start_station_name
ORDER BY total_rides DESC
LIMIT 10;

-- 11.2 Top 10 starting stations for annual members.
SELECT start_station_name, COUNT(*) AS total_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND member_casual = 'member'
  AND start_station_name IS NOT NULL
  AND TRIM(start_station_name) <> ''
GROUP BY start_station_name
ORDER BY total_rides DESC
LIMIT 10;

-- 11.3 Compare casual and member rides at stations used by both groups.
SELECT
    start_station_name,
    SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_rides,
    SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND start_station_name IS NOT NULL
  AND TRIM(start_station_name) <> ''
GROUP BY start_station_name
HAVING SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) > 0
   AND SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) > 0
ORDER BY casual_rides DESC
LIMIT 10;


/*=============================================================================
SECTION 12 — LONG-RIDE CHECK AND AVERAGE-DURATION SENSITIVITY
A ride over 60 minutes is not automatically invalid. Compare results before
excluding long rides; do not delete records without a documented reason.
=============================================================================*/

-- 12.1 Count rides longer than 60 minutes by rider and bike type.
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS rides_over_60_minutes,
    ROUND(AVG(ride_length), 2) AS avg_long_ride_minutes,
    ROUND(MAX(ride_length), 2) AS longest_ride_minutes
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND ride_length > 60
GROUP BY member_casual, rideable_type
ORDER BY rides_over_60_minutes DESC;

-- 12.2 Compare average duration with all positive rides and rides up to 60 min.
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS positive_duration_rides,
    ROUND(AVG(ride_length), 2) AS avg_all_positive_rides_min,
    ROUND(AVG(CASE WHEN ride_length <= 60 THEN ride_length END), 2) AS avg_rides_up_to_60_min,
    SUM(CASE WHEN ride_length > 60 THEN 1 ELSE 0 END) AS rides_over_60_min
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
  AND ride_length > 0
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rideable_type;


/*=============================================================================
SECTION 13 — FINAL SUMMARY FOR THE REPORT
Use this output for the main comparison table in the case study.
=============================================================================*/

SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM cyclistic_analysis.cyclistic_rides
         WHERE started_at >= '2025-09-01'
           AND started_at <  '2026-09-01'),
        2
    ) AS ride_percentage,
    ROUND(AVG(CASE WHEN ride_length > 0 THEN ride_length END), 2) AS avg_ride_minutes,
    ROUND(AVG(CASE WHEN ride_length > 0 AND ride_length <= 60 THEN ride_length END), 2) AS avg_ride_up_to_60_min,
    SUM(CASE WHEN TRIM(REPLACE(day_type, CHAR(13), '')) = 'Weekend' THEN 1 ELSE 0 END) AS weekend_rides,
    ROUND(
        100.0 * SUM(CASE WHEN TRIM(REPLACE(day_type, CHAR(13), '')) = 'Weekend' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS weekend_ride_pct,
    ROUND(
        100.0 * SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS electric_bike_pct
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01'
GROUP BY member_casual
ORDER BY member_casual;

-- Previously verified results (re-run the query if the data changes):
-- casual: 2,160,116 rides; 35.32%; average 20.66 min; 804,894 weekend rides;
--         weekend share 37.26%; electric bike share 73.60%.
-- member: 3,955,534 rides; 64.68%; average 12.37 min; 923,063 weekend rides;
--         weekend share 23.34%; electric bike share 68.06%.


/*=============================================================================
SECTION 14 — FINAL VALIDATION AND OPTIONAL TROUBLESHOOTING
=============================================================================*/

-- 14.1 Confirm the reporting-period total (expected: 6,115,650).
SELECT COUNT(*) AS reporting_period_total
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01';

-- 14.2 Check that casual and member counts add up to the period total.
SELECT
    SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_rides,
    SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_rides,
    COUNT(*) AS all_rides
FROM cyclistic_analysis.cyclistic_rides
WHERE started_at >= '2025-09-01'
  AND started_at <  '2026-09-01';

-- 14.3 Optional MySQL diagnostics; run only if troubleshooting is needed.
-- SELECT @@hostname AS server_name, @@port AS server_port, @@version AS mysql_version;
-- SHOW TABLE STATUS FROM cyclistic_analysis LIKE 'cyclistic_rides';
-- SHOW GLOBAL STATUS LIKE 'Uptime';

/*=============================================================================
END OF PROJECT
The Python script does the initial cleaning. This SQL file documents the
creation/setup, import, validation, index review, analysis, and final reporting.
Run queries individually. The expected results above are based on earlier
outputs and have not been produced by executing this entire file in this turn.
=============================================================================*/
