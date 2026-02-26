
use HealthcarePLD;

-- working view linking patient → prescription → last refill
CREATE VIEW vw_patient_rx_refill AS
SELECT
  p.patient_id,
  p.age,
  p.gender,
  p.primary_region,
  p.comorbidities,
  pr.rx_id,
  pr.hcp_id,
  pr.drug,
  pr.dose_mg,
  pr.start_date,
  r.refill_id,
  r.refill_date,
  r.quantity_days,
  r.refill_number
FROM patients p
JOIN prescriptions pr ON p.patient_id = pr.patient_id
LEFT JOIN refills r ON pr.rx_id = r.rx_id;

select * from vw_patient_rx_refill