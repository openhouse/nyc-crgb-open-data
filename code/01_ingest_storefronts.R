# Purpose: Read LL157 storefront statistics CSVs, standardize column names, and save cleaned RDS files.

source(here::here("code", "00_setup.R"))

read_storefront_stats <- function(path) {
  if (!file.exists(path)) {
    stop(glue::glue("Expected storefront stats at {path}. Drop the CSV in data-raw/storefront/ and rerun."))
  }

  df <- readr::read_csv(path, show_col_types = FALSE) |>
    janitor::clean_names()

  has_rent <- "median_rent_psf" %in% names(df)

  df <- df |>
    mutate(
      year = as.integer(year),
      geography_type = stringr::str_to_lower(geography_type),
      geography_id = as.character(geography_id),
      geography_name = as.character(geography_name),
      total_storefronts = as.integer(total_storefronts),
      vacant_storefronts = as.integer(vacant_storefronts)
    )

  df <- if (has_rent) {
    df |>
      mutate(median_rent_psf = as.numeric(median_rent_psf))
  } else {
    df |>
      mutate(median_rent_psf = NA_real_)
  }

  # If DOF tweaks upstream column names, we may need to extend the cleaning logic above
  # to coalesce alternate count fields before applying types.
  df
}

run_ingest_storefronts <- function() {
  dir.create(data_path("storefront"), showWarnings = FALSE, recursive = TRUE)

  class2_4_raw <- data_raw_path("storefront", "storefront_stats_class2_4.csv")
  class1_raw <- data_raw_path("storefront", "storefront_stats_class1.csv")

  storefront_stats_class2_4 <- read_storefront_stats(class2_4_raw)
  storefront_stats_class1 <- read_storefront_stats(class1_raw)

  class2_4_out <- data_path("storefront", "storefront_stats_class2_4_clean.rds")
  class1_out <- data_path("storefront", "storefront_stats_class1_clean.rds")

  readr::write_rds(storefront_stats_class2_4, class2_4_out)
  readr::write_rds(storefront_stats_class1, class1_out)

  # Optional CSV outputs for quick inspection
  readr::write_csv(storefront_stats_class2_4, sub("\\.rds$", ".csv", class2_4_out))
  readr::write_csv(storefront_stats_class1, sub("\\.rds$", ".csv", class1_out))

  invisible(c(class2_4 = class2_4_out, class1 = class1_out))
}

if (sys.nframe() == 0) {
  run_ingest_storefronts()
  message("Saved cleaned storefront stats to data/storefront/.")
}
