# Purpose: Build CRGB storefront indicators from cleaned LL157 storefront statistics.

source(here::here("code", "00_setup.R"))

class2_4 <- readr::read_rds(data_path("storefront", "storefront_stats_class2_4_clean.rds"))
class1 <- readr::read_rds(data_path("storefront", "storefront_stats_class1_clean.rds"))

summarise_storefronts <- function(df) {
  df |>
    group_by(year, geography_type, geography_id, geography_name) |>
    summarise(
      total_storefronts = sum(total_storefronts, na.rm = TRUE),
      vacant_storefronts = sum(vacant_storefronts, na.rm = TRUE),
      median_rent_psf = ifelse(
        all(is.na(median_rent_psf)),
        NA_real_,
        weighted.mean(median_rent_psf, w = total_storefronts, na.rm = TRUE)
      ),
      .groups = "drop"
    )
}

class2_4_agg <- summarise_storefronts(class2_4) |>
  rename(
    total_storefronts_class2_4 = total_storefronts,
    vacant_storefronts_class2_4 = vacant_storefronts,
    median_rent_psf_class2_4 = median_rent_psf
  )

class1_agg <- summarise_storefronts(class1) |>
  rename(
    total_storefronts_class1 = total_storefronts,
    vacant_storefronts_class1 = vacant_storefronts
  )

combined <- full_join(class2_4_agg, class1_agg, by = c("year", "geography_type", "geography_id", "geography_name")) |>
  mutate(
    total_storefronts = coalesce(total_storefronts_class2_4, 0) + coalesce(total_storefronts_class1, 0),
    vacant_storefronts = coalesce(vacant_storefronts_class2_4, 0) + coalesce(vacant_storefronts_class1, 0),
    vacancy_rate = dplyr::if_else(total_storefronts > 0, vacant_storefronts / total_storefronts, NA_real_),
    median_rent_psf = median_rent_psf_class2_4
  ) |>
  select(
    year,
    geography_type,
    geography_id,
    geography_name,
    total_storefronts,
    vacant_storefronts,
    vacancy_rate,
    median_rent_psf,
    total_storefronts_class1,
    vacant_storefronts_class1,
    total_storefronts_class2_4,
    vacant_storefronts_class2_4,
    median_rent_psf_class2_4
  ) |>
  arrange(year, geography_type, geography_id)

# ensure output directory
output_path <- data_path("indicators")
dir.create(output_path, showWarnings = FALSE, recursive = TRUE)

readr::write_csv(combined, file.path(output_path, "crgb_storefront_indicators.csv"))

message("Wrote indicators to ", file.path(output_path, "crgb_storefront_indicators.csv"))
