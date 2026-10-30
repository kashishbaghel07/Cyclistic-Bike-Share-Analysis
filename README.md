# Cyclistic Bike-Share Analysis

### A Data Analytics Case Study | Google Data Analytics Certificate

## 1. Project Overview

This project analyses bike-share usage data from Cyclistic, a fictional bike-share company based in Chicago.

The main objective is to understand how annual members and casual riders use Cyclistic bikes differently and identify opportunities to encourage casual riders to purchase annual memberships.

The analysis covers **1 September 2025 to 31 August 2026**, using 6,115,650 ride records.

## 2. Business Task

The marketing team wants to understand the differences between casual riders and annual members.

The analysis focuses on:

- How ride usage differs between casual riders and annual members.
- Differences in average ride duration.
- Daily, monthly and hourly ride patterns.
- Bike-type preferences.
- Popular starting stations.
- Opportunities to encourage casual riders to become annual members.

## 3. Tools and Technologies

| Tool | Purpose |
|---|---|
| Microsoft Excel (Power Query) | Data import, transformation and initial preparation |
| Python (Pandas) | Combining monthly files, removing duplicates and data cleaning |
| MySQL | Data storage, validation and SQL analysis |
| Power BI | Interactive dashboard and data visualization |

## 4. Project Workflow

The project follows the six steps of the data analysis process.

1. **Ask:** Define the business problem and analysis questions.
2. **Prepare:** Collect and inspect the monthly Cyclistic trip-data files.
3. **Process:** Prepare and clean the data using Excel Power Query and Python.
4. **Analyze:** Use MySQL queries to compare rider behaviour and identify patterns.
5. **Share:** Present findings through an interactive Power BI dashboard and final report.
6. **Act:** Suggest marketing strategies based on the analysis.

## 5. Data Preparation and Cleaning

### 5.1 Initial Data Preparation using Excel Power Query

Excel Power Query was used for the initial data preparation.

The work included:

- Importing and combining monthly Cyclistic CSV files.
- Reviewing and selecting the required columns.
- Renaming and transforming columns.
- Changing data types where required.
- Adding custom columns for analysis.
- Applying filters and removing records with zero or negative ride durations.
- Preparing the dataset for further analysis.

### 5.2 Data Cleaning using Python

Python and Pandas were used to combine the monthly CSV files and perform additional data cleaning.

The Python script performs the following operations:

1. Locates and reads the monthly CSV files.
2. Combines all monthly files into one dataset.
3. Checks the required columns.
4. Removes duplicate ride IDs.
5. Converts start and end timestamps into datetime format.
6. Calculates ride duration in minutes.
7. Removes zero or negative ride durations.
8. Creates analysis columns:
   - `day_of_week`
   - `start_hour`
   - `month`
   - `day_type`
9. Exports the cleaned dataset as `cyclistic_cleaned.csv`.

### Python Cleaning Results

| Cleaning Stage | Records |
|---|---:|
| Original records | 6,115,982 |
| After duplicate removal | 6,115,947 |
| After duration cleaning | 6,115,918 |

- Duplicate ride IDs removed: **35**
- Zero or negative duration records removed: **29**

The final prepared dataset contained **6,115,918 records**.

## 6. SQL Analysis using MySQL

The cleaned dataset generated through Python was imported into MySQL for further analysis.

The SQL analysis script is organized into 14 sections.

### SQL Analysis Performed

- Database and table creation.
- Importing the cleaned CSV dataset.
- Data exploration and validation.
- Checking missing values and duplicate ride IDs.
- Reviewing existing indexes and optional indexes.
- Comparing casual riders and annual members.
- Monthly, seasonal and hourly ride analysis.
- Bike-type preference analysis.
- Weekday and weekend comparisons.
- Identifying the top 10 starting stations for each rider group.
- Long-ride analysis and average-duration sensitivity.
- Generating final summary results for the report.
- Final validation of the reporting-period totals.

The SQL queries include comments and explanations to make the analysis easier to understand.

### Reporting Period

The full prepared dataset contains 6,115,918 records, including 268 rides from August 2025.

The main analysis covers **1 September 2025 to 31 August 2026**, excluding those 268 rides.

Therefore, the reporting-period total is **6,115,650 rides**.

## 7. Key Findings

### 7.1 Rides by Rider Type

| Rider Type | Total Rides | Percentage |
|---|---:|---:|
| Annual Members | 3,955,534 | 64.68% |
| Casual Riders | 2,160,116 | 35.32% |
| **Total** | **6,115,650** | **100%** |

### 7.2 Average Ride Duration

| Rider Type | Average Duration |
|---|---:|
| Casual Riders | 20.66 minutes |
| Annual Members | 12.37 minutes |

Casual riders take longer rides on average than annual members.

### 7.3 Weekday and Weekend Usage

- Casual riders have a higher weekend ride share of 37.26%.
- Annual members have a weekend ride share of 23.34%.
- Casual riders have a larger share of weekend rides than annual members.

### 7.4 Monthly Trends

- Casual rider activity peaks in July.
- Annual member activity peaks in August.

### 7.5 Bike-Type Preference

Electric bikes are the most-used bike type for both rider groups.

- Casual riders: 73.60% electric-bike share.
- Annual members: 68.06% electric-bike share.

### 7.6 Popular Starting Stations

- Most popular casual starting station: Navy Pier (51,740 rides).
- Most popular member starting station: Canal St & Madison St (23,179 rides).

## 8. Power BI Dashboard

An interactive Power BI dashboard was created to present the analysis findings.

The dashboard includes:

- Total rides and key performance indicators.
- Rider-type distribution.
- Monthly ride trends.
- Weekday and weekend comparisons.
- Hourly ride patterns.
- Average ride duration.
- Bike-type preferences.
- Popular starting stations.

The dashboard includes slicers to explore the data by rider type, month and bike type.

### Dashboard Preview

![Cyclistic Power BI Dashboard](Cyclistic_Dashboard.png)

## 9. Business Recommendations

1. **Weekend Membership Campaigns:** Test membership promotions targeting casual riders during weekends.
2. **Seasonal Campaigns:** Run membership campaigns during higher-activity months, especially spring and summer.
3. **Station-Based Marketing:** Explore opportunities at stations with high casual rider activity, such as Navy Pier.
4. **Repeat Usage Analysis:** Study repeat casual usage if suitable privacy-safe data becomes available.
5. **Measure Campaign Results:** Compare actual membership conversions before deciding which strategies are effective.

## 10. Repository Structure

```text
Cyclistic-Bike-Share-Analysis/
│
├── Python/
│   └── prepare_data.py
│
├── REPORT/
│   └── CYCLISTIC.docx
│
├── Cyclistic_Dashboard.png
├── Cyclistic_SQL_Analysis.sql
├── cyclistic_cleaned_sample.csv
└── README.md
```

## 11. Data Source and Reproducibility

The original Cyclistic trip data is available from the [Divvy System Data website](https://divvybikes.com/system-data).

The complete raw and cleaned datasets are not included in this repository because of their large file sizes. A 10,000-row cleaned sample CSV is provided for preview.

### To reproduce the data preparation:

1. Download the required monthly trip-data CSV files from the official source.
2. Create a folder named `01_Raw_Data` in your local project folder.
3. Place the downloaded monthly CSV files inside `01_Raw_Data`.
4. Keep `prepare_data.py` inside the `Python` folder.
5. Install the required Python library:

   ```bash
   pip install pandas
   ```

6. Run the script from the main project folder:

   ```bash
   python Python/prepare_data.py
   ```

The script automatically creates the `02_Cleaned_Data` folder and saves the prepared dataset as `cyclistic_cleaned.csv`.

**Note:** The Python script reads the original monthly CSV files from `01_Raw_Data`. The Excel Power Query preparation is documented as a separate part of the project's workflow. The complete raw and cleaned datasets are stored locally and are not included in this repository.

The SQL analysis, dashboard preview, cleaned-data sample and final report are included in this repository to document the analysis and findings.

## 12. Limitations

- Ride records do not represent unique customers.
- The dataset does not explain why riders choose casual rides or annual memberships.
- Missing station information can affect station-level comparisons.
- Long rides can influence average ride-duration calculations.
- Marketing recommendations require further testing to measure actual membership conversions.

## 13. Conclusion

This project helped me apply the complete data analytics workflow using Excel, Python, MySQL and Power BI.

The analysis identified differences in riding patterns between casual riders and annual members. These findings provide opportunities for Cyclistic to test weekend, seasonal and station-based membership campaigns.

The effectiveness of these recommendations should be measured through further analysis and marketing experiments.

---

**Project Type:** Data Analytics Case Study

**Tools:** Excel | Python | MySQL | Power BI

**Reporting Period:** September 2025 – August 2026
