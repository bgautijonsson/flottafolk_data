# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c(
    "tibble",
    "eurostat",
    "dplyr",
    "tidyr",
    "arrow",
    "lubridate",
    "stringr",
    "metill"
    ), # packages that your targets need to run
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(
    name = beneficiaries,
    command = get_beneficiaries(),
    format = "file"
  ),
  tar_target(
    name = applicants,
    command = get_applicants(),
    format = "file"
  ),
  tar_target(
    name = grants,
    command = get_grants(),
    format = "file"
  ),
  tar_target(
    name = decisions,
    command = get_decisions(),
    format = "file"
  ),
  tar_target(
    name = population,
    command = get_population(),
    format = "file"
  ),
  tar_target(
    name = make_combined_data,
    command = combine_data(beneficiaries, applicants, grants, decisions, population),
    format = "file"
  ),
  tar_target(
    name = data,
    command = load_combined_data(make_combined_data)
  )
)
