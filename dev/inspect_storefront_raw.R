#!/usr/bin/env Rscript

# Quick helper to peek at the latest NYC Open Data storefront snapshots.

source(here::here("code", "00_setup.R"))

paths <- list.files(data_raw_path("storefront"), pattern = "\\.csv$", full.names = TRUE)

if (length(paths) == 0) {
  message("No storefront snapshots found in ", data_raw_path("storefront"), ".")
  quit(status = 0)
}

purrr::walk(paths, function(p) {
  cat(paste0("\n=== ", p, " ===\n"))
  df <- readr::read_csv(p, n_max = 5, show_col_types = FALSE) |>
    janitor::clean_names()
  print(names(df))
  print(utils::head(df, 2))
})
