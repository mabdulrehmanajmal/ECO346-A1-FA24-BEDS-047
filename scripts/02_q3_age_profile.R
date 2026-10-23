# ECO346 Assignment 1 — Question 3
# Weighted earnings by five-year age band

setwd("C:/Users/hp/Downloads/ECO346-A1-FA24-BEDS-047-main/ECO346-A1-FA24-BEDS-047-main")
library(ggplot2)

# Load and join data
persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

hh_info <- households[, c("hhid", "hhweight", "prov_code", "urban_rural")]
combined <- merge(persons, hh_info, by = "hhid", all.x = TRUE)

# Eligible earners
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

# Weighted mean function
weighted_mean <- function(x, w) {
  sum(x * w) / sum(w)
}

# Create ten age bands: 15–19, 20–24, ..., 60–64
earners$age_band <- cut(
  earners$age,
  breaks = seq(15, 65, by = 5),
  right = FALSE,
  labels = c(
    "15-19", "20-24", "25-29", "30-34", "35-39",
    "40-44", "45-49", "50-54", "55-59", "60-64"
  )
)

# Midpoints for plotting
band_midpoints <- seq(17, 62, by = 5)

# Build the summary table
band_table <- do.call(
  rbind,
  lapply(levels(earners$age_band), function(band) {
    d <- earners[earners$age_band == band, ]
    
    data.frame(
      age_band = band,
      midpoint = mean(range(as.numeric(
        sub("^([0-9]+)-.*$", "\\1", band)
      ))),
      n_earners = nrow(d),
      weighted_mean_earnings = if (nrow(d) > 0) {
        weighted_mean(d$earn_annual, d$hhweight)
      } else {
        NA_real_
      }
    )
  })
)

# Set midpoints explicitly to 17, 22, ..., 62
band_table$midpoint <- band_midpoints

# Bands with fewer than 30 unweighted earners are thin
band_table$thin <- band_table$n_earners < 30

# Print table; round mean earnings to whole rupees
band_table$weighted_mean_earnings <- round(
  band_table$weighted_mean_earnings
)

print(band_table, row.names = FALSE)

# Find the highest weighted-mean age band
valid_means <- which(!is.na(band_table$weighted_mean_earnings))
highest_row <- valid_means[
  which.max(band_table$weighted_mean_earnings[valid_means])
]
highest_band <- band_table[highest_row, ]

cat("\nMean earnings for ages 25-29 (Rs):",
    band_table$weighted_mean_earnings[band_table$age_band == "25-29"],
    "\n")
cat("Mean earnings for ages 45-49 (Rs):",
    band_table$weighted_mean_earnings[band_table$age_band == "45-49"],
    "\n")
cat("Highest-mean age band:", as.character(highest_band$age_band), "\n")
cat("Highest weighted mean (Rs):",
    highest_band$weighted_mean_earnings, "\n")

# Jitter individual observations horizontally by no more than 0.4 years
set.seed(346)
earners$jitter_age <- earners$age + runif(nrow(earners), -0.4, 0.4)

# Separate band means into thin and non-thin points
band_table$point_shape <- ifelse(band_table$thin, 1, 19)

# Create age-profile figure
p3 <- ggplot() +
  geom_point(
    data = earners,
    aes(x = jitter_age, y = earn_annual),
    alpha = 0.20,
    size = 1.5,
    colour = "grey35"
  ) +
  geom_line(
    data = band_table,
    aes(x = midpoint, y = weighted_mean_earnings),
    linewidth = 0.8,
    colour = "steelblue"
  ) +
  geom_point(
    data = subset(band_table, !thin),
    aes(x = midpoint, y = weighted_mean_earnings),
    size = 3.5,
    shape = 19,
    colour = "steelblue"
  ) +
  geom_point(
    data = subset(band_table, thin),
    aes(x = midpoint, y = weighted_mean_earnings),
    size = 3.5,
    shape = 1,
    stroke = 1.2,
    colour = "steelblue"
  ) +
  annotate(
    "text",
    x = highest_band$midpoint,
    y = highest_band$weighted_mean_earnings,
    label = paste0(
      "Highest mean: ", highest_band$age_band
    ),
    vjust = -1,
    hjust = 0.5,
    size = 3.5
  ) +
  scale_x_continuous(
    breaks = seq(15, 65, by = 5),
    limits = c(14.5, 65)
  ) +
  scale_y_log10(
    limits = c(10000, 10000000),
    breaks = c(10000, 100000, 1000000, 10000000),
    labels = c("10,000", "100,000", "1,000,000", "10,000,000")
  ) +
  labs(
    title = "Annual earnings and age among urban earners in Balochistan",
    x = "Age (years)",
    y = "Annual earnings (rupees; logarithmic scale)",
    caption = paste0(
      "Source: PSLM person and household data. ",
      "Sample: ages 15–64 with positive annual earnings, ",
      "Balochistan, urban. Household weights used for means. ",
      "Points show individuals; large points show weighted age-band means. ",
      "Hollow means indicate bands with fewer than 30 earners."
    )
  ) +
  theme_minimal(base_size = 11)

print(p3)

# Save figure and table
if (!dir.exists("figures")) dir.create("figures")
ggsave(
  "figures/q3_age_profile.svg",
  plot = p3,
  width = 10,
  height = 6,
  units = "in"
)

write.csv(
  band_table,
  "figures/q3_age_band_table.csv",
  row.names = FALSE
)