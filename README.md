# Healthcare Patient Encounter Cost and Risk Analysis

This repository contains the assets and documentation for the "Patient Encounter Cost and Risk Analysis in Healthcare Systems" capstone project. This business domain analysis project leverages SQL for robust data extraction and transformation, with key insights visualized through business intelligence tools like Power BI or Tableau. The core objective is to uncover patterns of high-cost healthcare utilization and identify potential financial risks, thereby providing actionable insights to healthcare providers for optimized resource allocation, patient care management, and financial planning.

## Project Overview

The healthcare industry continuously seeks strategies to manage costs, mitigate risks, and enhance patient care efficiently. This project directly addresses these challenges by performing a comprehensive analysis of patient encounter data, including procedure costs, payer contributions, and patient demographics. By identifying critical trends, financial exposures, and at-risk patient cohorts, this analysis aims to empower healthcare stakeholders with data-driven insights to improve operational efficiency, financial health, and overall patient outcomes.

**Project Goals:**
* To conduct a comprehensive analysis of patient encounters, procedure costs, and payer coverage to reveal patterns of high-cost healthcare utilization and potential financial risks.
* To provide actionable insights for healthcare providers to support informed decision-making in resource allocation, patient care management, and financial planning.

**Methodology:**
The project adheres to a structured data analysis methodology:
1.  **Data Setup & Preprocessing:** Healthcare datasets are loaded into a SQL database (MySQL), followed by meticulous data exploration, checking for missing values, and performing necessary data cleaning.
2.  **SQL-based Analysis:** Complex analysis is performed using SQL to extract specific insights across various dimensions of healthcare data.
3.  **Data Visualization:** Key findings and trends are translated into interactive dashboards using Power BI or Tableau, facilitating intuitive exploration and understanding for stakeholders.

## Data Model & Schema

The analysis is built upon a well-structured relational data model comprising five interconnected core tables within the `healthcare` database:

### 1. `Patients` Table
Stores detailed demographic information for each patient, including `Id`, `BIRTHDATE`, `DEATHDATE`, `FIRST` and `LAST` names, `GENDER`, `RACE`, `ETHNICITY`, `ADDRESS` details (`CITY`, `STATE`, `ZIP`), and geographical coordinates (`LAT`, `LON`).

### 2. `Payers` Table
Contains information about insurance providers, identified by `Id`, and includes `NAME`, `ADDRESS`, `CITY`, `STATE_HEADQUARTERED`, `ZIP`, and `PHONE` numbers.

### 3. `Encounters` Table
Records each patient's visit or interaction with the healthcare system. Key fields include `Id`, `START` and `STOP` timestamps for the encounter, `PATIENT` (foreign key to `Patients`), `ORGANIZATION` (foreign key to `Organizations`), `PAYER` (foreign key to `Payers`), `ENCOUNTERCLASS`, a `CODE` and `DESCRIPTION` for the encounter, `BASE_ENCOUNTER_COST`, `TOTAL_CLAIM_COST`, `PAYER_COVERAGE`, and `REASONCODE` with `REASONDESCRIPTION`.

### 4. `Organizations` Table
Details about healthcare organizations (hospitals, clinics), including `Id`, `NAME`, `ADDRESS` details (`CITY`, `STATE`, `ZIP`), geographical coordinates (`LAT`, `LON`), and `UTILIZATION` metrics.

### 5. `Procedures` Table
Information about medical procedures performed during encounters. Fields include `Id`, `DATE` of procedure, `PATIENT` (foreign key to `Patients`), `ENCOUNTER` (foreign key to `Encounters`), a `CODE` and `DESCRIPTION` for the procedure, `BASE_COST`, and `REASONCODE` with `REASONDESCRIPTION`.

## Key Analysis Areas & Insights

The project delves into several critical areas of healthcare operations and finance, with insights derived from detailed data analysis.

### 1. Evaluating Financial Risk by Encounter Outcome
* **Objective:** To identify high-risk reason codes based on uncovered costs and analyze the difference between total claim costs and payer coverage.
* **Analysis:** Focused on calculating the total and average costs associated with different encounter outcomes, and the gap between the `TOTAL_CLAIM_COST` and `PAYER_COVERAGE` for each `REASONCODE` from patient encounters.
* **Key Findings:**
    * **NULL Outcome:** Identified as having the highest total and average cost. This indicates a significant financial risk area and highlights a critical need for accurate classification of encounter outcomes to better manage costs.
    * **Expired Outcomes:** Showed expectedly high average costs and risk scores, reflecting the intense resources typically required for critical care leading to this outcome.
    * **Discharged to Home:** While contributing to a high total cost (due to high volume), its average cost and risk score were comparatively lower, consistent with more routine and less financially intensive care pathways.

### 2. Identifying Patients with Frequent High-Cost Encounters
* **Objective:** To identify patients with more than 3 encounters in a year where each encounter costs above $10,000.
* **Analysis:** Involved filtering patient encounters by a cost threshold (>$10,000) and then aggregating these high-cost encounters by patient within a year to count frequency.
* **Key Findings:**
    * The analysis successfully identified patients with exceptionally high total healthcare costs due to frequent high-cost encounters. For instance:
        * Patient `3f523789-55f3-bb31-2757-4803ca6a9c2a` accumulated a total cost of **$9,932,262.99**.
        * Patient `ff331e5c-ab16-e218-f39a-63e11de1ed75` incurred **$6,356,665.66**.
        * Patient `a733bbc1-cbdf-992f-f1b7-bd230028fc4f` had costs totaling **$3,014,121.02**.
    * These specific patients represent critical candidates for intensive care coordination and proactive interventions to manage future healthcare utilization and associated costs.

### 3. Identifying Risk Factors Based on Demographics and Diagnosis Codes
* **Objective:** To find the top 3 most frequent diagnosis codes and analyze the affected demographics.
* **Analysis:** Involved linking patient demographic information (gender, age) with their associated encounter reason codes (diagnosis codes) to identify the most frequent combinations.
* **Key Findings:**
    * Certain demographic segments, such as 96-year-old females, showed a disproportionately high frequency of encounters for specific (often unspecified or `NULL`) reason codes, indicating potential vulnerabilities.
    * Reason codes like 'N/A' or those left `NULL` frequently appeared across various demographic groups. This suggests either issues with data completeness in diagnosis recording or a prevalence of unclassified health conditions driving healthcare encounters.
    * These insights are crucial for guiding preventative care initiatives and developing effective patient risk stratification programs.

### 4. Assessing Payer Contributions for Different Procedure Types
* **Objective:** To compare payer contributions to total claim costs across various procedures.
* **Analysis:** Focused on aggregating `PAYER_COVERAGE` and `TOTAL_CLAIM_COST` from encounters, linked to specific procedures, to assess the financial contribution of payers for different procedure types.
* **Key Findings:**
    * Procedures with codes `180325003`, `274804006`, and `225158009` were associated with the highest total claim costs, with a significant portion typically covered by insurance payers.
    * The analysis revealed "uncovered gaps" – instances where payer coverage was low relative to the total cost of certain procedures. These gaps highlight potential revenue leakage for providers and opportunities for renegotiating payer contracts.

### 5. Identifying Patients with Multiple Procedures Across Encounters
* **Objective:** To find patients who had multiple procedures in different encounters for the same diagnosis.
* **Analysis:** Involved grouping procedure data by patient and the associated reason code (diagnosis), then identifying those groups where a patient had distinct encounters for the same reason code.
* **Key Findings:**
    * A significant number of patients exhibited recurrent encounters. Some individuals, like `Patient 0226f105-2572-1c6f-15f0-1aa0438e40d0`, were identified as having over 100 distinct encounters.
    * Patients with consistently high encounter counts, regardless of the specific reason codes, represent a cohort that could greatly benefit from enhanced care coordination and targeted chronic disease management strategies.

### 6. Analyzing Patient Encounter Duration
* **Objective:** To identify organizations with encounters exceeding an average duration of 24 hours.
* **Analysis:** Involved calculating the average duration of encounters (time difference between `START` and `STOP` timestamps) and grouping this by `ORGANIZATION` and `ENCOUNTERCLASS`.
* **Key Findings:**
    * **Inpatient Encounters:** Consistently demonstrated the longest average durations, directly reflecting the complex and intensive nature of inpatient care.
    * **Emergency Encounters:** Showed moderate durations, indicating immediate but generally not prolonged medical attention.
    * **Ambulatory/Outpatient Encounters:** Characterized by the shortest durations, consistent with routine visits and minor procedures.
    * Organizations whose average encounter durations exceeded 24 hours were identified, signaling potential areas for operational review and efficiency improvements.

### 7. Geographical Analysis of Encounters by Organization and Cost
* **Analysis:** Explored the distribution of total claim costs across various geographical locations and the healthcare organizations operating within those regions.
* **Key Findings:**
    * `Boston, MA`, emerged as the location with the highest total claim costs across multiple organizations, indicating a significant concentration of healthcare activity and expenditure in this metropolitan area.
    * Other cities like Everett, Hull, Brookline, Somerville, Cambridge, Weymouth, and Melrose also showed substantial contributions to overall healthcare costs.
    * This geographical data is invaluable for informing strategic resource allocation, guiding service expansion initiatives, and planning community health programs based on regional demand and cost profiles.

### 8. Procedure Cost Trend by Diagnosis
* **Analysis:** Examined how the base costs of specific medical procedures evolved over time when linked to different diagnoses.
* **Key Findings:**
    * **Atrial Fibrillation:** Showed a notable increase in base costs between 2011 and 2013, followed by a period of stabilization.
    * **Normal Pregnancy:** Maintained consistently high base costs with various fluctuations over the years.
    * **Oncology (Malignant Neoplasm of Breast/Colon, Lung Cancers):** Generally demonstrated increasing or fluctuating costs, reflecting ongoing treatment advancements, diagnostic procedures, and long-term care needs.
    * **Chronic Conditions (e.g., COPD, CHF):** Costs tended to increase over time, highlighting the sustained management burden associated with chronic diseases.
    * Continuous monitoring of these cost trends is essential for accurate financial forecasting, optimizing clinical pathways, and identifying areas for cost-efficiency improvements.

### 9. Uncovered Costs by Payer and Reason Code
* **Analysis:** Focused on identifying and breaking down healthcare costs that are not covered by insurance payers, categorizing these by the associated reason codes.
* **Key Findings:**
    * A large proportion of uncovered costs were associated with `NULL` reason codes, indicating critical data quality issues or unidentified reasons for non-coverage.
    * **Normal Pregnancy:** Despite often having high payer coverage, this condition also showed substantial uncovered costs, suggesting that specific services or complications related to pregnancy may not be fully reimbursed.
    * **Serious Conditions:** Conditions such as Sepsis, Malignant Neoplasms (Breast, Lung, Colon), Chronic Congestive Heart Failure, and Acute Bronchitis exhibited significant uncovered costs, pointing to potential gaps in insurance coverage or high out-of-pocket expenses for patients with severe illnesses.
    * These insights are crucial for enhancing revenue cycle management, improving patient financial counseling, and informing policy advocacy efforts to address coverage gaps.

### 10. Encounter Cost Distribution by Class
* **Analysis:** Provided a breakdown of total claim costs and base encounter costs across different encounter classes (e.g., Ambulatory, Urgent Care, Inpatient).
* **Key Findings:**
    * **Ambulatory Encounters:** Accounted for the highest total claim costs, likely attributable to the sheer volume of outpatient visits.
    * **Urgent Care:** Also showed significant total claim costs, underscoring its role in addressing immediate, non-emergency care needs.
    * **Inpatient Encounters:** While not always the highest in total claim cost (due to lower volume compared to ambulatory), they typically had significantly higher average base costs per encounter due to the complexity and intensity of care required.
    * Understanding this cost distribution across service lines is fundamental for effective resource allocation, targeted cost control initiatives, and strategic planning within healthcare facilities.

## Data Visualization & Dashboards

The insights derived from the analysis are translated into interactive dashboards, typically created using Power BI or Tableau. The planned dashboards are designed to provide intuitive and actionable views of the data:

* **Encounter Cost Distribution:** Visualizing the breakdown of costs by `EncounterClass`.
* **High-Cost Patient Identification:** Highlighting patients with high healthcare utilization patterns for targeted intervention.
* **Uncovered Costs Analysis:** Analyzing the contribution of uncovered costs, broken down by payers and reason codes.
* **Procedure Cost Trends:** Illustrating how procedure costs change over time for different diagnoses.
* **Geographical Analysis:** Identifying high-cost regions and their associated healthcare organizations to inform strategic planning.

## Recommendations & Next Steps

Based on the comprehensive analysis, the following recommendations are proposed to optimize healthcare operations, manage financial risks, and ultimately improve patient outcomes:

1.  **Data Quality Improvement:** Prioritize addressing `NULL` and unspecified reason codes in encounter outcomes, risk factors, and uncovered costs. This will ensure more accurate and reliable data for all future analyses and operational decisions.
2.  **Targeted Case Management:** Implement proactive case management programs specifically for patients identified with frequent and/or high-cost encounters. This can improve care coordination, reduce readmissions, and prevent future high-cost events.
3.  **Payer Contract Review:** Conduct thorough and regular analyses of payer contributions and uncovered costs for specific procedure types and diagnoses. This will help identify opportunities for negotiation with payers and improve overall revenue capture.
4.  **Clinical Pathway Optimization:** Review and optimize existing clinical pathways for high-cost diagnoses and long-duration encounter classes. The goal is to enhance efficiency, reduce unnecessary costs, and standardize care delivery.
5.  **Geographical Strategy:** Utilize the geographical cost data to inform strategic decisions regarding service expansion, facility planning, and community health initiatives, ensuring resources are aligned with regional demand and need.
6.  **Predictive Analytics:** Explore and develop predictive models capable of proactively identifying patients at risk of future high-cost encounters or poor health outcomes. Early identification allows for timely and effective intervention.
7.  **Regular Reporting:** Establish a consistent cadence for reviewing these key metrics and insights. Continuous monitoring will ensure ongoing improvement in financial management, risk mitigation, and the overall patient experience.

## Conclusion

This project provides a robust framework and actionable insights for healthcare systems to better understand and manage patient encounter costs and associated financial risks. By prioritizing data quality, implementing targeted interventions, and engaging in strategic planning informed by these analyses, healthcare providers can significantly enhance operational efficiency, optimize financial performance, and ultimately elevate the overall patient experience.

## Author

* **Sourav Kumar**

---

## 📬 Contact

For any queries or collaborations, reach out via GitHub: [@sourav-003](https://github.com/sourav-003)

