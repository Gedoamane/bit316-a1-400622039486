# BIT316 Assignment 1 – Data Structures & Data Wrangling

**Student:** Allarayam Amane Gedeon (400622039486)

**Course:** BIT316 R Programming, BlueCrest College, Ghana

## Dataset
`dplyr::storms` – Atlantic tropical storm tracks, 1975–2022 (name, date, position,
wind speed, pressure, status, category, storm diameters). Stored as
`data/storms.csv` (19,537 rows × 13 columns). If the file is missing, the script
recreates it from the built-in dataset.

## Packages required
- R 4.1 or newer
- `tidyverse` (readr, dplyr, tidyr, ggplot2)

```r
install.packages("tidyverse")
```

## How to run
1. Clone the repository and open the folder in RStudio (or set it as the working directory).
2. Open `bit316_a1.R` and run it top to bottom, or from the console:
   ```r
   source("bit316_a1.R")
   ```

A log of a full successful run is in `console_log.txt`.

## Script structure
- **Part A** – vectors, factor, list, matrix, data frame
- **Part B** – import with `read_csv()`, overview, missing-value report
- **Part C** – dplyr pipe chain, grouped summaries, NA handling, `pivot_longer()`
- **Part D** – this README, comments, and the Git history

## Summary of findings
- The dataset has **19,537 rows and 13 columns**. Only three columns have missing
  values: `category` (14,734, because it is recorded only for hurricanes) and the
  two diameter columns (9,512 each, because diameters were not measured before 2004).
- `wind` and `pressure` have no missing values, so `drop_na()` removed 0 rows.
- **2020** had the most distinct named storms (30), followed by 2005 (29). The
  highest peak wind was **165 knots in 1980**, with 160 knots in 1988 and 2005.
- Hurricanes had the highest mean wind speed (**86.6 knots**) and the lowest mean
  pressure (**969 mb**), compared with 45.7 knots and 999 mb for tropical storms.
- 2,642 hurricane observations since 2000 were extracted; the strongest were
  Wilma (2005) and Dorian (2019) at 160 knots (about 296 km/h).
- Reshaping the two diameter columns with `pivot_longer()` put "diameter type" in
  one column, which made it possible to plot both over time with a single `ggplot()` call.

## References
- R for Data Science (2e), Wickham, Çetinkaya-Rundel & Grolemund
- dplyr and tidyr documentation, https://dplyr.tidyverse.org
