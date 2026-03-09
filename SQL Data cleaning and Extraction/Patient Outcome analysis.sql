
SELECT * FROM vw_Patient_Adherence

SELECT
	o.patient_id,
	p.PDC,
	AVG(o.outcome_score) as avg_score
FROM 
	outcomes o
JOIN vw_Patient_Adherence p
ON o.patient_id = p.patient_id
where o.hospitalization_flag = 0
GROUP BY o.patient_id, p.PDC
HAVING p.PDC > 0.8;

-- 138 out of 1000 are highly adherent non hospitalised stable patients

SELECT
    o.hospitalization_flag,
    COUNT(*) AS patients,
    AVG(p.PDC) AS avg_pdc,
    AVG(o.outcome_score) AS avg_outcome
FROM outcomes o
JOIN vw_Patient_Adherence p
ON o.patient_id = p.patient_id
GROUP BY o.hospitalization_flag;

/*
hospitalization_flag	patients	avg_pdc	avg_outcome
0	511	0.671287236355728	75
1	489	0.653851397409678	74
*/

SELECT
    CASE
        WHEN p.PDC < 0.5 THEN 'Low adherence'
        WHEN p.PDC < 0.8 THEN 'Moderate adherence'
        ELSE 'High adherence'
    END AS adherence_group,
    COUNT(*) AS patients,
    AVG(o.hospitalization_flag*1.0) AS hospitalization_rate,
    AVG(o.outcome_score) AS avg_outcome
FROM vw_Patient_Adherence p
JOIN outcomes o
ON p.patient_id = o.patient_id
GROUP BY
    CASE
        WHEN p.PDC < 0.5 THEN 'Low adherence'
        WHEN p.PDC < 0.8 THEN 'Moderate adherence'
        ELSE 'High adherence'
    END
ORDER BY adherence_group;

/*
adherence_group	patients	hospitalization_rate	avg_outcome
High adherence				259	0.467181			75
Low adherence				244	0.549180			74
Moderate adherence			497	0.470824			75
*/