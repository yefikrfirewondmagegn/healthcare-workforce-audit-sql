
-- PROJECT: HEALTHCARE WORKFORCE DATA CLEANING AND AUDIT
-- DATABASE: healthcare
-- TOOLS: MySQL Workbench
-- ORIGINAL TABLE: healthcare_survey1
-- CLEANED TABLE: healthcare_survey1_staging
-- RECORDS: 120

USE healthcare;

SHOW DATABASES;

SHOW TABLES;

DESCRIBE healthcare_survey1;

SELECT COUNT(*) AS original_total_records
FROM healthcare_survey1;

SELECT *
FROM healthcare_survey1
ORDER BY id
LIMIT 10;


-- Identify missing, zero, negative and extreme hours

SELECT
    id,
    profession,
    department,
    shift_hours_per_week,
    burnout_score,
    CASE
        WHEN shift_hours_per_week IS NULL
             OR TRIM(shift_hours_per_week) = ''
            THEN 'Missing hours'

        WHEN TRIM(shift_hours_per_week)
             NOT REGEXP '^[0-9]+([.][0-9]+)?$'
            THEN 'Invalid numeric format'

        WHEN CAST(shift_hours_per_week AS DECIMAL(10,2)) = 0
            THEN 'Zero hours - investigate'

        WHEN CAST(shift_hours_per_week AS DECIMAL(10,2)) < 0
            THEN 'Negative hours - investigate'

        WHEN CAST(shift_hours_per_week AS DECIMAL(10,2)) > 90
            THEN 'Above 90 hours - review'

        ELSE 'No hours issue detected'
    END AS data_quality_issue
FROM healthcare_survey1
WHERE shift_hours_per_week IS NULL
   OR TRIM(shift_hours_per_week) = ''
   OR TRIM(shift_hours_per_week)
      NOT REGEXP '^[0-9]+([.][0-9]+)?$'
   OR CAST(shift_hours_per_week AS DECIMAL(10,2)) = 0
   OR CAST(shift_hours_per_week AS DECIMAL(10,2)) < 0
   OR CAST(shift_hours_per_week AS DECIMAL(10,2)) > 90
ORDER BY id;


-- Investigate department inconsistencies

SELECT
    department,
    COUNT(*) AS record_count
FROM healthcare_survey1
GROUP BY department
ORDER BY department;


-- Check duplicate respondent IDs

SELECT
    id,
    COUNT(*) AS occurrences
FROM healthcare_survey1
GROUP BY id
HAVING COUNT(*) > 1;


-- Investigate burnout score quality

SELECT
    COUNT(*) AS total_records,
    MIN(burnout_score) AS minimum_score,
    MAX(burnout_score) AS maximum_score,
    ROUND(AVG(burnout_score), 2) AS average_score,
    SUM(burnout_score IS NULL) AS missing_scores,
    SUM(burnout_score < 0) AS negative_scores,
    SUM(burnout_score > 10) AS scores_above_10
FROM healthcare_survey1;

DESCRIBE healthcare_survey1_staging;

SELECT COUNT(*) AS cleaned_total_records
FROM healthcare_survey1_staging;

SELECT *
FROM healthcare_survey1_staging
ORDER BY id
LIMIT 15;


SELECT
    department,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
GROUP BY department
ORDER BY department;


-- Check original and cleaned working hours

SELECT
    id,
    department,
    shift_hours_original_value,
    shift_hours_per_week,
    shift_hours_imputation_method,
    shift_hours_cleaning_action
FROM healthcare_survey1_staging
WHERE shift_hours_original_value IS NOT NULL
ORDER BY id;


-- Summarize cleaning actions

SELECT
    shift_hours_cleaning_action,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
GROUP BY shift_hours_cleaning_action
ORDER BY shift_hours_cleaning_action;


-- Check remaining missing and zero hours

SELECT
    COUNT(*) AS total_records,
    SUM(shift_hours_per_week IS NULL) AS missing_hours,
    SUM(shift_hours_per_week = 0) AS zero_hours,
    SUM(shift_hours_per_week < 0) AS negative_hours
FROM healthcare_survey1_staging;


-- Extreme working hours are flagged for review, not automatically deleted.

SELECT
    id,
    profession,
    department,
    shift_hours_original_value,
    shift_hours_per_week,
    shift_hours_original_status,
    shift_hours_cleaning_action
FROM healthcare_survey1_staging
WHERE shift_hours_per_week > 90
ORDER BY shift_hours_per_week DESC;


-- Count flagged outliers

SELECT
    COUNT(*) AS flagged_outlier_records
FROM healthcare_survey1_staging
WHERE shift_hours_per_week > 90;


-- Verify outlier review labels

SELECT
    shift_hours_original_status,
    shift_hours_cleaning_action,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
WHERE shift_hours_per_week > 90
GROUP BY
    shift_hours_original_status,
    shift_hours_cleaning_action;


-- Check workload distribution

SELECT
    workload_category,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
GROUP BY workload_category
ORDER BY workload_category;


-- Compare existing categories with calculated categories

SELECT
    id,
    shift_hours_per_week,
    workload_category AS current_category,

    CASE
        WHEN shift_hours_per_week <= 40
            THEN 'Up to 40 hours'
        WHEN shift_hours_per_week <= 60
            THEN '41-60 hours'
        ELSE 'Over 60 hours'
    END AS expected_category

FROM healthcare_survey1_staging
WHERE workload_category <>
    CASE
        WHEN shift_hours_per_week <= 40
            THEN 'Up to 40 hours'
        WHEN shift_hours_per_week <= 60
            THEN '41-60 hours'
        ELSE 'Over 60 hours'
    END;


-- Summary of burnout scores

SELECT
    COUNT(*) AS total_records,
    COUNT(burnout_score) AS non_missing_scores,
    MIN(burnout_score) AS minimum_score,
    MAX(burnout_score) AS maximum_score,
    ROUND(AVG(burnout_score), 2) AS average_score
FROM healthcare_survey1_staging;


-- Burnout category distribution

SELECT
    burnout_category,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
GROUP BY burnout_category
ORDER BY burnout_category;


-- High burnout flag distribution

SELECT
    high_burnout_flag,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
GROUP BY high_burnout_flag
ORDER BY high_burnout_flag;


-- Compare burnout categories and high burnout flags

SELECT
    burnout_category,
    high_burnout_flag,
    COUNT(*) AS record_count
FROM healthcare_survey1_staging
GROUP BY
    burnout_category,
    high_burnout_flag
ORDER BY
    burnout_category,
    high_burnout_flag;


SELECT
    department,
    COUNT(*) AS total_records,
    ROUND(AVG(shift_hours_per_week), 2) AS average_hours,
    MIN(shift_hours_per_week) AS minimum_hours,
    MAX(shift_hours_per_week) AS maximum_hours,
    ROUND(AVG(burnout_score), 2) AS average_burnout_score
FROM healthcare_survey1_staging
GROUP BY department
ORDER BY department;



-- Check total records and unique IDs

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT id) AS unique_ids,
    COUNT(*) - COUNT(DISTINCT id) AS duplicate_records
FROM healthcare_survey1_staging;


-- Check missing values across important columns

SELECT
    SUM(id IS NULL) AS missing_ids,

    SUM(profession IS NULL OR TRIM(profession) = '')
        AS missing_professions,

    SUM(department IS NULL OR TRIM(department) = '')
        AS missing_departments,

    SUM(shift_hours_per_week IS NULL)
        AS missing_shift_hours,

    SUM(burnout_score IS NULL)
        AS missing_burnout_scores,

    SUM(workload_category IS NULL OR TRIM(workload_category) = '')
        AS missing_workload_categories,

    SUM(burnout_category IS NULL OR TRIM(burnout_category) = '')
        AS missing_burnout_categories,

    SUM(high_burnout_flag IS NULL OR TRIM(high_burnout_flag) = '')
        AS missing_burnout_flags

FROM healthcare_survey1_staging;


-- 10.3 Final working hours statistics

SELECT
    COUNT(*) AS total_records,
    ROUND(MIN(shift_hours_per_week), 2) AS minimum_hours,
    ROUND(MAX(shift_hours_per_week), 2) AS maximum_hours,
    ROUND(AVG(shift_hours_per_week), 2) AS average_hours
FROM healthcare_survey1_staging;


-- 10.4 Final dataset summary

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT id) AS unique_respondents,

    SUM(
        shift_hours_cleaning_action =
        'Department average imputation'
    ) AS imputed_records,

    SUM(
        shift_hours_per_week > 90
    ) AS flagged_extreme_hours,

    SUM(
        burnout_category = 'Higher (project-defined)'
    ) AS higher_burnout_records

FROM healthcare_survey1_staging;


