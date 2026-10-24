# ECO346 Assignment 1 - Q2 Weighted Earnings Histogram
# Variant 7: Urban Balochistan

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

weighted_quantile <- function(x, w, p) {
  keep <- is.finite(x) & is.finite(w) & w > 0
  x <- x[keep]
  w <- w[keep]
  
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  
  x[which(cumsum(w) / sum(w) >= p)[1]]
}

rs <- function(x) {
  paste0("Rs ", formatC(round(x), format = "d", big.mark = ","))
}

x <- earners$earn_annual
w <- earners$hhweight

median_unweighted <- median(x)
median_weighted <- weighted_quantile(x, w, 0.50)
p10 <- weighted_quantile(x, w, 0.10)
p90 <- weighted_quantile(x, w, 0.90)

in_range <- x >= 10000 & x < 10000000
hist_data <- earners[in_range, ]
hist_data$log_earnings <- log10(hist_data$earn_annual)
excluded <- sum(!in_range)

cat("Eligible earners:", nrow(earners), "\n")
cat("Unweighted median:", rs(median_unweighted), "\n")
cat("Weighted median:", rs(median_weighted), "\n")
cat("Weighted P10:", rs(p10), "\n")
cat("Weighted P90:", rs(p90), "\n")
cat("P90/P10 ratio:", sprintf("%.2f", p90 / p10), "\n")
cat("Excluded from histogram:", excluded, "\n")

p <- ggplot(
  hist_data,
  aes(x = log_earnings, weight = hhweight)
) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = 0.1,
    boundary = 4,
    closed = "left",
    fill = "steelblue",
    colour = "white"
  ) +
  geom_vline(
    xintercept = log10(c(median_weighted, p90)),
    linetype = "dashed"
  ) +
  scale_x_continuous(
    breaks = 4:7,
    labels = rs(10^(4:7))
  ) +
  labs(
    title = "Distribution of annual earnings in urban Balochistan",
    subtitle = paste(
      "Weighted median:", rs(median_weighted),
      "| Weighted P90:", rs(p90)
    ),
    x = "Annual earnings (rupees, logarithmic scale)",
    y = "Weighted density per log10 unit",
    caption = paste0(
      "Source: PSLM 2019-20. Ages 15-64 with positive earnings; ",
      "weighted by hhweight. Histogram exclusions: ", excluded, "."
    )
  ) +
  theme_minimal(base_size = 11)

dir.create("figures", showWarnings = FALSE)

ggsave(
  "figures/q2_histogram.svg",
  plot = p,
  width = 10,
  height = 6
)

print(p)
cat("Q2 histogram saved successfully.\n")