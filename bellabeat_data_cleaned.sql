-- *** Bellabeat Case Study *** --

-- CLEANING DATASET -- 

USE bellabeat;

-- check column names across tables in dataset
SELECT 
    COLUMN_NAME,
    COUNT(TABLE_NAME)
FROM 
    bellabeat.INFORMATION_SCHEMA.COLUMNS
GROUP BY COLUMN_NAME;


-- check that every table has an Id column
SELECT 
    TABLE_NAME,
    SUM(CASE 
        WHEN column_name = 'Id' THEN 1
        ELSE 0
    END) AS has_id_column
FROM bellabeat.INFORMATION_SCHEMA.COLUMNS
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME ASC;
-- every table has Id column


-- check that each table has a date or time column type
SELECT
	TABLE_NAME,
	COLUMN_NAME,
	DATA_TYPE
FROM
	bellabeat.INFORMATION_SCHEMA.COLUMNS
WHERE
	DATA_TYPE IN ('datetime', 'date', 'time')
-- every table has a date column


-- check names of columns with DATATIME, DATE, OR TIME
SELECT 
    CONCAT(table_catalog,'.',table_schema,'.',table_name) AS table_path,
    table_name, column_name
FROM bellabeat.INFORMATION_SCHEMA.COLUMNS
WHERE
    DATA_TYPE IN ('datetime', 'date', 'time');


-- check distinct users from tables
SELECT 
	COUNT(DISTINCT Id) AS number_of_users
FROM 
	bellabeat..dailyActivity;
-- result 33 unique user ids
-- interesting because only 30 users were said to participate in the study

SELECT 
	COUNT(DISTINCT Id) AS number_of_users
FROM 
	bellabeat..dailySleep;
-- result 24 unique user ids

SELECT 
	COUNT(DISTINCT Id) AS number_of_users
FROM 
	bellabeat..weight;
-- result 8 unique user ids


-- User Id is common key across all tables of this analysis
-- Validate Id lenghs
SELECT DISTINCT LEN(Id) FROM bellabeat..dailyActivity;

SELECT DISTINCT LEN(Id) FROM bellabeat..dailySleep;

SELECT DISTINCT LEN(Id) FROM bellabeat..weight;
-- all Ids are either 11 or 12 characters long


-- check for duplicates and nulls in tables using distinct row count
--dailyActivity
SELECT 
	COUNT(*)
FROM (
	SELECT DISTINCT * 
	FROM bellabeat..dailyActivity) AS distinct_rows;
-- 940 distinct rows

SELECT 
	COUNT(*) AS total_rows
FROM bellabeat..dailyActivity;
-- 940 total rows = 0 to remove


-- dailySleep
SELECT
	COUNT(*)
	FROM (
		SELECT DISTINCT * 
		FROM bellabeat..dailySleep) AS distinct_rows;
-- 410 distinct rows

SELECT 
	COUNT(*) AS total_rows
	FROM bellabeat..dailySleep;
-- 413 total rows = 3 to remove


-- weight
SELECT
	COUNT(*) 
	FROM (
		SELECT DISTINCT * 
		FROM bellabeat..weight) AS distinct_rows;
-- 67 distinct rows

SELECT 
	COUNT(*) AS total_rows 
	FROM bellabeat..weight;
-- 67 total rows = 0 to remove


-- delete duplicate rows
DROP TABLE IF EXISTS bellabeat.dailySleepCleaned
SELECT 
	DISTINCT * INTO bellabeat..dailySleepCleaned
FROM bellabeat..dailySleep
WHERE Id IS NOT NULL;

SELECT COUNT(1) FROM bellabeat..dailySleepCleaned AS total_rows;
-- 410 rows; duplicates removed


-- rename columns to lowercase camel across all tables for consistency, clean TIMESTAMP formats, reound decimals, remove non-essential columns
-- daily_activity table
DROP TABLE IF EXISTS bellabeat..dailyActivityClean
SELECT
        Id AS id,
        ActivityDate AS activity_date,
        TotalSteps AS total_steps,
        ROUND(TotalDistance,2) AS total_distance,
        ROUND(TrackerDistance,2) AS tracker_distance,
        LoggedActivitiesDistance AS logged_activities_distance,
        ROUND(VeryActiveDistance,2) AS very_active_distance,
        ROUND(ModeratelyActiveDistance,2) AS moderately_active_distance,
        ROUND(LightActiveDistance,2) AS light_active_distance,
        ROUND(SedentaryActiveDistance,2) AS sedentary_active_distance,
        VeryActiveMinutes AS very_active_minutes,
        FairlyActiveMinutes AS fairly_active_minutes,
        LightlyActiveMinutes AS lightly_active_minutes,
        SedentaryMinutes AS sedentary_minutes,
        Calories AS calories
	INTO bellabeat..dailyActivityClean
FROM 
    bellabeat..dailyActivity;

-- daily_sleep table
DROP TABLE IF EXISTS bellabeat..dailySleepClean
SELECT
    Id AS id,
    SleepDay AS sleep_day,
    TotalSleepRecords AS total_sleep_records,
    TotalMinutesAsleep AS total_minutes_asleep,
    TotalTimeInBed AS total_time_in_bed
	INTO bellabeat..dailySleepClean
FROM 
    bellabeat..dailySleepCleaned

-- weight table
DROP TABLE IF EXISTS bellabeat..weightClean
SELECT
    Id AS id,
    Date AS tracking_date,
    WeightKg AS weight_kg,
    ROUND(WeightPounds, 2) AS weight_pounds,
	Fat AS fat,
	BMI AS bmi,
	IsManualReport AS is_manual_report,
	LogId as log_id
	INTO bellabeat..weightClean
FROM 
    bellabeat..weight;


-- preview clean data
SELECT TOP 15 * FROM bellabeat..dailyActivityClean;
SELECT TOP 15 * FROM bellabeat..dailySleepClean;
SELECT TOP 15 * FROM bellabeat..weightClean;


-- export clean data to xlsx sheets to load into tableau
SELECT *
	FROM bellabeat..dailyActivityClean;

SELECT *
	FROM bellabeat..dailySleepClean;

SELECT *
	FROM bellabeat..weightClean;