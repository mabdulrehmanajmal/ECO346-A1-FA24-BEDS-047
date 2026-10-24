# ECO346 Assignment 1 - Data check
# Variant 7: Urban Balochistan

persons_file <- "data/pslm_person_subset.csv"
households_file <- "data/pslm_hh_subset.csv"

persons <- read.csv(persons_file)
households <- read.csv(households_file)

cat("Person records:", nrow(persons), "\n")
cat("Household records:", nrow(households), "\n")

required_person <- c("hhid", "age", "earn_annual")
required_household <- c(
  "hhid", "hhweight", "prov_code", "urban_rural"
)

stopifnot(all(required_person %in% names(persons)))
stopifnot(all(required_household %in% names(households)))

cat("Required columns are present.\n")
cat("Data check completed successfully.\n")
