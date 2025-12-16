# Bellabeat Wellness Analysis
**Smart Device Usage Insights for Marketing Strategy**

![Activity Analysis](https://img.shields.io/badge/Analysis-Complete-success)
![Tools](https://img.shields.io/badge/Tools-R%20%7C%20ggplot2%20%7C%20tidyverse-blue)

## 📊 Project Overview

This case study analyzes smart device usage data from 33 FitBit users to provide actionable insights for **Bellabeat Time**, a wellness watch designed for women. The analysis focuses on activity patterns, sleep quality, and user engagement to inform marketing strategy.

**Business Question:** How can Bellabeat leverage smart device usage trends to enhance their marketing approach for Bellabeat Time?

---

## 🎯 Key Findings

### 1. **Activity Gap Opportunity**
- Average daily steps: **7,638** (below the 10,000 recommendation)
- **81% of days** fall short of recommended activity levels
- **Opportunity:** Position Bellabeat Time as a motivational partner for gradual improvement

### 2. **Weekend Activity Drop**
- Users are **more active on weekdays** than weekends
- Sunday shows the lowest activity levels
- **Opportunity:** Weekend-specific challenges and engagement campaigns

### 3. **Sleep Tracking Underutilization**
- Only **73% of users** track sleep despite device capability
- Average sleep: **7.0 hours** (healthy range)
- Sleep efficiency: **92.8%**
- **Opportunity:** Emphasize holistic wellness (activity + sleep), not just fitness

### 4. **Peak Activity Times**
- Highest activity: **12-2 PM** (lunch) and **5-7 PM** (evening)
- Sedentary periods: **8-11 AM** and **2-4 PM**
- **Opportunity:** Smart notification timing during low-activity hours

### 5. **User Engagement Varies**
- Average engagement: **21 days** logged out of 31
- High variability in consistency
- **Opportunity:** Implement retention strategies and habit-building features

---

## 📈 Visualizations

### Activity Patterns
![Activity Distribution](outputs/viz_01_activity_distribution.png)
*Most users fall in the "Lightly Active" to "Moderately Active" range*

![Weekday vs Weekend](outputs/viz_02_weekday_weekend.png)
*Clear drop in weekend activity presents opportunity for targeted campaigns*

### Sleep Analysis
![Sleep Distribution](outputs/viz_04_sleep_distribution.png)
*Average sleep duration is healthy, but adoption of sleep tracking is low*

### Hourly Patterns
![Hourly Activity](outputs/viz_07_hourly_pattern.png)
*Peak activity during lunch and post-work hours*

---

## 💡 Business Recommendations

### 1. **Target "Aspirational Achievers"**
Focus marketing on women averaging 7,500 steps who want to reach 10,000. Emphasize gradual progress over perfection.

**Tactics:**
- Realistic goal-setting during onboarding
- Celebrate milestone achievements (8K, 9K steps)
- "Every step forward counts" messaging

### 2. **Weekend Wellness Initiative**
Launch campaigns to maintain weekday momentum through weekends.

**Tactics:**
- Friday evening: "Keep your streak going!" notifications
- Weekend-specific activity suggestions (family walks, hiking)
- "Weekend Warrior" badge system

### 3. **Holistic Wellness Positioning**
Differentiate from fitness-only trackers by emphasizing comprehensive health.

**Tactics:**
- "Fitness trackers tell you to move more. Bellabeat Time helps you move better AND rest better"
- Sleep score feature with personalized insights
- Evening wind-down reminders

### 4. **Smart Notification Timing**
Send movement reminders during sedentary periods (10 AM, 3 PM), not during peak activity.

**Tactics:**
- Context-aware notifications based on user patterns
- Include quick 2-minute activity suggestions
- Allow "focus time" customization

### 5. **Engagement & Retention Strategy**
Build long-term usage through community and personalized insights.

**Tactics:**
- 30-day habit challenge at onboarding
- Weekly progress reports with personalized coaching
- Monthly wellness score (activity + sleep + consistency)

---

## 🛠️ Tools & Technologies

- **R** - Data cleaning, analysis, and visualization
- **tidyverse** - Data manipulation (dplyr, tidyr)
- **ggplot2** - Data visualization
- **lubridate** - Date/time handling
- **RStudio Cloud** - Development environment

---

## 📁 Project Structure

```
bellabeat-wellness-analysis/
├── scripts/
│   ├── 01_data_loading.R          # Data import and initial exploration
│   ├── 02_data_cleaning.R         # Data cleaning and preparation
│   ├── 03_analysis.R              # Core analysis and visualizations
│   └── 04_recommendations.R       # Business recommendations
├── outputs/
│   ├── viz_01_activity_distribution.png
│   ├── viz_02_weekday_weekend.png
│   └── ... (11 total visualizations)
└── README.md
```

---

## 📊 Data Source

**FitBit Fitness Tracker Data** (CC0: Public Domain)
- Source: [Kaggle](https://www.kaggle.com/datasets/arashnic/fitbit)
- Sample: 33 users over 31 days (April-May 2016)
- Metrics: Daily activity, sleep, heart rate

### Data Limitations
- Small sample size (33 users)
- Short time period (31 days)
- 2016 data (behaviors may have evolved)
- No demographic verification (couldn't confirm women users)

---

## 🚀 How to Reproduce This Analysis

1. Download the FitBit dataset from [Kaggle](https://www.kaggle.com/datasets/arashnic/fitbit)
2. Install required R packages: `tidyverse`, `lubridate`, `scales`
3. Run scripts in order: 01 → 02 → 03 → 04
4. Visualizations will be saved to `outputs/` folder

---

## 📧 Contact

**Sabrina Hoyle**
- GitHub: [@sabrinahhoyle](https://github.com/sabrinahhoyle)
- LinkedIn: [https://www.linkedin.com/in/sabrinahoyle/]
- Email: [sabrinahhoyle@gmail.com]

---

## 📝 Project Context

This case study was completed as the capstone project for the **Google Data Analytics Professional Certificate**. It demonstrates end-to-end data analysis skills including:
- Business problem definition
- Data cleaning and preparation
- Exploratory data analysis
- Statistical analysis and visualization
- Business insight generation
- Actionable recommendation development

---

*Project completed: December 2024*
