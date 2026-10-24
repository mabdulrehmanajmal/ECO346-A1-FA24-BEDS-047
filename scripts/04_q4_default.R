
# ECO346 Assignment 1 - Q4: Default Plot
# Variant 7: Urban Balochistan
# Save this default figure before creating the redesign.

library(ggplot2)

persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

hh_info <- households[, c(
  "hhid", "hhweight", "prov_code", "urban_rural"
)]

combined <- merge(persons, hh_info, by = "hhid")

earners <- subset(
  combined,
  prov_code == 4 &
    urban_rural == 2 &
    age >= 15 & age <= 64 &
    is.finite(earn_annual) & earn_annual > 0 &
    is.finite(hhweight) & hhweight > 0
)

# Required default plot: no additional layers or styling
p_default <- ggplot(
  earners,
  aes(x = age, y = earn_annual)
) +
  geom_point()

dir.create("figures", showWarnings = FALSE)

ggsave(
  "figures/default.svg",
  plot = p_default,
  width = 8,
  height = 5,
  units = "in"
)

print(p_default)

cat(
  "Default plot saved to figures/default.svg\n",
  "Number of earners:", nrow(earners), "\n"
)