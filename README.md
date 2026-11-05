# Healthcare Workforce Data Audit and Statistical Analysis

## Project Overview
This project demonstrates a complete data cleaning, validation, and statistical analysis workflow using a healthcare workforce dataset containing 120 records.

## Tools Used
- MySQL Workbench – Data cleaning and validation
- R and RStudio – Statistical analysis and visualization
- CSV – Dataset storage

## Project Structure
healthcare-workforce-audit/
│
├── data/
│   ├── healthcare_workforce_original.csv
│   └── healthcare_workforce_cleaned.csv
│
├── r_analysis/
│   ├── plots/
│   │   ├── average_burnout_by_department.png
│   │   ├── burnout_categories.png
│   │   ├── burnout_distribution.png
│   │   └── hours_vs_burnout.png
│   ├── healthcare_workforce_analysis.R
│   ├── statistical_analysis_summary.txt
│   └── statistical_results.txt
│
├── screenshots/
│   ├── mysql_cleaning.png
│   ├── mysql_validation.png
│   ├── project_structure.png
│   ├── rstudio_plots.png
│   └── rstudio_script.png
│
├── sql/
│   └── healthcare_workforce_audit.sql
│
└── README.md

## Statistical Analysis
The analysis includes:
- Descriptive statistics
- Department and profession distributions
- Pearson correlation analysis
- One-way ANOVA
- Four visualizations

## Data Validation
The cleaned dataset contains 120 records and 120 unique IDs. The validation query found no missing values in the checked fields.

## Outputs
- Cleaned dataset
- SQL cleaning and validation script
- Statistical analysis results
- Four PNG charts
- Software screenshots

## Author
Healthcare Workforce Data Analysis Portfolio Project
