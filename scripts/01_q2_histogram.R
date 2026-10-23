# ECO346 Assignment 1 — Question 2
# Variant 7: Balochistan, urban residents, ages 15–64

# 1. Set the working directory to the REPOSITORY ROOT.
# Edit this path if your folder is somewhere else.
setwd("C:/Users/hp/Downloads/ECO346-A1-FA24-BEDS-047-main/ECO346-A1-FA24-BEDS-047-main")

library(ggplot2)

# 2. Read the data
persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

# 3. Keep the household variables needed for the analysis
hh_info <- households[, c("hhid", "hhweight", "prov_code", "urban_rural")]

# 4. Join the two datasets using household ID
combined <- merge(persons, hh_info, by = "hhid", all.x = TRUE)

# 5. Select eligible earners
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

# 6. Weighted quantile function required for this assignment
weighted_quantile <- function(x, w, p) {
  keep <- !is.na(x) & is.finite(x) &
    !is.na(w) & is.finite(w) & w > 0
  
  x <- x[keep]
  w <- w[keep]
  
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  
  x[which(cumsum(w) / sum(w) >= p)[1]]
}

x <- earners$earn_annual
w <- earners$hhweight

# 7. Calculate and print statistics
n_earners <- nrow(earners)
unweighted_median <- median(x)
weighted_median <- weighted_quantile(x, w, 0.50)
weighted_p10 <- weighted_quantile(x, w, 0.10)
weighted_p90 <- weighted_quantile(x, w, 0.90)
p90_p10_ratio <- weighted_p90 / weighted_p10

# Histogram covers log10 earnings from 4.0 to 7.0
in_range <- x >= 10^4 & x < 10^7
excluded <- sum(!in_range)

cat("Number of eligible earners:", n_earners, "\n")
cat("Unweighted median (Rs):", unweighted_median, "\n")
cat("Weighted median (Rs):", weighted_median, "\n")
cat("Weighted P10 (Rs):", weighted_p10, "\n")
cat("Weighted P90 (Rs):", weighted_p90, "\n")
cat("P90/P10 ratio:", round(p90_p10_ratio, 2), "\n")
cat("Earners inside histogram range:", sum(in_range), "\n")
cat("Earners excluded from histogram:", excluded, "\n")

# 8. Prepare histogram data
hist_data <- earners[in_range, ]
hist_data$log_earnings <- log10(hist_data$earn_annual)

# 9. Create and save the weighted histogram
p2 <- ggplot(
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
    xintercept = log10(weighted_median),
    linetype = "dashed",
    linewidth = 0.8
  ) +
  geom_vline(
    xintercept = log10(weighted_p90),
    linetype = "dashed",
    linewidth = 0.8
  ) +
  annotate(
    "text",
    x = log10(weighted_median),
    y = Inf,
    label = paste0("Weighted median: Rs ",
                   format(round(weighted_median), big.mark = ",")),
    angle = 90,
    vjust = 1.2,
    hjust = 1.1,
    size = 3
  ) +
  annotate(
    "text",
    x = log10(weighted_p90),
    y = Inf,
    label = paste0("Weighted P90: Rs ",
                   format(round(weighted_p90), big.mark = ",")),
    angle = 90,
    vjust = -0.2,
    hjust = 1.1,
    size = 3
  ) +
  scale_x_continuous(
    breaks = 4:7,
    labels = c("Rs 10,000", "Rs 100,000",
               "Rs 1,000,000", "Rs 10,000,000"),
    limits = c(4, 7)
  ) +
  labs(
    title = "Annual earnings among urban earners in Balochistan",
    subtitle = "A weighted distribution of positive annual earnings",
    x = "Annual earnings (rupees; logarithmic scale)",
    y = "Weighted density per log10 earnings unit",
    caption = paste0(
      "Source: PSLM person and household data. ",
      "Sample: ages 15–64, positive annual earnings, ",
      "Balochistan (province code 4), urban (code 2). ",
      "Household weights used. Histogram excludes ",
      excluded, " earners outside Rs 10,000–10,000,000."
    )
  ) +
  theme_minimal(base_size = 11)

print(p2)

# 10. Save the figure as SVG
if (!dir.exists("figures")) dir.create("figures")
ggsave(
  "figures/q2_histogram.svg",
  plot = p2,
  width = 10,
  height = 6,
  units = "in"
)