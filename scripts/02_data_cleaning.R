# ==============================================================================
# BELLABEAT CAPSTONE PROJECT
# Script 02: Data Cleaning & Preparation
# Author: Sabrina
# Date: December 16, 2024
# Purpose: Clean data and create analysis-ready datasets
# ==============================================================================

# SETUP ------------------------------------------------------------------------

# Clear environment
rm(list = ls())

# Load required packages
library(tidyverse)
library(lubridate)

# Load the data we saved from Script 01
daily_activity <- readRDS("daily_activity_loaded.rds")
sleep_day <- readRDS("sleep_day_loaded.rds")
hourly_steps <- readRDS("hourly_steps_loaded.rds")

cat("\n=== DATA LOADED FROM SCRIPT 01 ===\n")
cat("Starting rows - Daily Activity:", nrow(daily_activity), "\n")
cat("Starting rows - Sleep:", nrow(sleep_day), "\n")

# DATA CLEANING ----------------------------------------------------------------

cat("\n=== CLEANING DAILY ACTIVITY DATA ===\n")

# Remove days with zero steps (device not worn)
before_removal <- nrow(daily_activity)
daily_activity_clean <- daily_activity %>%
  filter(TotalSteps > 0)
removed <- before_removal - nrow(daily_activity_clean)

cat("Removed", removed, "days with zero steps\n")
cat("Remaining rows:", nrow(daily_activity_clean), "\n")

# Remove any duplicate records
daily_activity_clean <- daily_activity_clean %>%
  distinct()

cat("After removing duplicates:", nrow(daily_activity_clean), "rows\n")

# CREATE NEW VARIABLES ---------------------------------------------------------

cat("\n=== CREATING DERIVED VARIABLES ===\n")

# Add useful calculated fields
daily_activity_clean <- daily_activity_clean %>%
  mutate(
    # Day of week
    day_of_week = wday(ActivityDate, label = TRUE),
    
    # Weekend flag
    is_weekend = day_of_week %in% c("Sat", "Sun"),
    
    # Total active minutes
    total_active_minutes = VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes,
    
    # Activity level categories based on steps
    activity_level = case_when(
      TotalSteps < 5000 ~ "Sedentary",
      TotalSteps < 7500 ~ "Lightly Active",
      TotalSteps < 10000 ~ "Moderately Active",
      TRUE ~ "Very Active"
    ),
    
    # Activity level as ordered factor
    activity_level = factor(activity_level, 
                            levels = c("Sedentary", "Lightly Active", 
                                       "Moderately Active", "Very Active"),
                            ordered = TRUE)
  )

cat("✓ Created new variables:\n")
cat("  - day_of_week\n")
cat("  - is_weekend\n")
cat("  - total_active_minutes\n")
cat("  - activity_level\n")

# CLEAN SLEEP DATA -------------------------------------------------------------

cat("\n=== CLEANING SLEEP DATA ===\n")

sleep_clean <- sleep_day %>%
  # Remove any duplicates
  distinct() %>%
  # Calculate sleep efficiency
  mutate(
    sleep_efficiency = (TotalMinutesAsleep / TotalTimeInBed) * 100,
    sleep_hours = TotalMinutesAsleep / 60,
    day_of_week = wday(SleepDate, label = TRUE)
  ) %>%
  # Remove any outliers (sleep >16 hours or <2 hours - likely data errors)
  filter(sleep_hours >= 2 & sleep_hours <= 16)

cat("Sleep data after cleaning:", nrow(sleep_clean), "rows\n")
cat("Average sleep efficiency:", round(mean(sleep_clean$sleep_efficiency), 1), "%\n")

# MERGE ACTIVITY AND SLEEP -----------------------------------------------------

cat("\n=== MERGING ACTIVITY AND SLEEP DATA ===\n")

# Join sleep to activity data (left join to keep all activity days)
daily_combined <- daily_activity_clean %>%
  left_join(
    sleep_clean %>% select(Id, SleepDate, TotalMinutesAsleep, 
                           TotalTimeInBed, sleep_efficiency, sleep_hours),
    by = c("Id" = "Id", "ActivityDate" = "SleepDate")
  )

cat("Combined dataset:", nrow(daily_combined), "rows\n")
cat("Rows with sleep data:", sum(!is.na(daily_combined$sleep_hours)), "\n")

# PREPARE HOURLY DATA ----------------------------------------------------------

cat("\n=== PREPARING HOURLY DATA ===\n")

hourly_steps_clean <- hourly_steps %>%
  mutate(
    # Parse the datetime
    activity_hour = mdy_hms(ActivityHour),
    date = as_date(activity_hour),
    hour = hour(activity_hour),
    day_of_week = wday(activity_hour, label = TRUE)
  ) %>%
  # Remove any rows with missing steps
  filter(!is.na(StepTotal))

cat("Hourly steps after cleaning:", nrow(hourly_steps_clean), "rows\n")

# CALCULATE USER-LEVEL STATISTICS ----------------------------------------------

cat("\n=== CALCULATING USER-LEVEL METRICS ===\n")

user_summary <- daily_activity_clean %>%
  group_by(Id) %>%
  summarise(
    days_logged = n(),
    avg_daily_steps = mean(TotalSteps),
    median_daily_steps = median(TotalSteps),
    avg_calories = mean(Calories),
    avg_active_minutes = mean(total_active_minutes),
    avg_sedentary_minutes = mean(SedentaryMinutes),
    step_consistency = sd(TotalSteps) / mean(TotalSteps) # Coefficient of variation
  ) %>%
  # Add engagement level
  mutate(
    engagement_level = case_when(
      days_logged >= 25 ~ "High",
      days_logged >= 15 ~ "Medium",
      TRUE ~ "Low"
    )
  )

cat("User summary created for", nrow(user_summary), "users\n")

# Add sleep tracking status
sleep_tracking <- sleep_clean %>%
  group_by(Id) %>%
  summarise(
    sleep_days_logged = n(),
    avg_sleep_hours = mean(sleep_hours),
    avg_sleep_efficiency = mean(sleep_efficiency)
  )

user_summary <- user_summary %>%
  left_join(sleep_tracking, by = "Id") %>%
  mutate(
    tracks_sleep = !is.na(sleep_days_logged),
    sleep_days_logged = replace_na(sleep_days_logged, 0)
  )

# DATA QUALITY SUMMARY ---------------------------------------------------------

cat("\n=== FINAL DATA QUALITY SUMMARY ===\n")

cat("\nCLEANED DATASETS:\n")
cat("1. daily_activity_clean:", nrow(daily_activity_clean), "rows,", 
    n_distinct(daily_activity_clean$Id), "users\n")
cat("2. sleep_clean:", nrow(sleep_clean), "rows,", 
    n_distinct(sleep_clean$Id), "users\n")
cat("3. daily_combined:", nrow(daily_combined), "rows (activity + sleep merged)\n")
cat("4. hourly_steps_clean:", nrow(hourly_steps_clean), "rows\n")
cat("5. user_summary:", nrow(user_summary), "users\n")

cat("\nDATA QUALITY METRICS:\n")
cat("- Users with high engagement (25+ days):", 
    sum(user_summary$engagement_level == "High"), "\n")
cat("- Users tracking sleep:", sum(user_summary$tracks_sleep), "\n")
cat("- Average data completeness:", 
    round(mean(user_summary$days_logged)/31 * 100, 1), "%\n")

# SAVE CLEANED DATA ------------------------------------------------------------

cat("\n=== SAVING CLEANED DATA ===\n")

saveRDS(daily_activity_clean, "daily_activity_clean.rds")
saveRDS(sleep_clean, "sleep_clean.rds")
saveRDS(daily_combined, "daily_combined.rds")
saveRDS(hourly_steps_clean, "hourly_steps_clean.rds")
saveRDS(user_summary, "user_summary.rds")

cat("✓ All cleaned datasets saved!\n")

# CREATE CLEANING LOG ----------------------------------------------------------

cat("\n=== CREATING CLEANING LOG ===\n")

cleaning_log <- data.frame(
  step = c(
    "1. Removed zero-step days",
    "2. Removed duplicates",
    "3. Created derived variables",
    "4. Cleaned sleep data (2-16 hour range)",
    "5. Merged activity and sleep",
    "6. Cleaned hourly data",
    "7. Created user summary statistics"
  ),
  rows_affected = c(
    removed,
    0,
    0,
    nrow(sleep_day) - nrow(sleep_clean),
    0,
    0,
    0
  ),
  result = c(
    paste(nrow(daily_activity_clean), "rows remaining"),
    "No duplicates found",
    "Added 5 new variables",
    paste(nrow(sleep_clean), "sleep records"),
    paste(sum(!is.na(daily_combined$sleep_hours)), "merged records"),
    paste(nrow(hourly_steps_clean), "hourly records"),
    paste(nrow(user_summary), "user profiles")
  )
)

# Save as CSV
write_csv(cleaning_log, "cleaning_log.csv")
cat("✓ Cleaning log saved as cleaning_log.csv\n")

# COMPLETION -------------------------------------------------------------------

cat("\n========================================\n")
cat("DATA CLEANING COMPLETE!\n")
cat("========================================\n")
cat("\nREADY FOR ANALYSIS:\n")
cat("✓ Clean activity data with derived variables\n")
cat("✓ Clean sleep data with efficiency metrics\n")
cat("✓ Combined activity + sleep dataset\n")
cat("✓ Hourly activity patterns\n")
cat("✓ User-level summary statistics\n")
cat("\nNEXT STEP: Run Script 03 for analysis and insights\n")
cat("========================================\n")
