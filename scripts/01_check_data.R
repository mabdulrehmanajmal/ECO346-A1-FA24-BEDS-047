# ECO346 Assignment 1
# Variant 7: Urban Balochistan

persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

# Check the column names
names(persons)
names(households)

# Display the first six rows
head(persons)
head(households)

# Count the rows in each file
nrow(persons)
nrow(households)