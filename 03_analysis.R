# ==============================================================================
# BELLABEAT CAPSTONE PROJECT
# Script 03: Core Analysis & Key Insights
# Author: Sabrina
# Date: December 16, 2024
# Purpose: Generate key insights and visualizations for Bellabeat Time
# ==============================================================================

# SETUP ------------------------------------------------------------------------

# Clear environment
rm(list = ls())

# Load required packages
library(tidyverse)
library(scales)
library(lubridate)

# Load cleaned data from Script 02
daily_activity <- readRDS("daily_activity_clean.rds")
sleep_data <- readRDS("sleep_clean.rds")
daily_combined <- readRDS("daily_combined.rds")
hourly_steps <- readRDS("hourly_steps_clean.rds")
user_summary <- readRDS("user_summary.rds")

cat("\n=== DATA LOADED - READY FOR ANALYSIS ===\n")

# SET VISUALIZATION THEME ------------------------------------------------------

# Custom theme for consistent, professional visualizations
theme_bellabeat <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

# Bellabeat-inspired color palette (coral, teal, purple)
bellabeat_colors <- c("#FF6B6B", "#4ECDC4", "#95E1D3", "#F38181", "#AA96DA")

cat("✓ Visualization theme set\n")

# ==============================================================================
# ANALYSIS 1: ACTIVITY PATTERNS & TRENDS
# ==============================================================================

cat("\n=== ANALYSIS 1: ACTIVITY PATTERNS ===\n")

## 1.1 Overall Activity Distribution

activity_stats <- daily_activity %>%
  summarise(
    avg_steps = mean(TotalSteps),
    median_steps = median(TotalSteps),
    below_recommended = sum(TotalSteps < 10000) / n() * 100
  )

cat("\nKEY FINDING 1: Activity Levels\n")
cat("- Average daily steps:", round(activity_stats$avg_steps), "\n")
cat("- Median daily steps:", round(activity_stats$median_steps), "\n")
cat("- Days below 10,000 steps:", round(activity_stats$below_recommended, 1), "%\n")

## 1.2 Activity Level Distribution

activity_distribution <- daily_activity %>%
  count(activity_level) %>%
  mutate(percentage = n / sum(n) * 100)

cat("\nActivity Level Breakdown:\n")
print(activity_distribution)

# Visualization 1: Activity Level Distribution
p1 <- ggplot(activity_distribution, aes(x = activity_level, y = n, fill = activity_level)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), 
            vjust = -0.5, fontface = "bold", size = 4) +
  scale_fill_manual(values = bellabeat_colors) +
  labs(
    title = "User Activity Level Distribution",
    subtitle = "Based on daily step counts (33 FitBit users)",
    x = "Activity Level",
    y = "Number of Days"
  ) +
  theme_bellabeat

ggsave("viz_01_activity_distribution.png", p1, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_01_activity_distribution.png\n")

## 1.3 Weekday vs Weekend Activity

weekday_comparison <- daily_activity %>%
  group_by(is_weekend) %>%
  summarise(
    avg_steps = mean(TotalSteps),
    avg_active_minutes = mean(total_active_minutes),
    avg_sedentary = mean(SedentaryMinutes)
  ) %>%
  mutate(day_type = ifelse(is_weekend, "Weekend", "Weekday"))

cat("\nKEY FINDING 2: Weekday vs Weekend\n")
print(weekday_comparison)

# Statistical test
t_test_result <- t.test(TotalSteps ~ is_weekend, data = daily_activity)
cat("\nStatistical significance (t-test p-value):", round(t_test_result$p.value, 4), "\n")

# Visualization 2: Weekday vs Weekend Comparison
p2 <- ggplot(weekday_comparison, aes(x = day_type, y = avg_steps, fill = day_type)) +
  geom_col(show.legend = FALSE, width = 0.6) +
  geom_text(aes(label = comma(round(avg_steps))), 
            vjust = -0.5, fontface = "bold", size = 5) +
  scale_fill_manual(values = c("Weekend" = "#FF6B6B", "Weekday" = "#4ECDC4")) +
  scale_y_continuous(labels = comma, limits = c(0, max(weekday_comparison$avg_steps) * 1.15)) +
  labs(
    title = "Average Steps: Weekday vs Weekend",
    subtitle = "Users are more active on weekdays than weekends",
    x = NULL,
    y = "Average Daily Steps"
  ) +
  theme_bellabeat

ggsave("viz_02_weekday_weekend.png", p2, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_02_weekday_weekend.png\n")

## 1.4 Activity by Day of Week

daily_pattern <- daily_activity %>%
  group_by(day_of_week) %>%
  summarise(avg_steps = mean(TotalSteps)) %>%
  mutate(is_weekend = day_of_week %in% c("Sat", "Sun"))

# Visualization 3: Steps by Day of Week
p3 <- ggplot(daily_pattern, aes(x = day_of_week, y = avg_steps, 
                                fill = is_weekend, group = 1)) +
  geom_col(show.legend = FALSE) +
  geom_line(color = "black", linewidth = 1) +
  geom_point(color = "black", size = 3) +
  scale_fill_manual(values = c("FALSE" = "#4ECDC4", "TRUE" = "#FF6B6B")) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Average Steps by Day of Week",
    subtitle = "Activity drops on weekends, especially Sunday",
    x = "Day of Week",
    y = "Average Steps"
  ) +
  theme_bellabeat

ggsave("viz_03_daily_pattern.png", p3, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_03_daily_pattern.png\n")

# ==============================================================================
# ANALYSIS 2: SLEEP QUALITY & PATTERNS
# ==============================================================================

cat("\n=== ANALYSIS 2: SLEEP PATTERNS ===\n")

## 2.1 Sleep Duration Analysis

sleep_stats <- sleep_data %>%
  summarise(
    avg_sleep = mean(sleep_hours),
    median_sleep = median(sleep_hours),
    below_7hrs = sum(sleep_hours < 7) / n() * 100,
    healthy_range = sum(sleep_hours >= 7 & sleep_hours <= 9) / n() * 100,
    avg_efficiency = mean(sleep_efficiency)
  )

cat("\nKEY FINDING 3: Sleep Quality\n")
cat("- Average sleep:", round(sleep_stats$avg_sleep, 1), "hours\n")
cat("- Below 7 hours:", round(sleep_stats$below_7hrs, 1), "%\n")
cat("- In healthy range (7-9hrs):", round(sleep_stats$healthy_range, 1), "%\n")
cat("- Average sleep efficiency:", round(sleep_stats$avg_efficiency, 1), "%\n")

# Visualization 4: Sleep Duration Distribution
p4 <- ggplot(sleep_data, aes(x = sleep_hours)) +
  geom_histogram(bins = 25, fill = "#AA96DA", color = "white", alpha = 0.8) +
  geom_vline(xintercept = 7, linetype = "dashed", color = "#FF6B6B", linewidth = 1) +
  geom_vline(xintercept = 9, linetype = "dashed", color = "#FF6B6B", linewidth = 1) +
  annotate("text", x = 8, y = Inf, label = "Healthy Range\n(7-9 hours)", 
           vjust = 2, fontface = "bold", color = "#FF6B6B") +
  scale_x_continuous(breaks = seq(2, 16, 2)) +
  labs(
    title = "Sleep Duration Distribution",
    subtitle = paste0("Average: ", round(sleep_stats$avg_sleep, 1), 
                      " hours | Sleep Efficiency: ", round(sleep_stats$avg_efficiency, 1), "%"),
    x = "Hours of Sleep",
    y = "Frequency"
  ) +
  theme_bellabeat

ggsave("viz_04_sleep_distribution.png", p4, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_04_sleep_distribution.png\n")

# ==============================================================================
# ANALYSIS 3: ACTIVITY-SLEEP RELATIONSHIP
# ==============================================================================

cat("\n=== ANALYSIS 3: ACTIVITY-SLEEP RELATIONSHIP ===\n")

## 3.1 Correlation Analysis

# Filter to only rows with sleep data
combined_with_sleep <- daily_combined %>%
  filter(!is.na(sleep_hours))

correlation <- cor(combined_with_sleep$TotalSteps, 
                   combined_with_sleep$sleep_hours, 
                   use = "complete.obs")

cat("\nKEY FINDING 4: Steps-Sleep Correlation\n")
cat("Correlation coefficient:", round(correlation, 3), "\n")

if(abs(correlation) < 0.3) {
  cat("Interpretation: Weak correlation - steps don't strongly predict sleep\n")
} else if(abs(correlation) < 0.7) {
  cat("Interpretation: Moderate correlation\n")
} else {
  cat("Interpretation: Strong correlation\n")
}

# Visualization 5: Steps vs Sleep Scatterplot
p5 <- ggplot(combined_with_sleep, aes(x = TotalSteps, y = sleep_hours)) +
  geom_point(alpha = 0.4, color = "#4ECDC4", size = 2) +
  geom_smooth(method = "lm", color = "#FF6B6B", linewidth = 1.5, se = TRUE, alpha = 0.2) +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Relationship Between Daily Steps and Sleep Duration",
    subtitle = paste0("Correlation: ", round(correlation, 3), 
                      " | Sample: ", nrow(combined_with_sleep), " observations"),
    x = "Total Daily Steps",
    y = "Hours of Sleep"
  ) +
  theme_bellabeat

ggsave("viz_05_steps_sleep_correlation.png", p5, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_05_steps_sleep_correlation.png\n")

## 3.2 Sleep by Activity Level

sleep_by_activity <- daily_combined %>%
  filter(!is.na(sleep_hours)) %>%
  group_by(activity_level) %>%
  summarise(
    avg_sleep = mean(sleep_hours),
    median_sleep = median(sleep_hours),
    n = n()
  )

cat("\nSleep by Activity Level:\n")
print(sleep_by_activity)

# Visualization 6: Sleep Duration by Activity Level
p6 <- ggplot(daily_combined %>% filter(!is.na(sleep_hours)), 
             aes(x = activity_level, y = sleep_hours, fill = activity_level)) +
  geom_boxplot(show.legend = FALSE, alpha = 0.8) +
  scale_fill_manual(values = bellabeat_colors) +
  labs(
    title = "Sleep Duration by Activity Level",
    subtitle = "More active users don't necessarily sleep more or less",
    x = "Activity Level",
    y = "Hours of Sleep"
  ) +
  theme_bellabeat

ggsave("viz_06_sleep_by_activity.png", p6, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_06_sleep_by_activity.png\n")

# ==============================================================================
# ANALYSIS 4: HOURLY ACTIVITY PATTERNS
# ==============================================================================

cat("\n=== ANALYSIS 4: HOURLY ACTIVITY PATTERNS ===\n")

## 4.1 Peak Activity Times

hourly_pattern <- hourly_steps %>%
  group_by(hour) %>%
  summarise(avg_steps = mean(StepTotal)) %>%
  arrange(desc(avg_steps))

cat("\nKEY FINDING 5: Peak Activity Hours\n")
cat("Top 3 most active hours:\n")
print(head(hourly_pattern, 3))

# Visualization 7: Hourly Activity Pattern
p7 <- ggplot(hourly_pattern %>% arrange(hour), aes(x = hour, y = avg_steps)) +
  geom_line(color = "#4ECDC4", linewidth = 1.5) +
  geom_point(color = "#4ECDC4", size = 3) +
  geom_area(alpha = 0.3, fill = "#4ECDC4") +
  scale_x_continuous(breaks = seq(0, 23, 2), 
                     labels = paste0(seq(0, 23, 2), ":00")) +
  labs(
    title = "Average Steps by Hour of Day",
    subtitle = "Peak activity: Lunch time (12-2 PM) and Evening (5-7 PM)",
    x = "Hour of Day",
    y = "Average Steps per Hour"
  ) +
  theme_bellabeat +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("viz_07_hourly_pattern.png", p7, width = 12, height = 6, dpi = 300)
cat("✓ Saved: viz_07_hourly_pattern.png\n")

# ==============================================================================
# ANALYSIS 5: USER ENGAGEMENT
# ==============================================================================

cat("\n=== ANALYSIS 5: USER ENGAGEMENT ===\n")

## 5.1 Engagement Levels

engagement_summary <- user_summary %>%
  count(engagement_level) %>%
  mutate(percentage = n / sum(n) * 100)

cat("\nKEY FINDING 6: User Engagement\n")
print(engagement_summary)

# Visualization 8: User Engagement Distribution
p8 <- ggplot(user_summary, aes(x = days_logged)) +
  geom_histogram(bins = 20, fill = "#FF6B6B", color = "white", alpha = 0.8) +
  geom_vline(xintercept = 25, linetype = "dashed", color = "darkred", linewidth = 1) +
  geom_vline(xintercept = 15, linetype = "dashed", color = "orange", linewidth = 1) +
  annotate("text", x = 27, y = Inf, label = "High\nEngagement", 
           vjust = 1.5, fontface = "bold", color = "darkred", size = 3) +
  labs(
    title = "User Engagement: Days Logged",
    subtitle = paste0("Average: ", round(mean(user_summary$days_logged), 1), " days out of 31"),
    x = "Number of Days Logged",
    y = "Number of Users"
  ) +
  theme_bellabeat

ggsave("viz_08_user_engagement.png", p8, width = 10, height = 6, dpi = 300)
cat("✓ Saved: viz_08_user_engagement.png\n")

## 5.2 Sleep Tracking Adoption

sleep_tracking_summary <- user_summary %>%
  summarise(
    total_users = n(),
    sleep_trackers = sum(tracks_sleep),
    percentage = sleep_trackers / total_users * 100
  )

cat("\nSleep Tracking:\n")
cat("Users tracking sleep:", sleep_tracking_summary$sleep_trackers, 
    "out of", sleep_tracking_summary$total_users,
    paste0("(", round(sleep_tracking_summary$percentage, 1), "%)"), "\n")

# ==============================================================================
# KEY INSIGHTS SUMMARY
# ==============================================================================

cat("\n========================================\n")
cat("ANALYSIS COMPLETE!\n")
cat("========================================\n")
cat("\nKEY INSIGHTS FOR BELLABEAT TIME:\n\n")

cat("1. ACTIVITY LEVELS\n")
cat("   - Average:", round(activity_stats$avg_steps), "steps/day (below 10K recommendation)\n")
cat("   - ", round(activity_stats$below_recommended, 1), "% of days below recommended levels\n")
cat("   → OPPORTUNITY: Position Time as motivational tool to reach activity goals\n\n")

cat("2. WEEKDAY VS WEEKEND\n")
cat("   - Users", ifelse(weekday_comparison$avg_steps[1] > weekday_comparison$avg_steps[2], 
                         "MORE", "LESS"), "active on weekdays\n")
cat("   → OPPORTUNITY: Weekend-specific challenges and reminders\n\n")

cat("3. SLEEP QUALITY\n")
cat("   - Average:", round(sleep_stats$avg_sleep, 1), "hours (healthy range)\n")
cat("   - Sleep efficiency:", round(sleep_stats$avg_efficiency, 1), "%\n")
cat("   → OPPORTUNITY: Emphasize Time's sleep tracking for holistic wellness\n\n")

cat("4. ACTIVITY-SLEEP LINK\n")
cat("   - Weak correlation between steps and sleep\n")
cat("   → INSIGHT: Active lifestyle alone doesn't guarantee good sleep\n")
cat("   → OPPORTUNITY: Integrated approach - track both activity AND sleep\n\n")

cat("5. PEAK ACTIVITY TIMES\n")
cat("   - Highest activity: 12-2 PM and 5-7 PM\n")
cat("   → OPPORTUNITY: Time notifications for movement during sedentary hours\n\n")

cat("6. USER ENGAGEMENT\n")
cat("   - Only", round(sleep_tracking_summary$percentage, 1), "% track sleep\n")
cat("   → OPPORTUNITY: Educate on benefits of comprehensive wellness tracking\n\n")

cat("VISUALIZATIONS CREATED: 8 publication-ready charts\n")
cat("\nNEXT STEP: Create presentation and GitHub portfolio\n")
cat("========================================\n")

# Save key metrics for presentation
key_metrics <- list(
  avg_steps = round(activity_stats$avg_steps),
  avg_sleep = round(sleep_stats$avg_sleep, 1),
  sleep_efficiency = round(sleep_stats$avg_efficiency, 1),
  below_10k = round(activity_stats$below_recommended, 1),
  sleep_trackers = round(sleep_tracking_summary$percentage, 1),
  total_users = n_distinct(daily_activity$Id)
)

saveRDS(key_metrics, "key_metrics.rds")
cat("\n✓ Key metrics saved for presentation\n")
