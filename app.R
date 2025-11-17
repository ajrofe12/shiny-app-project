library(shiny)
library(ggplot2)
library(tidyverse)
library(vip)
library(ranger)
library(caret)
library(readr)

data_sample_filtered <- read.csv("data_sample_filtered.csv", row.names = 1)
rf_model <- readRDS("rf_model.rds")
rf_predictions <- read_csv("rf_predictions.csv")
load("rf_conf_matrix.RData")
accuracy <- readRDS("rf_accuracy.rds")

levels_usage <- c("Low", "Medium", "High")
# Ensure usage levels are factors
data_sample_filtered$in.usage_level <- factor(data_sample_filtered$in.usage_level, levels = levels_usage)
rf_predictions$in.usage_level <- factor(rf_predictions$in.usage_level, levels = levels_usage)
rf_predictions$predicted_usage <- factor(rf_predictions$predicted_usage, levels = levels_usage)

vip_data <- vip(rf_model)$data

# Select the top 5 most important variables
top_vip_data <- vip_data %>%
  top_n(5, wt = Importance)

vip_plot <- ggplot(top_vip_data, aes(x = reorder(Variable, Importance), y = Importance)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  coord_flip() +  # Flip the axes for better readability
  labs(title = "Random Forest Variable Importance") + 
  theme_minimal() + 
  theme(
    plot.title = element_text(hjust = 0.5, color = 'black'),  # Center title and change color
    axis.text.x = element_text(size = 14, color = 'black'),   # Increase size and color for x-axis
    axis.text.y = element_text(size = 14, color = 'black')     # Increase size and color for y-axis
  )


# --- UI ---
ui <- fluidPage(
  titlePanel("Energy Usage Prediction App"),
  
  tabsetPanel(
    tabPanel(
      "Dataset Preview",
      numericInput("num_rows", "Number of Rows to Display:", 
                   value = 10, min = 1, max = 100, step = 1),
      dataTableOutput("dataset_preview")
    ),
    
    tabPanel(
      "Variable Importance",
      plotOutput("vip_plot", height = "800px", width = "800px")
    ),
    
    tabPanel(
      "Predictions",
      h4("Prediction Results"),
      dataTableOutput("predictions_table"),
      
      h4("Confusion Matrix"),
      tableOutput("conf_matrix"),
      
      h4("Model Accuracy"),
      textOutput("accuracy_text"),
      
      h4("Confusion Matrix Explanation"),
      textOutput("conf_matrix_explanation")
    )
  )
)

# --- SERVER ---
server <- function(input, output, session) {
  
  # Dataset preview
  output$dataset_preview <- renderDataTable({
    head(data_sample_filtered, n = input$num_rows)
  })
  
  # VIP plot
  output$vip_plot <- renderPlot({
    vip_data <- vip(rf_model)$data
    top_vip_data <- vip_data %>% top_n(10, wt = Importance)
    
    ggplot(top_vip_data, aes(x = reorder(Variable, Importance), y = Importance)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(title = "Random Forest Variable Importance") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, color = 'black'),
        axis.text.x = element_text(size = 14, color = 'black'),
        axis.text.y = element_text(size = 14, color = 'black')
      )
  })
  
  # Predictions table (just display precomputed predictions)
  output$predictions_table <- renderDataTable({
    rf_predictions
  })
  
  # Confusion matrix (precomputed)
  output$conf_matrix <- renderTable({
    as.data.frame(conf_matrix$table)
  })
  
  # Accuracy (precomputed)
  output$accuracy_text <- renderText({
    paste("Model Accuracy:", round(accuracy, 4))
  })
  
  # Confusion matrix explanation
  output$conf_matrix_explanation <- renderText({
    paste(
      "A confusion matrix shows the comparison between actual and predicted values.",
      "\n\nDiagonal values represent correct predictions (true positives/negatives).",
      "\n\nHigher diagonal values indicate better model performance.",
      "\n\nOff-diagonal values represent misclassifications."
    )
  })
}

# Run app
shinyApp(ui = ui, server = server)
