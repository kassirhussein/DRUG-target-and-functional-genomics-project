# Drug-MOA Merger
# Author: Hussein
# Description: This R script merges known drug data with mechanism of action (MOA) information from local Parquet files.
# Outputs: Multiple CSVs with drug information

# Load required libraries
library(arrow)
library(dplyr)
library(tidyverse)

# Make sure to download OPEN TARGET files from https://platform.opentargets.org/downloads

# --- Load Known Drugs Data ---

# Set your folder path (adjust to your own machine)
folder_path_known_drugs <- "Your folder path//knowndrugs"

# Read all .parquet files and combine into one data frame
parquet_files_known_drugs <- list.files(folder_path_known_drugs, pattern = "\\.parquet$", full.names = TRUE)
known_drugs <- parquet_files_known_drugs %>%
  lapply(read_parquet) %>%
  bind_rows()

# --- Load Mechanism of Action (MOA) Data ---

folder_path_moa <- "Your folder path/drug_mechanism of action"
parquet_files_moa <- list.files(folder_path_moa, pattern = "\\.parquet$", full.names = TRUE)

moa <- parquet_files_moa %>%
  lapply(read_parquet) %>%
  bind_rows() %>%
  tidyr::unnest(cols = c(chemblIds))

# --- Merge Known Drugs with MOA ---

# Select only relevant columns from MOA
moa2 <- moa %>% select(1, 3)

# 'approved_indication' is used here but never defined
# Assuming you meant 'known_drugs' or another dataset
# Update this line once 'approved_indication' is clarified

approved_drug <- known_drugs %>%
  semi_join(approved_indication, by = c("drugId" = "id", "label" = "efoName")) %>%
  left_join(moa2, by = c("drugId" = "chemblIds"))


#  Write file output ----------------------------------

write.csv(approved_drug,"Your folder path/approved_drug.csv" )
