
-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT p1.npi, SUM(total_claim_count) AS total_claim_count
FROM prescriber p1
LEFT JOIN prescription p2
USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY p1.npi
ORDER BY total_claim_count DESC
LIMIT 20;

--ANSWER:prescriber w/ npi#: 1881634483	w/ a total of 99707 claims
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT 
	p1.npi, 
	p1.nppes_provider_first_name, 
	p1.nppes_provider_last_org_name,    							
	p1.specialty_description, 
	SUM(p2.total_claim_count) AS total_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
WHERE p2.total_claim_count IS NOT NULL
GROUP BY p1.npi,
	p1.nppes_provider_first_name, 																p1.nppes_provider_last_org_name,
	p1.specialty_description
ORDER BY SUM(p2.total_claim_count) DESC
LIMIT 20;	

--ANSWER: Bruce Pendley (Family Practice)

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS sum_of_claim_count
FROM prescriber p1
LEFT JOIN prescription p2
USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY sum_of_claim_count DESC;

--ANSWER: Family Practice

--     b. Which specialty had the most total number of claims for opioids?
-- SELECT *
-- FROM drug
SELECT specialty_description, SUM(total_claim_count) AS sum_of_claim_count
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
LEFT JOIN drug
USING (drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

--ANSWER: Nurse Practitioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, CAST(total_drug_cost AS money)
FROM prescription
LEFT JOIN drug
USING (drug_name)
ORDER BY  total_drug_cost DESC
LIMIT 50;

--ANSWER: "PIRFENIDONE"	"$2,829,174.30"

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


SELECT d.generic_name, CAST(ROUND(SUM(p.total_drug_cost)/SUM(p.total_day_supply),2) AS money) AS cost_per_day
FROM prescription AS p
LEFT JOIN drug AS d
USING (drug_name)
GROUP BY d.generic_name
ORDER BY  cost_per_day DESC
LIMIT 50;

--ANSWER: "C1 ESTERASE INHIBITOR"	$3,495.22

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
		CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
				WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
				ELSE 'neither' END AS drug_type
FROM drug;




--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
		(CASE WHEN d.opioid_drug_flag ='Y' THEN 'opioid'
				WHEN d.antibiotic_drug_flag ='Y' THEN 'antibiotic'
				ELSE 'neither' END) AS drug_type, CAST(SUM(p.total_drug_cost) AS money) AS total_drug_cost
FROM drug AS d
LEFT JOIN prescription AS p
USING (drug_name)
WHERE opioid_drug_flag = 'Y' OR antibiotic_drug_flag ='Y'
GROUP BY d.antibiotic_drug_flag,d.opioid_drug_flag
ORDER BY total_drug_cost DESC;

--ANSWER: More money spent on opioids at $105,080,626.37 compared to antibiotics at $38,435,121.26

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(cbsa)
FROM cbsa
WHERE cbsaname iLIKE '%TN%'

--ANSWER 58

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsaname, SUM(p.population) AS sum_of_pop
FROM cbsa AS c
LEFT JOIN population AS p
USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY sum_of_pop DESC;

--ANSWER: largest combined population:"Nashville-Davidson--Murfreesboro--Franklin, TN"	1830410

SELECT cbsaname, SUM(p.population) AS sum_of_pop
FROM cbsa AS c
LEFT JOIN population AS p
USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY sum_of_pop;

--ANSWER: smallest combined population: "Morristown, TN"	116352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT cbsa, county, p.population
FROM population AS p
FULL JOIN fips_county AS f
USING (fipscounty)
FULL JOIN cbsa
USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsa, county, p.population
ORDER BY p.population DESC;

--ANSWER: SEVIER county with population of: 95523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.



SELECT drug_name, SUM(total_claim_count) AS sum_of_claims
FROM prescription
GROUP BY npi, drug_name
HAVING SUM(total_claim_count)>=3000
ORDER BY sum_of_claims DESC;


--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.


SELECT p.drug_name, total_claim_count,
	CASE WHEN d.opioid_drug_flag= 'Y' THEN 'Y'
	ELSE 'N' END AS opioid
FROM prescription AS p
LEFT JOIN drug AS d
USING (drug_name)
GROUP BY p.npi, p.drug_name, p.total_claim_count,d.opioid_drug_flag
HAVING SUM(p.total_claim_count)>=3000
ORDER BY p.total_claim_count DESC
LIMIT 9;


--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT p2.nppes_provider_last_org_name,p2.nppes_provider_first_name, p.drug_name, total_claim_count,
	CASE WHEN d.opioid_drug_flag= 'Y' THEN 'Y'
	ELSE 'N' END AS opioid
FROM prescription AS p
LEFT JOIN drug AS d
USING (drug_name)
LEFT JOIN prescriber AS p2
ON p.npi=p2.npi
GROUP BY p.npi, p.drug_name, p.total_claim_count,d.opioid_drug_flag,p2.nppes_provider_last_org_name,p2.nppes_provider_first_name
HAVING SUM(p.total_claim_count)>=3000
ORDER BY p.total_claim_count DESC
LIMIT 9;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber AS p
CROSS JOIN drug AS d
WHERE p.specialty_description = 'Pain Management'
	AND p.nppes_provider_city = 'NASHVILLE'
	AND d.opioid_drug_flag = 'Y';
	

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT p.npi, d.drug_name, p2.total_claim_count
FROM prescriber AS p
CROSS JOIN drug AS d
LEFT JOIN prescription AS p2
ON p.npi=p2.total_claim_count
WHERE p.specialty_description = 'Pain Management'
	AND p.nppes_provider_city = 'NASHVILLE'
	AND d.opioid_drug_flag = 'Y';
	
SELECT p1.npi, p2.total_claim_count, d.drug_name
FROM prescriber p1
LEFT JOIN prescription p2
USING (npi)
CROSS JOIN drug AS d
WHERE p1.specialty_description = 'Pain Management'
	AND p1.nppes_provider_city = 'NASHVILLE'
	AND d.opioid_drug_flag = 'Y';
	


--clues 1 all about the 1st sentence, not a concept not talked about in class, and has to do with keys
---cross join? 
---key 
--left join prescription but the key being used is throwing ppl off 
--no aggregation
 --using 2 keys?
 
 
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.