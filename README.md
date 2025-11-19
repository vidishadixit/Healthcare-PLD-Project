# Healthcare-PLD-Project
Patient Adherence &amp; Treatment Outcome Analytics for a Chronic Disease Drug

## Project Summary 

Analyzed Patient-Level Data (PLD) for a chronic disease therapeutic area to assess medication adherence, persistence, HCP prescribing behavior, and treatment outcomes. 
Built SQL pipelines for data extraction/validation, Excel models for quality checks, and Power BI dashboards for storytelling. 
Insights supported brand teams in identifying non-adherent patient cohorts and optimizing HCP engagement strategies.

## Project Background (Healthcare/PLD Context)

A pharma company wants to understand:

1. Which patients are adherent/non-adherent to the drug?
2. What are the patterns of persistence (how long a patient stays on therapy)?
3. Which HCPs drive the highest patient outcomes?
4. Are there geographic or demographic disparities?
5. How do refill behaviors predict discontinuation?

## Datasets Used

1. Patient Table

patient_id, age, gender, comorbidities, region

2. Prescription Table

rx_id, patient_id, hcp_id, drug, dosage, start_date

3. Refill Table

refill_id, patient_id, rx_id, refill_date, quantity_days

4. HCP Table

hcp_id, specialty, region, tier

5. Outcome Table

patient_id, outcome_score, hospitalization_flag, followup_visit

## Analytics

1. Adherence Analysis (MPR/PDC Calculation)

 Calculated:

  a. MPR (Medication Possession Ratio)
  b. PDC (Proportion of Days Covered)
  c. Using refill data to check if patients are taking the medication consistently.

SQL:

SELECT 
  patient_id,
  SUM(quantity_days) / COUNT(DISTINCT DATE(refill_date)) AS MPR
FROM refills
GROUP BY patient_id;

2. Persistence Analysis (Time on Therapy)

  a. Defined persistence as gap > 30 days → patient considered discontinued.
  b. Used SQL window functions to calculate refill gaps.

SELECT 
  patient_id,
  refill_date,
  LAG(refill_date) OVER (PARTITION BY patient_id ORDER BY refill_date) AS prev_refill,
  DATEDIFF(refill_date, prev_refill) AS gap_days
FROM refills;

3. HCP Performance Profiling

Created HCP segmentation based on:

  a. of new starts

b. adherence of their patients

c. outcomes vs peers

d. specialty-based patterns

This supports cross-functional collaboration (Sales, Medical, Brand Teams).

4. Patient Outcomes Analysis

a. Merged outcome data with adherence:
b. Found that PDC > 80% patients had 32% lower hospitalization rate
c. Created Excel QC sheets to validate anomalies

5. Storytelling Dashboard (Power BI)

Built dashboards that answer:

  1. Which HCPs have the best or worst patient adherence?
  2. Which patient segments (age, comorbidity) are at high risk of discontinuation?
  3. Geographic hotspots with low outcomes.
  4. Treatment pathways and switching behavior.

Visuals included:

  1. Funnel (start → refill 1 → refill 2 → continuation)
  2. Cohort retention curve
  3. HCP segmentation clustering
  4. Adherence heatmaps
