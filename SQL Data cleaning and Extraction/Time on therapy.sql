WITH ordered_refills AS (
    SELECT
        r.patient_id,
        CONVERT(date, r.refill_date) AS refill_date,
        CAST(r.quantity_days AS INT) AS quantity_days,
        LAG(CONVERT(date, r.refill_date)) OVER (PARTITION BY r.patient_id ORDER BY CONVERT(date, r.refill_date)) AS prev_refill_date,
        LAG(CAST(r.quantity_days AS INT)) OVER (PARTITION BY r.patient_id ORDER BY CONVERT(date, r.refill_date)) AS prev_quantity_days
    FROM refills r
    WHERE CONVERT(date, r.refill_date) BETWEEN '2025-05-01' AND '2025-10-31'
),
gaps AS (
    SELECT
        patient_id,
        refill_date,
        prev_refill_date,
        prev_quantity_days,
        CASE 
            WHEN prev_refill_date IS NULL THEN NULL
            ELSE DATEDIFF(
                   day,
                   DATEADD(day, prev_quantity_days, prev_refill_date),  -- end of previous coverage
                   refill_date                                         -- current refill date
                 )
        END AS gap_days
    FROM ordered_refills
)
SELECT TOP (200)
    g.patient_id,
    MIN(g.refill_date) AS first_fill,
    MAX(g.refill_date) AS last_fill,
    MAX(CASE WHEN gap_days > 30 THEN 1 ELSE 0 END) AS discontinued_flag,
    DATEDIFF(day, MIN(g.refill_date), MAX(g.refill_date)) + 1 AS time_on_therapy_days
FROM gaps g
GROUP BY g.patient_id
ORDER BY time_on_therapy_days DESC;


/*
patient_id	first_fill	last_fill	discontinued_flag	time_on_therapy_days
2.00	2025-06-30	2025-10-23	0	116
3.00	2025-10-04	2025-10-27	0	24
4.00	2025-08-23	2025-08-23	0	1
5.00	2025-09-14	2025-09-14	0	1
1.00	2025-10-21	2025-10-21	0	1
*/
