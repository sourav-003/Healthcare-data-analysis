CREATE DATABASE healthcare;
USE healthcare;
CREATE TABLE Patients (
    Id VARCHAR(36) PRIMARY KEY,
    BIRTHDATE DATE NOT NULL,
    DEATHDATE DATE NULL,
    PREFIX VARCHAR(10),
    FIRST VARCHAR(50) NOT NULL,
    LAST VARCHAR(50) NOT NULL,
    SUFFIX VARCHAR(10),
    MAIDEN VARCHAR(50),
    MARITAL VARCHAR(10),
    RACE VARCHAR(20),
    ETHNICITY VARCHAR(20),
    GENDER CHAR(1) NOT NULL,
    BIRTHPLACE VARCHAR(100),
    ADDRESS VARCHAR(100),
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    COUNTY VARCHAR(50),
    ZIP VARCHAR(10),
    LAT DECIMAL(9,6),
    LON DECIMAL(9,6)
);
CREATE TABLE Payers (
    Id VARCHAR(100) PRIMARY KEY,  -- Increased length from 50 to 50+
    NAME VARCHAR(255) NOT NULL,
    ADDRESS VARCHAR(255) NULL,
    CITY VARCHAR(100) NULL,
    STATE_HEADQUARTERED VARCHAR(10) NULL,
    ZIP VARCHAR(10) NULL,  
    PHONE VARCHAR(20) NULL
);
CREATE TABLE encounters (
    Id VARCHAR(100) PRIMARY KEY,
    START DATETIME,
    STOP DATETIME,
    PATIENT VARCHAR(100),
    ORGANIZATION VARCHAR(100),
    PROVIDER VARCHAR(100),
    PAYER VARCHAR(100),
    ENCOUNTERCLASS VARCHAR(50),
    CODE VARCHAR(50),
    DESCRIPTION TEXT,
    BASE_ENCOUNTER_COST DECIMAL(10,2),
    TOTAL_CLAIM_COST DECIMAL(10,2),
    PAYER_COVERAGE DECIMAL(10,2),
    REASONCODE VARCHAR(50),
    REASONDESCRIPTION TEXT
);
ALTER TABLE encounters DROP COLUMN PROVIDER;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/encounters_cleaned.csv'
INTO TABLE encounters
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
TRUNCATE TABLE organizations;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_payers.csv'
INTO TABLE payers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE IF NOT EXISTS organizations (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    lat DECIMAL(9,6),
    lon DECIMAL(9,6)
);
INSERT INTO organizations (id, name, address, city, state, zip, lat, lon) 
VALUES 
('d78e84ec-30aa-3bba-a33a-f29a3a454662', 
 'MASSACHUSETTS GENERAL HOSPITAL', 
 '55 FRUIT STREET', 
 'BOSTON', 
 'MA', 
 '02114', 
 42.362813, 
 -71.069187);
 
 CREATE TABLE IF NOT EXISTS patients (
    id VARCHAR(50) PRIMARY KEY,
    birthdate DATE NOT NULL,
    deathdate VARCHAR(10), -- 'N/A' for alive patients
    prefix VARCHAR(10),
    first VARCHAR(100) NOT NULL,
    last VARCHAR(100) NOT NULL,
    suffix VARCHAR(10) DEFAULT 'N/A',
    maiden VARCHAR(100) DEFAULT 'N/A',
    marital VARCHAR(20) DEFAULT 'Unknown',
    race VARCHAR(50),
    ethnicity VARCHAR(50),
    gender VARCHAR(20) NOT NULL,
    birthplace VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    county VARCHAR(100),
    zip VARCHAR(10) DEFAULT '00000',
    lat DECIMAL(9,6),
    lon DECIMAL(9,6)
);
 
 LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_patients.csv'
INTO TABLE patients
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, birthdate, deathdate, prefix, first, last, suffix, maiden, marital, race, 
 ethnicity, gender, birthplace, address, city, state, county, zip, lat, lon);

SELECT COUNT(*) FROM patients;

CREATE TABLE procedures (
    start DATETIME NOT NULL,
    stop DATETIME NOT NULL,
    patient VARCHAR(50) NOT NULL,
    encounter VARCHAR(50) NOT NULL,
    code VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,   -- ❌ No Default Value for TEXT
    base_cost DECIMAL(10,2) NOT NULL,
    reasoncode VARCHAR(20) DEFAULT 'N/A',
    reasondescription TEXT        -- ❌ No Default Value for TEXT
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_procedures.csv'
INTO TABLE procedures
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- Step 1: Add Primary Keys to `organizations` and `payers`
ALTER TABLE organizations 
ADD CONSTRAINT pk_organizations PRIMARY KEY (id);

ALTER TABLE payers 
ADD CONSTRAINT pk_payers PRIMARY KEY (id);

--  Step 2: Add Foreign Key to `encounters` (Linking to `patients`)
ALTER TABLE encounters 
ADD CONSTRAINT fk_encounter_patient 
FOREIGN KEY (patient) REFERENCES patients(id) 
ON UPDATE CASCADE;

--  Step 3: Add Foreign Key to `encounters` (Linking to `organizations`)
ALTER TABLE encounters 
ADD CONSTRAINT fk_encounter_organization 
FOREIGN KEY (organization) REFERENCES organizations(id) 
ON UPDATE CASCADE;


--  Step 4: Add Foreign Key to `encounters` (Linking to `payers`)
ALTER TABLE encounters 
ADD CONSTRAINT fk_encounter_payer 
FOREIGN KEY (payer) REFERENCES payers(id) 
ON UPDATE CASCADE;

--  Step 5: Add Foreign Keys to `procedures` (Linking to `patients` and `encounters`)
ALTER TABLE procedures 
ADD CONSTRAINT fk_procedure_patient 
FOREIGN KEY (patient) REFERENCES patients(id) 
ON UPDATE CASCADE;

ALTER TABLE procedures 
ADD CONSTRAINT fk_procedure_encounter 
FOREIGN KEY (encounter) REFERENCES encounters(id) 
ON UPDATE CASCADE;
-- Check for NULL values
SELECT * FROM patients WHERE id IS NULL;
SELECT * FROM encounters WHERE patient IS NULL;
SELECT * FROM procedures WHERE encounter IS NULL;

-- Check for duplicates
SELECT id, COUNT(*) FROM patients GROUP BY id HAVING COUNT(*) > 1;
SELECT id, COUNT(*) FROM encounters GROUP BY id HAVING COUNT(*) > 1;
DELETE FROM patients
WHERE id IS NULL
AND birthdate IS NULL
AND deathdate IS NULL
AND prefix IS NULL
AND first IS NULL
AND last IS NULL
AND suffix IS NULL
AND maiden IS NULL
AND marital IS NULL
AND race IS NULL
AND ethnicity IS NULL
AND gender IS NULL
AND birthplace IS NULL
AND address IS NULL
AND city IS NULL
AND state IS NULL
AND county IS NULL
AND zip IS NULL
AND lat IS NULL
AND lon IS NULL;
DELETE FROM encounters
WHERE Id IS NULL
AND START IS NULL
AND STOP IS NULL
AND PATIENT IS NULL
AND ORGANIZATION IS NULL
AND PAYER IS NULL
AND ENCOUNTERCLASS IS NULL
AND CODE IS NULL
AND DESCRIPTION IS NULL
AND BASE_ENCOUNTER_COST IS NULL
AND TOTAL_CLAIM_COST IS NULL
AND PAYER_COVERAGE IS NULL
AND REASONCODE IS NULL
AND REASONDESCRIPTION IS NULL;

-- SQL Analysis Tasks
-- (a) Evaluating Financial Risk by Encounter Outcome
-- Objective: Identify high-risk ReasonCodes based on uncovered costs.
-- 	Find the difference between TotalClaimCost and PayerCoverage.
SELECT reasoncode, 
       SUM(total_claim_cost - payer_coverage) AS uncovered_cost
FROM encounters
GROUP BY reasoncode
ORDER BY uncovered_cost DESC
LIMIT 5;

-- (b) Identifying Patients with Frequent High-Cost Encounters
-- Objective: Find patients with more than 3 encounters in a year where each costs above $10,000.
SELECT patient, COUNT(id) AS encounter_count, SUM(total_claim_cost) AS total_cost
FROM encounters
WHERE total_claim_cost > 10000
GROUP BY patient
HAVING encounter_count > 3;

-- (c) Identifying Risk Factors Based on Demographics and Diagnosis Codes
-- Objective: Find the top 3 most frequent diagnosis codes and analyze affected demographics.
SELECT p.gender, 
       TIMESTAMPDIFF(YEAR, p.birthdate, CURDATE()) AS age, 
       e.reasoncode, 
       COUNT(*) AS frequency
FROM encounters e
JOIN patients p ON e.patient = p.id
WHERE e.reasoncode IS NOT NULL
GROUP BY p.gender, age, e.reasoncode
ORDER BY frequency DESC
LIMIT 3;

-- (d) Assessing Payer Contributions for Different Procedure Types
-- Objective: Compare payer contributions to total claim costs across procedures.
SELECT COUNT(*) FROM patients;
SELECT COUNT(*) FROM encounters;
SELECT pr.code, 
       SUM(e.payer_coverage) AS total_payer_coverage, 
       SUM(e.total_claim_cost) AS totalclaimcost
FROM procedures pr
JOIN encounters e ON pr.encounter = e.id
GROUP BY pr.code
ORDER BY total_payer_coverage DESC;

-- (e) Identifying Patients with Multiple Procedures Across Encounters
-- Objective: Find patients who had multiple procedures in different encounters for the same diagnosis.
SELECT patient, reasoncode, COUNT(DISTINCT encounter) AS encounter_count
FROM procedures
GROUP BY patient, reasoncode
HAVING encounter_count > 1;

-- (f) Analyzing Patient Encounter Duration
-- Objective: Identify organizations with encounters exceeding 24 hours.
SELECT organization, encounterclass, AVG(TIMESTAMPDIFF(HOUR, start, stop)) AS avg_duration
FROM encounters
GROUP BY organization, encounterclass
HAVING avg_duration > 24;












































