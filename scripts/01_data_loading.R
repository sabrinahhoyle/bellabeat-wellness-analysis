# ==============================================================================
# BELLABEAT CAPSTONE PROJECT
# Script 01: Data Loading & Initial Exploration - RStudio Cloud Version
# Author: Sabrina
# Date: December 16, 2024
# Purpose: Load FitBit data and perform initial quality checks
# ==============================================================================

# SETUP ------------------------------------------------------------------------

# Clear environment
rm(list = ls())

# Load required packages
library(tidyverse)
library(lubridate)
library(janitor)
library(skimr)
library(scales)

# DATA LOADING -----------------------------------------------------------------

cat("\n=== LOADING DATA ===\n")

# Load the three essential datasets (files are in current directory)
daily_activity <- read_csv("dailyActivity_merged.csv", show_col_types = FALSE)
sleep_day <- read_csv("sleepDay_merged.csv", show_col_types = FALSE)
hourly_steps <- read_csv("hourlySteps_merged.csv", show_col_types = FALSE)

cat("✓ Data loaded successfully!\n")

# INITIAL INSPECTION -----------------------------------------------------------

cat("\n=== DATASET DIMENSIONS ===\n")
cat("Daily Activity:", nrow(daily_activity), "rows x", ncol(daily_activity), "columns\n")
cat("Sleep Day:", nrow(sleep_day), "rows x", ncol(sleep_day), "columns\n")
cat("Hourly Steps:", nrow(hourly_steps), "rows x", ncol(hourly_steps), "columns\n")

cat("\n=== UNIQUE USERS ===\n")
cat("Users in daily_activity:", n_distinct(daily_activity$Id), "\n")
cat("Users in sleep_day:", n_distinct(sleep_day$Id), "\n")
cat("Users in hourly_steps:", n_distinct(hourly_steps$Id), "\n")

# DATE RANGE CHECK -------------------------------------------------------------

cat("\n=== DATE RANGE ANALYSIS ===\n")

# Parse dates to proper format
daily_activity <- daily_activity %>%
  mutate(ActivityDate = mdy(ActivityDate))

sleep_day <- sleep_day %>%
  mutate(SleepDay = mdy_hms(SleepDay),
         SleepDate = as_date(SleepDay))

cat("\nDate range:", 
    min(daily_activity$ActivityDate), "to", 
    max(daily_activity$ActivityDate), "\n")

# MISSING VALUES CHECK ---------------------------------------------------------

cat("\n=== MISSING VALUES ===\n")

missing_daily <- colSums(is.na(daily_activity))
if(sum(missing_daily) == 0) {
  cat("✓ No missing values in daily activity!\n")
} else {
  print(missing_daily[missing_daily > 0])
}

# DATA QUALITY CHECKS ----------------------------------------------------------

cat("\n=== DATA QUALITY CHECKS ===\n")

zero_steps <- sum(daily_activity$TotalSteps == 0)
cat("Days with zero steps:", zero_steps, "\n")

extreme_steps <- sum(daily_activity$TotalSteps > 40000)
cat("Days with >40,000 steps:", extreme_steps, "\n")

# SUMMARY STATISTICS -----------------------------------------------------------

cat("\n=== ACTIVITY SUMMARY ===\n")
cat("Average daily steps:", round(mean(daily_activity$TotalSteps), 0), "\n")
cat("Median daily steps:", round(median(daily_activity$TotalSteps), 0), "\n")
cat("Average calories:", round(mean(daily_activity$Calories), 0), "\n")
cat("Average sedentary minutes:", round(mean(daily_activity$SedentaryMinutes), 0), "\n")

cat("\n=== SLEEP SUMMARY ===\n")
cat("Average sleep hours:", round(mean(sleep_day$TotalMinutesAsleep)/60, 1), "\n")
cat("Median sleep hours:", round(median(sleep_day$TotalMinutesAsleep)/60, 1), "\n")
cat("Sleep efficiency:", round(mean(sleep_day$TotalMinutesAsleep/sleep_day$TotalTimeInBed)*100, 1), "%\n")

# USER ENGAGEMENT --------------------------------------------------------------

cat("\n=== USER ENGAGEMENT ===\n")

user_days <- daily_activity %>%
  group_by(Id) %>%
  summarise(days_logged = n())

cat("Average days logged per user:", round(mean(user_days$days_logged), 1), "\n")
cat("Users tracking sleep:", n_distinct(sleep_day$Id), "out of", n_distinct(daily_activity$Id), "\n")

# CREATE QUICK PLOTS -----------------------------------------------------------

cat("\n=== CREATING PLOTS ===\n")

# Plot 1: Steps distribution
p1 <- ggplot(daily_activity, aes(x = TotalSteps)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(title = "Distribution of Daily Steps",
       subtitle = "FitBit Users (April-May 2016)",
       x = "Total Steps", 
       y = "Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave("01_steps_distribution.png", p1, width = 8, height = 5, dpi = 300)
cat("✓ Saved: 01_steps_distribution.png\n")

# Plot 2: Sleep distribution
p2 <- ggplot(sleep_day, aes(x = TotalMinutesAsleep/60)) +
  geom_histogram(bins = 20, fill = "darkgreen", color = "white") +
  labs(title = "Distribution of Sleep Duration",
       subtitle = "FitBit Users (April-May 2016)",
       x = "Hours of Sleep", 
       y = "Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave("02_sleep_distribution.png", p2, width = 8, height = 5, dpi = 300)
cat("✓ Saved: 02_sleep_distribution.png\n")

# Plot 3: User engagement
p3 <- ggplot(user_days, aes(x = days_logged)) +
  geom_histogram(bins = 15, fill = "coral", color = "white") +
  labs(title = "User Engagement: Days Logged",
       subtitle = "Number of days each user tracked activity",
       x = "Days Logged", 
       y = "Number of Users") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave("03_engagement_distribution.png", p3, width = 8, height = 5, dpi = 300)
cat("✓ Saved: 03_engagement_distribution.png\n")

# SAVE DATA --------------------------------------------------------------------

cat("\n=== SAVING PROCESSED DATA ===\n")

saveRDS(daily_activity, "daily_activity_loaded.rds")
saveRDS(sleep_day, "sleep_day_loaded.rds")
saveRDS(hourly_steps, "hourly_steps_loaded.rds")

cat("✓ Data saved!\n")

# COMPLETION -------------------------------------------------------------------

cat("\n========================================\n")
cat("EXPLORATION COMPLETE!\n")
cat("========================================\n")
cat("\nKEY FINDINGS:\n")
cat("1. Dataset contains", n_distinct(daily_activity$Id), "users\n")
cat("2. Average daily steps:", round(mean(daily_activity$TotalSteps), 0), 
    "(below 10,000 recommendation)\n")
cat("3. Average sleep:", round(mean(sleep_day$TotalMinutesAsleep)/60, 1), 
    "hours (healthy range)\n")
cat("4. Data quality:", zero_steps, "days with zero steps need removal\n")
cat("\nNEXT STEP: Run Script 02 for data cleaning\n")
cat("========================================\n")

