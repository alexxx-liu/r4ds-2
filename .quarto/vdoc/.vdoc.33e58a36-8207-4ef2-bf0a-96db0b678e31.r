#
#
#
#
#
#
#
#
#
#| message: false
library(tidyverse)
library(readxl)
```
#
#| message: false
library(dplyr)

us_births <- read_excel("data/us_births_1994_2014.xlsx")
glimpse(us_births)
```
#
us_births <- read_excel("data/us_births_1994_2014.xlsx")
summary(us_births[c("births", "year")])
```
#
#| cache: true
births_tibble <- read_excel("data/us_births_1994_2014.xlsx") %>%
  mutate(day_of_week = factor(
    day_of_week,
    levels = c("Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"),
    ordered = TRUE
  ))
#
#
#
#| label: avg_births
avg_births <- births_tibble %>%
  group_by(month, date_of_month) %>%
  summarize(avg_births = mean(births, na.rm = TRUE), .groups = "drop")

print(head(avg_births))
#
#
#
#| label: births_heatmap
# create a month name column that works whether `month` is numeric or already a name
avg_births_plot <- avg_births %>%
  mutate(month_chr = as.character(month)) %>%
  mutate(month_name = ifelse(!is.na(suppressWarnings(as.integer(month_chr))),
                             month.name[as.integer(month_chr)],
                             month_chr),
         month_name = factor(month_name, levels = rev(month.name)))

library(ggplot2)
ggplot(avg_births_plot, aes(x = date_of_month, y = month_name, fill = avg_births)) +
  geom_tile() +
  scale_x_continuous(breaks = seq(1,31,by=2)) +
  scale_fill_gradient(low = "#ffffff", high = "#2166ac") +
  labs(x = "Date of month", y = "Month", fill = "Mean births") +
  theme_minimal()
#
#
#
#| label: dec25_analysis
# For each year compute Dec 25 births, baseline mean of Dec 20-24 and 27-30, weekday of Dec 25, and percent
dec25_stats <- births_tibble %>%
  filter(month == 12, date_of_month >= 20, date_of_month <= 30) %>%
  group_by(year) %>%
  summarize(
    dec25 = sum(births * (date_of_month == 25), na.rm = TRUE),
    baseline = mean(births[date_of_month %in% c(20:24, 27:30)], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # attach weekday for Dec 25 from the original tibble
  left_join(
    births_tibble %>% filter(month == 12, date_of_month == 25) %>% select(year, day_of_week),
    by = "year"
  ) %>%
  mutate(pct_of_baseline = ifelse(is.na(baseline) | baseline == 0, NA_real_, dec25 / baseline * 100))

print(dec25_stats)
#
#
#
#| label: christmas_summary
christmas_data <- dec25_stats
summary(christmas_data)
#
#
#
#| label: dec25_trend
dec25_plot <- dec25_stats %>%
  mutate(year = as.integer(year))

ggplot(dec25_plot, aes(x = year, y = pct_of_baseline, color = day_of_week)) +
  geom_line(aes(group = 1), color = "#2c3e50") +
  geom_point(size = 3) +
  scale_y_continuous(labels = scales::label_number(suffix = "%", accuracy = 0.1)) +
  labs(x = "Year", y = "Dec 25 as % of baseline", title = "Dec 25 births as percentage of surrounding baseline (colored by weekday)") +
  theme_minimal()
#
#
#
#
