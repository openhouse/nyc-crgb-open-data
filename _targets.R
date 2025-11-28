# Minimal targets pipeline to build CRGB storefront indicators

library(targets)
source(here::here("code", "00_setup.R"))
tar_option_set(packages = c("tidyverse", "here", "yaml", "sf"))

list(
  tar_target(
    ingest_storefronts,
    {
      source(here::here("code", "01_ingest_storefronts.R"))
      data_path("storefront", "storefront_stats_class2_4_clean.rds")
    },
    format = "file"
  ),
  tar_target(
    build_indicators,
    {
      source(here::here("code", "03_build_indicators.R"))
      data_path("indicators", "crgb_storefront_indicators.csv")
    },
    format = "file",
    cue = tar_cue(mode = "always")
  )
)
