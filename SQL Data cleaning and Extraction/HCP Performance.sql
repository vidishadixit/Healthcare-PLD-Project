SELECT TOP 10 * FROM hcp;
SELECT TOP 10 * FROM prescriptions;
SELECT TOP 10 * FROM vw_Patient_Adherence;


WITH starts AS (
    SELECT
        pr.hcp_id,
        pr.patient_id,
		pr.rx_id
    FROM prescriptions pr
    WHERE pr.start_date BETWEEN '2025-05-01' AND '2025-10-31'
    GROUP BY pr.hcp_id, pr.patient_id, pr.rx_id
)
SELECT TOP (10)
    h.hcp_id,
    h.name,
    COUNT(DISTINCT s.patient_id) AS new_starts,
    ROUND(AVG(a.pdc), 3) AS avg_pdc_of_new_starts,
    ROUND(AVG(o.outcome_score), 1) AS avg_outcome_score_of_new_starts,
	AVG(CASE WHEN a.PDC >= 0.8 THEN 1.0 ELSE 0 END) AS adherence_rate
FROM hcp h
LEFT JOIN starts s ON s.hcp_id = h.hcp_id
LEFT JOIN vw_Patient_Adherence a ON a.rx_id = s.rx_id
LEFT JOIN outcomes o ON o.patient_id = s.patient_id
GROUP BY h.hcp_id, h.name
ORDER BY new_starts DESC;


/*
hcp_id	name	new_starts	avg_pdc_of_new_starts	avg_outcome_score_of_new_starts
HCP031	Dr_31	7	0.669	75
HCP054	Dr_54	6	0.668	76
HCP062	Dr_62	6	0.518	71
HCP089	Dr_89	6	0.478	69
HCP100	Dr_100	6	0.77	75
HCP144	Dr_144	6	0.651	77
HCP147	Dr_147	5	0.649	75
HCP121	Dr_121	5	0.842	74
HCP122	Dr_122	5	0.603	68
HCP124	Dr_124	5	0.787	73
*/