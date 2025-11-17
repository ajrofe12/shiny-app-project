# **Residential Energy Usage Shiny App**  
**Course:** IST 687 – Introduction to Data Science  
**Semester:** Fall 2024  
**Tools:** R, Shiny, tidyverse, ranger, caret, vip, ggplot2  

**Live App:** https://ajrofe.shinyapps.io/shiny_app/

---

## **Overview**

This interactive Shiny application explores residential household energy usage and predicts whether a home belongs to a **Low**, **Medium**, or **High** energy usage category. The app uses a Random Forest model trained on a dataset containing **200+ building, weather, demographic, and energy consumption variables**, providing users with tools to:

- Preview the cleaned dataset  
- View variable importance scores  
- Explore model predictions  
- Examine accuracy and the confusion matrix  

This project demonstrates the full data science lifecycle: cleaning, sampling, feature engineering, modeling, evaluation, and visualization.

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
- Structural characteristics  

### **Weather Variables**
- Dry bulb temperature  
- Relative humidity  
- Wind speed & direction  
- Solar radiation levels  

### **Demographics**
- Household income  
- Census region & climate zone  
- Tenure (rent/own)  

### **Target Variable**
`in.usage_level` with values:
- **Low**
- **Medium**
- **High**

The final modeling dataset contains **100,000 sampled observations**.

---

## **Modeling Pipeline**

### Data Preprocessing
- Combined low/medium/high datasets  
- Removed constant and near-zero variance variables  
- Converted categorical variables to factors  
- Cleaned occupant values  
- Extracted date & time from timestamp  
- Removed irrelevant identifiers (`bldg_id`)  

### Modeling
A **Random Forest** classifier (`ranger`) was trained on an 80/20 split.

Saved model outputs include:
- `rf_model.rds`  
- `rf_predictions.csv`  
- `rf_conf_matrix.RData`  
- `rf_accuracy.rds`  
- `data_sample_filtered.csv`  

These files load automatically inside the Shiny app.

---

## **Shiny App Structure**

The application consists of **three main tabs**, each showing different parts of the analysis pipeline.

---

### ### **1. Dataset Preview**
Allows users to:
- Specify the number of rows to display  
- View the cleaned modeling dataset using a dynamic data table  

Provides transparency into preprocessing steps and the final features used for modeling.

---

### ### **2. Variable Importance**
Displays the **top variables** contributing to the Random Forest model.

- Renders a **bar chart** of variable importances  
- Uses `vip` and `ggplot2`  
- Highlights the **most influential predictors** of energy usage level  

This helps users understand the model’s behavior and interpretability.

---

### ### **3. Predictions & Model Performance**
This tab includes:

#### **Prediction Results**
A table of all predictions from `rf_predictions.csv`.

#### **Confusion Matrix**
A precomputed confusion matrix summarizing:
- Correct classifications  
- Misclassified homes  
- Distribution of errors  

#### **Model Accuracy**
Displayed as a single numeric metric from `rf_accuracy.rds`.

#### **Confusion Matrix Explanation**
A plain-language interpretation of:
- True positives  
- False positives  
- Misclassification meaning  
- How to read matrix diagonals  
