WITH starts AS (
    SELECT
        pr.hcp_id,
        pr.patient_id
    FROM prescriptions pr
    WHERE CONVERT(date, pr.start_date) BETWEEN '2025-05-01' AND '2025-10-31'
    GROUP BY pr.hcp_id, pr.patient_id
),
patient_pdc AS (
    SELECT
        patient_id,
        CASE
            WHEN SUM(CAST(quantity_days AS decimal(12,6))) 
                 / (DATEDIFF(day, '2025-05-01', '2025-10-31') + 1) > 1
            THEN 1.0
            ELSE SUM(CAST(quantity_days AS decimal(12,6))) 
                 / (DATEDIFF(day, '2025-05-01', '2025-10-31') + 1)
        END AS pdc_est
    FROM refills
    WHERE CONVERT(date, refill_date) BETWEEN '2025-05-01' AND '2025-10-31'
    GROUP BY patient_id
)
SELECT TOP (100)
    h.hcp_id,
    h.name,
    COUNT(DISTINCT s.patient_id) AS new_starts,
    ROUND(AVG(p.pdc_est), 3) AS avg_pdc_of_new_starts,
    ROUND(AVG(o.outcome_score), 1) AS avg_outcome_score_of_new_starts
FROM hcps h
LEFT JOIN starts s ON s.hcp_id = h.hcp_id
LEFT JOIN patient_pdc p ON p.patient_id = s.patient_id
LEFT JOIN outcomes o ON o.patient_id = s.patient_id
GROUP BY h.hcp_id, h.name
ORDER BY new_starts DESC;


/*
hcp_id	name	new_starts	avg_pdc_of_new_starts	avg_outcome_score_of_new_starts
HCP0013	Dr. J_9	1	NULL	75
HCP0031	Dr. F_5	1	0.152000	73
HCP0048	Dr. C_2	1	0.815000	84
HCP0054	Dr. I_8	1	NULL	76
HCP0090	Dr. B_1	1	0.152000	72
HCP0098	Dr. A_10	1	NULL	82
HCP0125	Dr. D_3	1	0.228000	78
HCP0133	Dr. E_4	1	0.152000	48
HCP0135	Dr. H_7	1	NULL	65
HCP0142	Dr. G_6	1	NULL	76
*/