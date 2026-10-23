# ECO346 Assignment 1 - Question 4
# Default scatterplot BEFORE redesign

setwd("C:/Users/hp/Downloads/ECO346-A1-FA24-BEDS-047-main/ECO346-A1-FA24-BEDS-047-main")

library(ggplot2)

# Load the data
persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

# Join household variables to person records
hh_info <- households[, c("hhid", "hhweight", "prov_code", "urban_rural")]
combined <- merge(persons, hh_info, by = "hhid", all.x = TRUE)

# Select the same eligible earners used in Questions 2 and 3
earners <- subset(
  combined,
  prov_code == 4 &
    urban_rural == 2 &
    age >= 15 & age <= 64 &
    earn_annual > 0 &
    !is.na(hhweight) &
    is.finite(hhweight) &
    hhweight > 0
)

# Required default plot: no extra layers or styling
p_default <- ggplot(earners, aes(age, earn_annual)) +
  geom_point()

# Display the default plot
print(p_default)

# Save as SVG
if (!dir.exists("figures")) {
  dir.create("figures")
}

ggsave(
  "figures/default.svg",
  plot = p_default,
  width = 8,
  height = 5,
  units = "in"
)

cat("Saved default figure to figures/default.svg\n")
