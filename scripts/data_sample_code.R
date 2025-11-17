setwd("/Users/aaronrofe/Documents/Fall 2024/IST 687/Project Data")

library(tidyverse)


# Read in the datasets, separated into low, medium and high based on in.usage_level 
high <- read_csv("high_data.csv")
medium <- read_csv("medium_data.csv")
low <- read_csv("low_data.csv")

dim(low)
dim(medium)
dim(high)

#Sample 100,000 observations from each dataset for exploratory analysis
set.seed(123) # For reproducibility
low_sample <- low %>% slice_sample(n = 25000)
medium_sample <- medium %>% slice_sample(n = 50000)
high_sample <- high %>% slice_sample(n = 25000)

low_sample <- low_sample %>% mutate(in.occupants = as.numeric(in.occupants))
medium_sample <- medium_sample %>% mutate(in.occupants = as.numeric(in.occupants))
high_sample <- high_sample %>% mutate(in.occupants = as.numeric(in.occupants))

# Handle warnings if conversion results in NAs (e.g., "unknown" values)
low_sample$in.occupants[is.na(low_sample$in.occupants)] <- 0
medium_sample$in.occupants[is.na(medium_sample$in.occupants)] <- 0
high_sample$in.occupants[is.na(high_sample$in.occupants)] <- 0

#Get the final data sample
data_sample <- bind_rows(low_sample, medium_sample, high_sample) 

data_sample <- data_sample %>%
  mutate(
    date = as.Date(date_time),           # Extract the date
    time = format(as.POSIXct(date_time), "%H:%M:%S") # Extract the time in HH:MM:SS format
  )

names(data_sample)

#Summary of the data
summary(data_sample)

# 2. Univariate Analysis
# Categorical Variables
categorical_vars <- c("in.bedrooms","in.hvac_heating_type", "in.tenure", 
                      "in.geometry_floor_area", "in.insulation_ceiling", "in.geometry_stories", "in.county", 
                      "in.ahs_region", 
                      "in.ashrae_iecc_climate_zone_2004", 
                      "in.bathroom_spot_vent_hour", 
                      "in.building_america_climate_zone", 
                      "in.cec_climate_zone", 
                      "in.ceiling_fan", 
                      "in.city", 
                      "in.clothes_dryer")

data_sample[categorical_vars] <- lapply(data_sample[categorical_vars], factor)

#for (var in categorical_vars) {
 # print(ggplot(data_sample, aes_string(x = var, fill = "in.usage_level")) +
  #        geom_bar(position = "dodge") +
   #       ggtitle(paste("Frequency Distribution of", var, "by Usage Level")))
#}

# 3. Bivariate Analysis
# Numerical vs. Numerical
#ggplot(data_sample, aes(x = in.geometry_floor_area, y = out.electricity.cooling.energy_consumption, color = in.usage_level)) +
 # geom_point(alpha = 0.5) +
  #geom_smooth(method = "lm", col = "red") +
  #ggtitle("Scatterplot: Floor Area vs Cooling Energy Consumption by Usage Level")


#table(data_sample$in.hvac_heating_type, data_sample$in.hvac_cooling_type)

#Regional and climate analysis
#ggplot(data_sample, aes(x = in.census_region, y = out.electricity.cooling.energy_consumption, fill = in.usage_level)) +
 # geom_boxplot() +
  #ggtitle("Energy Consumption by Region and Usage Level")

# Appliances and HVAC Systems
#ggplot(data_sample, aes(x = in.hvac_heating_type, 
 #                       y = out.electricity.cooling.energy_consumption, fill = in.usage_level)) +
  #geom_boxplot() +
  #ggtitle("Cooling Energy by Heating System Type and Usage Level")

# Insulation and Ventilation
#ggplot(data_sample, aes(x = in.insulation_ceiling, y = out.electricity.cooling.energy_consumption, color = in.usage_level)) +
 # geom_point(alpha = 0.5) +
  #ggtitle("Insulation vs Cooling Energy by Usage Level")

#Modelling
names(data_sample)

#Create ordering for ordered logit model
data_sample$in.usage_level <- factor(data_sample$in.usage_level, levels = c("Low", "Medium", "High"), ordered = TRUE)

names(data_sample)

colnames(data_sample)[216] <- "dry_bulb_temp"
colnames(data_sample)[217] <- "relative_humidity" 
colnames(data_sample)[218] <- "wind_speed" 



data_sample_filtered <- data_sample %>%
  dplyr::select(in.usage_level, 
                in.income,
                where(is.numeric),
                in.geometry_floor_area_bin,
                in.heating_fuel,
                time,
                dry_bulb_temp,
                -bldg_id,
                -out.electricity.plug_loads.energy_consumption
  )

sapply(data_sample_filtered, function(x) length(unique(x)))

# Check for columns with only one unique value
constant_vars <- sapply(data_sample_filtered, function(x) length(unique(x)) == 1)
print(names(data_sample_filtered)[constant_vars])
data_sample_filtered <- data_sample_filtered[, !constant_vars]

#### Remove columns with near-zero variance
nzv <- nearZeroVar(data_sample_filtered, saveMetrics = TRUE)

# Display near-zero variance columns
nzv_cols <- rownames(nzv[nzv$nzv, ])
print(paste("Near-zero variance columns:", paste(nzv_cols, collapse = ", ")))

# Filter out near-zero variance columns
data_sample_filtered <- data_sample_filtered[, !colnames(data_sample_filtered) %in% nzv_cols]




##### Train/test split for models
names(data_sample_filtered)
colnames(data_sample_filtered)[23] <- "wind_direction"

data_sample_filtered$in.usage_level <- factor(data_sample_filtered$in.usage_level,
                                              levels = c("Low", "Medium", "High"),
                                              ordered = FALSE)  # set TRUE only for ordinal models

write.csv(x = data_sample_filtered, "data_sample_filtered.csv")

data_split <- initial_split(data_sample_filtered, prop = 0.8)
train_data <- training(data_split)
test_data <- testing(data_split)

library(ranger)
rf_model <- ranger(in.usage_level ~ ., data = train_data, importance = "impurity")

# Generate predictions once and save them
rf_preds <- predict(rf_model, data = test_data)$predictions

# Add predictions to test data
pred_data <- test_data %>%
  mutate(predicted_usage = rf_preds)

# Compute confusion matrix and accuracy
library(caret)
conf_matrix <- caret::confusionMatrix(
  factor(pred_data$predicted_usage, levels = c("Low", "Medium", "High")),
  factor(pred_data$in.usage_level, levels = c("Low", "Medium", "High"))
)
accuracy <- conf_matrix$overall['Accuracy']

# Save predictions, confusion matrix, and accuracy
write.csv(pred_data, "rf_predictions.csv", row.names = FALSE)   
save(conf_matrix, accuracy, file = "rf_conf_matrix.RData")      
saveRDS(accuracy, file = "rf_accuracy.rds")                      
saveRDS(rf_model, "rf_model.rds")                              


