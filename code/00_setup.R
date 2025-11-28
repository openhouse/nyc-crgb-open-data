# Purpose: Load core packages and define helper utilities for file paths and specs.

suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(here)
  library(yaml)
  library(targets)
  library(gt)
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
