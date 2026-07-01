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
library(readxl)
#
#
#
#| label: nba_recruits_summary
# Read NBA recruits, select columns, and show summary
nba_recruits <- read_excel("data/nba_recruits.xlsx") %>%
  select(rank, nba_mean_ws48, top_mean_wa, total_seasons, drafted)

summary(nba_recruits)
#
#
#
#| label: tier_counts
# Read full recruits file and count players by tier
tier_counts <- read_excel("data/nba_recruits.xlsx") %>%
  count(tier, name = "n") %>%
  arrange(desc(n))

print(tier_counts)
#
#
#
#
