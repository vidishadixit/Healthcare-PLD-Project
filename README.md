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

Average patient adherence (PDC) over a 180-day observation window was 0.66, with 25.9% of patients meeting the adherence threshold (PDC ≥ 0.8). 
Physician-level analysis revealed substantial variation in adherence outcomes, with some HCPs achieving adherence rates above 60–75%, while others with larger patient panels showed rates below 35%.

1. Adherence Analysis (MPR/PDC Calculation)

 Calculated:

  a. MPR (Medication Possession Ratio)

SQL:

SELECT 
  patient_id,
  CAST(SUM(quantity_days) AS FLOAT) /
    NULLIF(DATEDIFF(day,
                    MIN(refill_date),
                    MAX(refill_end_date)),0) AS MPR
FROM 
   refills
GROUP BY 
   patient_id;
   
b. PDC (Proportion of Days Covered)

   CASE 
        WHEN CAST(SUM(quantity_days) AS FLOAT) /
             NULLIF(180,0) > 1
        THEN 1
        ELSE CAST(SUM(quantity_days) AS FLOAT) /
             NULLIF(180,0)
    END AS PDC
 
   c. Ever discontinued from medications
   

2. Persistence Analysis (Time on Therapy)
 Defined persistence as gap > 30 days → patient considered discontinued.
CASE 
        WHEN MAX(CASE WHEN gap_days > 30 THEN 1 ELSE 0 END) = 1
        THEN 1
        ELSE 0
    END AS ever_discontinued

3. HCP Performance Profiling

Created HCP segmentation based on:

 a. of new starts: COUNT(DISTINCT s.patient_id) AS new_starts

 b. adherence of their patients: AVG(CASE WHEN a.PDC >= 0.8 THEN 1.0 ELSE 0 END) AS adherence_rate

 c. outcomes vs peers: ROUND(AVG(o.outcome_score), 1) AS avg_outcome_score_of_new_starts,

During the May–October 2025 observation window, physicians initiated therapy for varying numbers of patients. Average adherence (PDC) ranged from 0.48 to 0.79 across HCPs. Some physicians, such as Dr_41, demonstrated higher adherence levels among their patients, while others showed lower persistence rates. Adherence rates ranged from 0% to 50%, indicating significant variation in patient medication persistence.

4. Patient Outcomes Analysis
Merged outcome data with adherence:
CASE
        WHEN p.PDC < 0.5 THEN 'Low adherence'
        WHEN p.PDC < 0.8 THEN 'Moderate adherence'
        ELSE 'High adherence'
    END AS adherence_group,
    COUNT(*) AS patients,
    AVG(o.hospitalization_flag*1.0) AS hospitalization_rate,
    AVG(o.outcome_score) AS avg_outcome
   
Patients with low medication adherence demonstrated the highest hospitalization rate (54.9%), compared to patients with moderate (47.1%) and high adherence (46.7%). This suggests that poorer medication adherence may be associated with increased hospitalization risk.

6. Created Excel QC sheets to validate anomalies

7. Storytelling Dashboard (Power BI)

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
