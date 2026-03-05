CREATE DATABASE Oncology;

USE Oncology;


-- Data Cleaning Scripts - Nulls and Normalizing 

-- Step 0: See column name and types

EXEC sp_help hcp;
EXEC sp_help outcomes;
EXEC sp_help patients;
EXEC sp_help prescriptions;
EXEC sp_help refills;


-- Step 0: See sample data

SELECT TOP 10 * FROM hcp;

SELECT TOP 10 * FROM outcomes;

SELECT TOP 10 * FROM patients;

SELECT TOP 10 * FROM prescriptions;

SELECT TOP 10 * FROM refills;


-- Step 1: Explore the data

SELECT
	MAX(outcome_score) AS MaximumScore,
	MIN(outcome_score) AS MinimunScore,
	AVG(outcome_score) AS AverageScore,
	STDEV(outcome_score) AS StandarddDeviationScore
FROM
	outcomes;
/*
MaximumScore	MinimunScore	AverageScore	StandarddDeviationScore
84				48				74				5.82553481286102
*/

SELECT
	MAX(survival_months_estimate) AS MaximumSurvivalMonths,
	MIN(survival_months_estimate) AS MinimunSurvivalMonths,
	AVG(survival_months_estimate) AS AverageSurvivalMonths,
	STDEV(survival_months_estimate) AS StandarddDeviationSurvivalMonths
FROM
	outcomes;
/*
MaximumSurvivalMonths	MinimunSurvivalMonths	AverageSurvivalMonths	StandarddDeviationSurvivalMonths
33						15						23						5.51349568192763
*/

SELECT
	MAX(age) AS MaximumAge,
	MIN(age) AS MinimunAge,
	AVG(age) AS AverageAge,
	STDEV(age) AS StandarddDeviationAge
FROM
	patients;

/*
MaximumAge	MinimunAge	AverageAge	StandarddDeviationAge
84			30			57			15.9099930508746
*/

SELECT
	MAX(quantity_days) AS MaximumQtyDays,
	MIN(quantity_days) AS MinimunQtyDays,
	AVG(quantity_days) AS AverageQtyDays,
	STDEV(quantity_days) AS StandarddDeviationQtyDays
FROM
	refills;
/*
MaximumQtyDays	MinimunQtyDays	AverageQtyDays	StandarddDeviationQtyDays
30				21				26				3.88333446461282
*/

SELECT
	outcome_score,
	COUNT(*) AS Distributions
FROM
	outcomes
GROUP BY
	outcome_score
ORDER BY
	COUNT(*);

	/*
outcome_score	Distributions
48	1
67	35
69	40
68	40
82	42
73	42
72	46
81	46
75	47
65	47
70	48
77	49
66	50
74	53
79	55
78	55
76	57
71	59
83	61
80	63
84	64
*/

SELECT
	survival_months_estimate,
	COUNT(*) AS Distributions
FROM
	outcomes
GROUP BY
	survival_months_estimate
ORDER BY
	COUNT(*);

/*
survival_months_estimate	Distributions
16	40
26	41
25	42
23	45
31	47
32	49
22	50
19	52
33	53
21	53
17	56
28	56
20	57
29	57
18	59
27	59
24	61
30	61
15	62
*/

SELECT
	age,
	COUNT(*) AS Distributions
FROM
	patients
GROUP BY
	age
ORDER BY
	COUNT(*) DESC;

/*
age	Distributions
62	27
64	26
57	26
61	25
78	24
82	23
68	23
53	22
83	22
30	22
66	22
55	22
52	21
45	21
34	21
54	21
80	20
37	20
77	20
31	20
32	20
81	20
41	20
65	19
73	19
58	19
46	19
74	19
76	18
84	18
59	17
48	17
40	16
51	16
42	16
50	16
38	16
63	15
69	15
79	15
56	15
33	15
70	15
71	15
39	14
35	14
43	14
49	14
44	14
67	13
36	13
47	13
60	13
75	11
72	9
*/

SELECT
	comorbidities,
	COUNT(*) AS Distributions
FROM
	patients
GROUP BY
	comorbidities
ORDER BY
	COUNT(*) DESC;

/*
comorbidities	Distributions
Diabetes	263
CKD	263
Hypertension	246
None	228
*/

-- Step 2: Standardize data formats: I feel there is no need


--Step 3: Remove dupliates

SELECT
	hcp_id,
	COUNT(*)
FROM
	hcp
GROUP BY
	hcp_id
HAVING
	COUNT(*)>1;

SELECT
	patient_id,
	COUNT(*)
FROM
	outcomes
GROUP BY
	patient_id
HAVING
	COUNT(*)>1;

SELECT
	patient_id,
	COUNT(*)
FROM
	patients
GROUP BY
	patient_id
HAVING
	COUNT(*)>1;

SELECT
	rx_id,
	COUNT(*)
FROM
	prescriptions
GROUP BY
	rx_id
HAVING
	COUNT(*)>1;

SELECT
	refill_id,
	COUNT(*)
FROM
	refills
GROUP BY
	refill_id
HAVING
	COUNT(*)>1;
/*
refill_id	(No column name)
RF4101100	2
*/

SELECT * FROM refills WHERE refill_id = 'RF4101100';
SELECT * FROM refills WHERE patient_id = 'P00016';
SELECT * FROM refills WHERE patient_id = 'P00446';

select * from prescriptions
where patient_id = 'P00016' or patient_id = 'P00446';

select * from hcp
where hcp_id = 'HCP023' or hcp_id = 'HCP015';

/*
rx_id	patient_id	hcp_id	start_date
RX000016	P00016	HCP023	2025-02-26
RX000446	P00446	HCP015	2025-02-12

hcp_id	name	specialty	region
HCP015	Dr_15	Hematology-Oncology	West
HCP023	Dr_23	Hematology-Oncology	North
*/

-- created refill event so that each row can have unique ids
SELECT 
    ROW_NUMBER() OVER (ORDER BY patient_id, refill_date) AS refill_event_id,
    refill_id,
    patient_id,
    rx_id,
    refill_date,
    quantity_days
FROM 
	refills;

-- Basic QC
SELECT 
	*,
	CASE
	WHEN gap_days IS NULL THEN 'First Refill'
	WHEN gap_days<0 THEN 'Overlap Supply'
	WHEN gap_days >30 THEN 'Possible Discontinuation'
	ELSE 'Normal'
	END AS 'QC Flag'
FROM(
SELECT 
	*,
	DATEADD(day, quantity_days,refill_date) as refill_end_date,
	LAG(DATEADD(day,quantity_days, refill_date))
	OVER(PARTITION BY patient_id ORDER BY refill_date) as prev_refill_date,
	DATEDIFF(day, LAG(DATEADD(day,quantity_days, refill_date))
	OVER(PARTITION BY patient_id ORDER BY refill_date),refill_date) as gap_days
FROM
	refills) t;

-- Step 4: Nulls

SELECT
	*
FROM
	hcp
WHERE hcp_id is null;

SELECT
	*
FROM
	outcomes
WHERE patient_id is null;

SELECT
	*
FROM
	patients
WHERE patient_id is null;

SELECT
	*
FROM
	prescriptions
WHERE rx_id is null;

SELECT
	*
FROM
	refills
WHERE refill_id is null;

-- no nulls

-- Step 5: Standardize string variables

-- no need

-- Step 6: Save Clean Data

SELECT 
	*,
	CASE
	WHEN gap_days IS NULL THEN 'First Refill'
	WHEN gap_days<0 THEN 'Overlap Supply'
	WHEN gap_days >30 THEN 'Possible Discontinuation'
	ELSE 'Normal'
	END AS QC_Flag
INTO Refill_Cleaned
FROM(
SELECT 
	*,
	ROW_NUMBER() OVER (ORDER BY patient_id, refill_date) AS refill_event_id,
	DATEADD(day, quantity_days,refill_date) as refill_end_date,
	LAG(DATEADD(day,quantity_days, refill_date))
	OVER(PARTITION BY patient_id ORDER BY refill_date) as prev_refill_date,
	DATEDIFF(day, LAG(DATEADD(day,quantity_days, refill_date))
	OVER(PARTITION BY patient_id ORDER BY refill_date),refill_date) as gap_days
FROM
	refills) t;