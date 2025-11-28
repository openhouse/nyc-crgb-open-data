# Purpose: Read LL157 storefront statistics CSVs, standardize column names, and save cleaned RDS files.

source(here::here("code", "00_setup.R"))

# helper to standardize column names to snake_case
clean_names <- function(df) {
  names(df) <- names(df) |>
    stringr::str_replace_all("[ .]+", "_") |>
    stringr::str_replace_all("[^A-Za-z0-9_]+", "") |>
    stringr::str_to_lower()
  df
}

read_storefront_stats <- function(path) {
  readr::read_csv(path, show_col_types = FALSE) |>
    clean_names() |>
    mutate(
      year = as.integer(year),
      geography_type = stringr::str_to_lower(geography_type),
      geography_id = as.character(geography_id),
      geography_name = as.character(geography_name),
      total_storefronts = as.integer(total_storefronts),
      vacant_storefronts = as.integer(vacant_storefronts),
      median_rent_psf = ifelse("median_rent_psf" %in% names(.), as.numeric(median_rent_psf), NA_real_)
    )
}

# ensure output directory exists
dir.create(data_path("storefront"), showWarnings = FALSE, recursive = TRUE)

class2_4_raw <- data_raw_path("storefront", "storefront_stats_class2_4.csv")
class1_raw <- data_raw_path("storefront", "storefront_stats_class1.csv")

storefront_stats_class2_4 <- read_storefront_stats(class2_4_raw)
storefront_stats_class1 <- read_storefront_stats(class1_raw)

readr::write_rds(storefront_stats_class2_4, data_path("storefront", "storefront_stats_class2_4_clean.rds"))
readr::write_rds(storefront_stats_class1, data_path("storefront", "storefront_stats_class1_clean.rds"))

message("Saved cleaned storefront stats to data/storefront/.")
