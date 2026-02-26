WITH window_refills AS (
    SELECT patient_id,
           SUM(quantity_days) AS total_quantity_days
    FROM refills
    WHERE refill_date BETWEEN '2025-05-01' AND '2025-10-31'
    GROUP BY patient_id
)
SELECT TOP (5)
    w.patient_id,
    w.total_quantity_days,
    d.window_days,
    ROUND(CAST(w.total_quantity_days AS decimal(12,6)) / d.window_days, 3) AS MPR,
    ROUND(
        CASE 
            WHEN CAST(w.total_quantity_days AS decimal(12,6)) / d.window_days > 1 
                THEN 1.0 
            ELSE CAST(w.total_quantity_days AS decimal(12,6)) / d.window_days 
        END
    , 3) AS PDC_approx
FROM window_refills w
CROSS APPLY (SELECT DATEDIFF(day, '2025-05-01', '2025-10-31') + 1 AS window_days) d
ORDER BY PDC_approx DESC;

/*
patient_id	total_quantity_days	window_days	MPR	PDC_approx
2.00	150	184	0.81500000000000000	0.81500000000000000
3.00	42	184	0.22800000000000000	0.22800000000000000
5.00	28	184	0.15200000000000000	0.15200000000000000
4.00	28	184	0.15200000000000000	0.15200000000000000
1.00	28	184	0.15200000000000000	0.15200000000000000
*/

