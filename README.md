# **Residential Energy Usage Shiny App**  
**Course:** IST 687 – Introduction to Data Science  
**Semester:** Fall 2024  
**Tools:** R, Shiny, tidyverse, ranger, caret, vip, ggplot2  

**Live App:** https://ajrofe.shinyapps.io/shiny_app/

---

## **Overview**

This interactive Shiny application explores residential household energy usage and predicts whether a home belongs to a **Low**, **Medium**, or **High** usage category.  
The app uses a Random Forest model trained on a dataset containing **200+ building, weather, demographic, and energy consumption variables**, providing users with tools to:

- Preview the cleaned dataset  
- View variable importance scores  
- Explore model predictions  
- Examine model accuracy and confusion matrices  

This project demonstrates the complete data science lifecycle: data cleaning, sampling, feature engineering, modeling, evaluation, and visualization.

---

## **Dataset Summary**

The dataset includes:

### **Energy Output Variables**
- Electricity (cooling, heating, appliances, lighting, pumps, fans)
- Natural gas, propane, and fuel oil usage  
- PV energy  
- Pool/spa heating  
- Plug loads  

### **Building Characteristics**
- Floor area and geometry  
- HVAC type & efficiency  
- Insulation (ceiling, wall, floor, foundation)  
- Ventilation / infiltration  
- Occupants, number of bedrooms  
- Structural attributes  

### **Weather Variables**
- Dry bulb temperature  
- Relative humidity  
- Wind speed & direction  
- Solar radiation  

### **Demographics**
- Household income  
- Census region & climate zone  
- Tenure (rent/own)  

### **Target Variable**
`in.usage_level` with three classes:
- **Low**
- **Medium**
- **High**

The final modeling dataset contains **100,000 sampled observations**.

---

## **Modeling Pipeline**

### **Data Preprocessing**
- Combined low/medium/high datasets  
- Removed constant and near-zero variance variables  
- Converted categorical variables to factors  
- Cleaned invalid occupant values  
- Extracted date and time from timestamp  
- Removed irrelevant identifiers  
- Applied correlation filtering  

### **Modeling**
A **Random Forest** classifier was trained using an 80/20 split.

Saved model outputs used by the app:
- `rf_predictions.csv`  
- `rf_conf_matrix.RData`  
- `rf_accuracy.rds`  
- `data_sample_filtered.csv`  

---

## **Shiny App Structure**

The application consists of **three interactive tabs**, each representing a step in the analysis process.

---

### **1. Dataset Preview**
- User chooses number of rows to display  
- Shows the cleaned modeling dataset  
- Provides transparency into preprocessing  

---

### **2. Variable Importance**
- Displays the top predictors of energy usage level  
- Uses `vip` + `ggplot2`  
- Helps interpret the Random Forest model  

---

### **3. Predictions & Model Performance**
This tab includes:

#### **Prediction Results**
Table of predictions from `rf_predictions.csv`.

#### **Confusion Matrix**
Shows:
- Correct predictions  
- Misclassifications  
- Class distribution  

#### **Accuracy Metric**
Loaded from `rf_accuracy.rds`.

#### **Confusion Matrix Explanation**
Plain-language explanation of:
- True positives  
- False positives  
- Misclassification meaning  
- How to read matrix diagonals  

---

## **Project Write-Up**

A complete write-up of the project’s methodology is included:

- [Energy Usage Project Writeup](energy_usage_writeup.pdf)

The document covers:
- Data cleaning, sampling strategy, and variance filtering  
- Justification for removing energy output variables  
- Comparison of Ordered Logit, Ordered Probit, and Random Forest models  
- Model accuracies and performance discussion  
- Interpretation of variable importance  
- Recommendations for energy efficiency  


## **Files Included**

- `app.R` – Full Shiny application
- `energy_usage_writeup.pdf` - Full project write-up and methodology
- `scripts/data_sample_code.R` – Data sampling and preprocessing pipeline  
- `data/data_sample_filtered.csv` – Cleaned dataset used by the app  
- `models/rf_predictions.csv` – Model predictions  
- `models/rf_conf_matrix.RData` – Confusion matrix results  
- `models/rf_accuracy.rds` – Model accuracy metric  

---
