# =============================================================================
# BIT316 R Programming - Assignment 1: Data Structures & Data Wrangling
# Author : Allarayam Amane Gedeon (400622039486)
# Dataset: dplyr::storms (Atlantic tropical storm tracks), saved as a CSV
# Run    : open in RStudio and source the whole script (Ctrl+Shift+Enter)
# =============================================================================

# ---- 0. Packages (all library() calls live here) ---------------------------
library(tidyverse)   # loads readr, dplyr, tidyr, tibble, ggplot2, etc.

# ---- 0b. Make sure the data file exists ------------------------------------
# WHY: the brief says the script must load data from a file in the repository.
# If data/storms.csv is missing, we create it once from the built-in dataset
# so the script still runs on any machine.
if (!dir.exists("data")) dir.create("data")
if (!file.exists("data/storms.csv")) {
  write_csv(dplyr::storms, "data/storms.csv")
}


# =============================================================================
# PART A - NATIVE DATA STRUCTURES
# =============================================================================

## A1. Vectors: vectorised operations and indexing -----------------------------
# A numeric vector (wind speeds in knots) and a character vector (storm names)
wind_knots <- c(35, 50, 65, 80, 110, 140)
storm_names <- c("Ana", "Bill", "Claudette", "Danny", "Elsa", "Fred")

# Vectorised operation: R applies the arithmetic to every element at once
wind_kmh <- wind_knots * 1.852          # convert knots to km/h
wind_kmh
mean(wind_knots)                         # a summary of the whole vector

# Indexing / subsetting: by position, by negative position, and by condition
wind_knots[2]                            # 2nd element
wind_knots[c(1, 3)]                      # 1st and 3rd elements
wind_knots[-1]                           # everything except the first
storm_names[wind_knots > 64]             # names of storms above 64 knots
toupper(storm_names)                     # vectorised string function

## A2. Factor: categorical data -----------------------------------------------
# WHY a factor: categories with a fixed set of values (levels) are stored
# efficiently and can be ordered, which matters for modelling and plotting.
intensity_chr <- c("weak", "moderate", "strong", "moderate", "weak", "strong")
intensity <- factor(intensity_chr,
                    levels = c("weak", "moderate", "strong"),
                    ordered = TRUE)
levels(intensity)                        # show the levels
table(intensity)                         # count per level

## A3. List: mixed types, access by name and position -------------------------
storm_info <- list(
  name     = "Katrina",                  # character
  year     = 2005L,                      # integer
  winds    = c(100, 150, 175),           # numeric vector
  landfall = TRUE                        # logical
)
storm_info$name                          # by name with $
storm_info[["year"]]                     # by name with [[ ]]
storm_info[[3]]                          # by position (the winds vector)
storm_info[[3]][2]                       # element 2 inside element 3

## A4. Matrix and data frame built by hand ------------------------------------
m <- matrix(1:6, nrow = 2, ncol = 3,
            dimnames = list(c("row1", "row2"), c("a", "b", "c")))
m
m["row1", ]                              # a row
m[, "b"]                                 # a column
m[2, 3]                                  # a single cell

small_df <- data.frame(
  storm = storm_names,
  wind  = wind_knots,
  level = intensity
)
small_df[2, ]                            # a row
small_df$wind                            # a column (vector)
small_df[["storm"]]                      # a column by name
small_df[3, "wind"]                      # a single cell (row 3, column wind)


# =============================================================================
# PART B - IMPORTING & EXPLORING
# =============================================================================

## B1. Import with readr and confirm it loaded --------------------------------
storms_raw <- read_csv("data/storms.csv")
dim(storms_raw)                          # rows x columns
spec(storms_raw)                         # column types chosen by readr
class(storms_raw)

## B2. Overview ---------------------------------------------------------------
glimpse(storms_raw)
str(storms_raw)
summary(storms_raw)
head(storms_raw)

## B3. Missing values per column ----------------------------------------------
na_counts <- storms_raw %>%
  summarise(across(everything(), ~ sum(is.na(.x)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "n_missing") %>%
  arrange(desc(n_missing))
na_counts
# Reading the result: `category` is NA for anything that is not a hurricane,
# and the two *_diameter columns are NA before 2004 when they were not recorded.


# =============================================================================
# PART C - WRANGLING WITH dplyr & tidyr
# =============================================================================

## C1. Pipe chain: filter -> select -> mutate -> arrange ----------------------
# WHAT: strongest hurricane observations since 2000, with speed in km/h.
# WHY : each verb does one job, and the pipe reads top to bottom.
strong_hurricanes <- storms_raw %>%
  filter(status == "hurricane", year >= 2000) %>%        # rows
  select(name, year, month, wind, pressure, category) %>% # columns
  mutate(wind_kmh = round(wind * 1.852, 1)) %>%           # derived column
  arrange(desc(wind))                                      # strongest first
head(strong_hurricanes, 10)

## C2. Handle missing values --------------------------------------------------
# Choices (WHY):
# - category: NA simply means "not a hurricane", so it is not truly missing.
#   I replace it with 0 so it can be grouped and counted.
# - wind/pressure: needed for the summaries, so I drop rows where either is NA
#   rather than inventing values (imputing a physical measurement would bias
#   the averages).
# - diameter columns: NA means "not measured before 2004". I do NOT impute
#   these; I only drop NAs at the point where I use them (see C4).
storms_clean <- storms_raw %>%
  mutate(category = replace_na(category, 0)) %>%
  drop_na(wind, pressure)

nrow(storms_raw) - nrow(storms_clean)    # rows removed by drop_na()
# Result: 0 rows removed, because wind and pressure have no NAs in this dataset.
# The drop_na() is kept as a safety step so the code stays correct if the data changes.

## C3. group_by() + summarise(): several grouped statistics -------------------
yearly_summary <- storms_clean %>%
  group_by(year) %>%
  summarise(
    n_storms      = n_distinct(name),                 # count of distinct storms
    n_obs         = n(),                              # count of observations
    mean_wind     = mean(wind),                       # average wind (knots)
    max_wind      = max(wind),                        # peak wind (knots)
    mean_pressure = mean(pressure),                   # average pressure (mb)
    .groups = "drop"
  ) %>%
  arrange(year)
yearly_summary

status_summary <- storms_clean %>%
  group_by(status) %>%
  summarise(n_obs = n(), mean_wind = mean(wind), .groups = "drop") %>%
  arrange(desc(mean_wind))
status_summary

## C4. Reshape with pivot_longer() --------------------------------------------
# WHAT: average storm size, wide format has one column per diameter type.
diam_wide <- storms_clean %>%
  drop_na(tropicalstorm_force_diameter, hurricane_force_diameter) %>%
  group_by(year) %>%
  summarise(
    tropicalstorm_force_diameter = mean(tropicalstorm_force_diameter),
    hurricane_force_diameter     = mean(hurricane_force_diameter),
    .groups = "drop"
  )

diam_long <- diam_wide %>%
  pivot_longer(
    cols      = c(tropicalstorm_force_diameter, hurricane_force_diameter),
    names_to  = "diameter_type",
    values_to = "mean_diameter_nm"
  )
head(diam_long)
# WHY tidier: "diameter type" is now a variable (one column) and the value is
# one column, so each row is one observation. This makes it easy to group,
# filter, or plot both types with one ggplot call (colour = diameter_type).

# Optional: a quick plot built from the long data
ggplot(diam_long, aes(year, mean_diameter_nm, colour = diameter_type)) +
  geom_line() +
  labs(title = "Mean storm wind-field diameter by year",
       x = "Year", y = "Diameter (nautical miles)")

# ---- End of script ----------------------------------------------------------
