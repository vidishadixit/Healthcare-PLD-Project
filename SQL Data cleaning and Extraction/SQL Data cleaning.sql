use HealthcarePLD


--row counts

select 'patients' as table_name, COUNT(*) as rows from patients
union all
select 'hcps' as table_name, count(*) as rows from hcps
union all
select 'outcomes' as table_name, COUNT(*) as rows from outcomes
union all
select 'prescriptions' as table_name, count(*) as rows from prescriptions
union all
select 'refills' as table_name, COUNT(*) as rows from refills

/*
table_name	rows
patients	10
hcps	10
outcomes	10
prescriptions	10
refills	10
*/

-- checking for missing keys

select
	sum(case when patient_id is null or patient_id = '' then 1 else 0 end) as missing_patient_Id_in_Patients
from
	patients

select
	sum(case when hcp_id is null or hcp_id = '' then 1 else 0 end) as missing_hcp_Id_in_HCPS
from
	hcps

select
	sum(case when patient_id is null or patient_id = '' then 1 else 0 end) as missing_patient_Id_in_Outcomes
from
	outcomes

select
	sum(case when patient_id is null or patient_id = '' then 1 else 0 end) as missing_patient_Id_in_prescriptions,
	sum(case when rx_id is null or rx_id = '' then 1 else 0 end) as mission_rx_id_in_prescriptions,
	sum(case when hcp_id is null or hcp_id = '' then 1 else 0 end) as missing_hcp_Id_in_prescriptions
from
	prescriptions

select
	sum(case when refill_id is null or refill_id = '' then 1 else 0 end) as missing_refill_id_in_Refills,
	sum(case when patient_id is null or patient_id = '' then 1 else 0 end) as missing_patient_Id_in_Refills
from
	refills

-- duplicate primary keys

select 
	patient_id, 
	count(*) as patient_count
from 
	patients
group by
	patient_id
having
	count(*) >1

select 
	hcp_id, 
	count(*) as hcp_id_count
from 
	hcps
group by
	hcp_id
having
	count(*) >1

select 
	rx_id, 
	count(*) as rx_id_count
from 
	prescriptions
group by
	rx_id
having
	count(*) >1

select 
	refill_id, 
	count(*) as refill_id_count
from 
	refills
group by
	refill_id
having
	count(*) >1

--date ranges
SELECT
  MIN(start_date) AS min_prescription_start,
  MAX(start_date) AS max_prescription_start
FROM prescriptions;
/*
min_prescription_start	max_prescription_start
2025-06-19	2025-10-21
*/

SELECT
  MIN(refill_date) AS min_refill_date,
  MAX(refill_date) AS max_refill_date
FROM refills;

/*
min_refill_date	max_refill_date
2025-06-30	2025-10-27
*/