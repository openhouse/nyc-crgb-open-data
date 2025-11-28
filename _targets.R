# Minimal targets pipeline to build CRGB storefront indicators

library(targets)
source(here::here("code", "00_setup.R"))
tar_option_set(packages = c("tidyverse", "here", "yaml", "sf", "janitor", "glue"))

list(
  tar_target(
    storefront_raw_class2_4,
    data_raw_path("storefront", "storefront_stats_class2_4.csv"),
    format = "file"
  ),
  tar_target(
    storefront_raw_class1,
    data_raw_path("storefront", "storefront_stats_class1.csv"),
    format = "file"
  ),
  tar_target(
    storefront_clean_files,
    {
      storefront_raw_class2_4
      storefront_raw_class1
      source(here::here("code", "01_ingest_storefronts.R"))
      run_ingest_storefronts()
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
