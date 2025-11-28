# Purpose: Load core packages and define helper utilities for file paths and specs.

suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(here)
  library(yaml)
  library(targets)
  library(gt)
  library(glue)
  library(janitor)
  # councilverse loads councildown themes; safe to skip if not installed
  if (requireNamespace("councilverse", quietly = TRUE)) {
    library(councilverse)
  }
})

# Construct a path within data-raw/
data_raw_path <- function(...) {
  here::here("data-raw", ...)
}

# Construct a path within data/
data_path <- function(...) {
  here::here("data", ...)
}

# Construct a path within viz/
viz_path <- function(...) {
  here::here("viz", ...)
}

# Read a YAML specification file and return as a tibble for convenience
read_spec <- function(path) {
  yaml::read_yaml(path) |> purrr::map_dfr(~as_tibble(.x))
}

# Retrieve a dataset specification (from spec/datasets.yml) by id
dataset_spec <- function(dataset_id) {
  specs <- yaml::read_yaml(here::here("spec", "datasets.yml"))
  match <- purrr::keep(specs, ~.x$id == dataset_id)
  if (length(match) == 0) {
    stop(glue::glue("Dataset spec '{dataset_id}' not found in spec/datasets.yml"))
  }
  match[[1]]
}

# Ensure a data frame includes all required columns listed in spec/datasets.yml
validate_required_columns <- function(df, dataset_id) {
  spec <- dataset_spec(dataset_id)
  required <- if (is.null(spec$key_columns)) character(0) else spec$key_columns
  missing <- setdiff(required, names(df))
  if (length(missing) > 0) {
    stop(glue::glue("Missing required columns for {dataset_id}: {paste(missing, collapse = ', ')}"))
  }
  invisible(TRUE)
}
