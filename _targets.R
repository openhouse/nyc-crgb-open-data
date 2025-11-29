# Minimal targets pipeline to build CRGB storefront indicators

library(targets)
source(here::here("code", "00_setup.R"))
source(here::here("code", "02_nyc_open_data.R"))
tar_option_set(packages = c("tidyverse", "here", "yaml", "sf", "janitor", "glue"))

use_open_data <- tolower(Sys.getenv("CRGB_USE_OPEN_DATA", "true")) %in% c("true", "t", "1", "yes", "y")
refresh_open_data <- tolower(Sys.getenv("CRGB_REFRESH_OPEN_DATA", "false")) %in% c("true", "t", "1", "yes", "y")

list(
  tar_target(
    storefront_raw_class2_4,
    {
      spec <- dataset_spec("storefront_stats_class2_4")
      if (use_open_data && !is.null(spec$open_data_id)) {
        fetch_nyc_open_data_snapshot(
          dataset_id = spec$open_data_id,
          out_path = data_raw_path(spec$raw_path),
          refresh = refresh_open_data
        )
      } else {
        data_raw_path(spec$raw_path)
      }
    },
    format = "file"
  ),
  tar_target(
    storefront_raw_class1,
    {
      spec <- dataset_spec("storefront_stats_class1")
      if (use_open_data && !is.null(spec$open_data_id)) {
        fetch_nyc_open_data_snapshot(
          dataset_id = spec$open_data_id,
          out_path = data_raw_path(spec$raw_path),
          refresh = refresh_open_data
        )
      } else {
        data_raw_path(spec$raw_path)
      }
    },
    format = "file"
  ),
  tar_target(
    storefront_clean_files,
    {
      storefront_raw_class2_4
      storefront_raw_class1
      source(here::here("code", "01_ingest_storefronts.R"))
      run_ingest_storefronts(use_open_data = use_open_data, refresh_open_data = refresh_open_data)
    },
    format = "file"
  ),
  tar_target(
    crgb_storefront_indicators,
    {
      storefront_clean_files
      source(here::here("code", "03_build_indicators.R"))
      build_storefront_indicators()
    },
    format = "file"
  ),
  tar_target(
    vacancy_rate_by_borough_png,
    {
      crgb_storefront_indicators
      source(here::here("viz", "vacancy_rate_by_borough.R"))
      viz_path("vacancy_rate_by_borough.png")
    },
    format = "file"
  )
)
