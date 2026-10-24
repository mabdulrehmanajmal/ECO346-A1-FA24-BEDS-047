# ECO346 Assignment 1 - Q3: Earnings by Age Group
# Variant 7: Urban Balochistan

library(ggplot2)

persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

hh_info <- households[, c(
  "hhid", "hhweight", "prov_code", "urban_rural"
)]

combined <- merge(persons, hh_info, by = "hhid")

# Select eligible earners in urban Balochistan
earners <- subset(
  combined,
  prov_code == 4 &
    urban_rural == 2 &
    age >= 15 & age <= 64 &
    is.finite(earn_annual) & earn_annual > 0 &
    is.finite(hhweight) & hhweight > 0
)

# Create five-year age bands
breaks <- seq(15, 65, by = 5)

earners$age_band <- cut(
  earners$age,
  breaks = breaks,
  right = FALSE,
  include.lowest = TRUE,
  labels = paste(
    seq(15, 60, by = 5),
    seq(19, 64, by = 5),
    sep = "-"
  )
)

# Calculate weighted mean and unweighted sample size
bands <- split(earners, earners$age_band)

age_summary <- do.call(rbind, lapply(names(bands), function(band) {
  d <- bands[[band]]
  
  data.frame(
    age_band = band,
    midpoint = mean(range(as.numeric(
      as.character(d$age)
    ))),
    n_earners = nrow(d),
    weighted_mean_earnings = weighted.mean(
      d$earn_annual, d$hhweight
    )
  )
}))

# Use the correct midpoint for each five-year band
age_summary$midpoint <- seq(17, 62, by = 5)
age_summary$thin <- age_summary$n_earners < 30

# Print results in the Console
age_summary$weighted_mean_earnings <-
  round(age_summary$weighted_mean_earnings)

print(age_summary, row.names = FALSE)

# Identify the age band with the highest weighted mean
top <- age_summary[
  which.max(age_summary$weighted_mean_earnings), 
]

# Plot individual earners and weighted mean by age band
p <- ggplot(
  earners,
  aes(x = age, y = earn_annual)
) +
  geom_point(
    position = position_jitter(width = 0.35, height = 0),
    alpha = 0.25,
    size = 1.3
  ) +
  geom_line(
    data = age_summary,
    aes(
      x = midpoint,
      y = weighted_mean_earnings,
      group = 1
    ),
    inherit.aes = FALSE,
    linewidth = 0.8
  ) +
  geom_point(
    data = age_summary,
    aes(
      x = midpoint,
      y = weighted_mean_earnings,
      shape = thin
    ),
    inherit.aes = FALSE,
    size = 3.5
  ) +
  geom_label(
    data = top,
    aes(
      x = midpoint,
      y = weighted_mean_earnings * 1.35,
      label = paste("Highest mean:", age_band)
    ),
    inherit.aes = FALSE,
    size = 3
  ) +
  scale_x_continuous(
    breaks = seq(15, 65, by = 5)
  ) +
  scale_y_log10(
    breaks = c(10000, 100000, 1000000, 10000000),
    labels = c("10,000", "100,000", "1,000,000", "10,000,000")
  ) +
  coord_cartesian(ylim = c(10000, 10000000)) +
  scale_shape_manual(
    values = c(`FALSE` = 16, `TRUE` = 1),
    labels = c(`FALSE` = "n ≥ 30", `TRUE` = "n < 30")
  ) +
  labs(
    title = "Annual earnings by age group in urban Balochistan",
    x = "Age (years)",
    y = "Annual earnings (rupees, log scale)",
    shape = "Age-band sample size",
    caption = paste(
      "Source: PSLM 2019-20. Ages 15-64 with positive earnings;",
      "weighted means use hhweight.",
      "Hollow markers indicate fewer than 30 earners."
    )
  ) +
  theme_minimal(base_size = 11)

dir.create("figures", showWarnings = FALSE)

ggsave(
  "figures/q3_age_profile.svg",
  plot = p,
  width = 10,
  height = 6
)

print(p)

cat("\nQ3 figure saved to figures/q3_age_profile.svg\n")