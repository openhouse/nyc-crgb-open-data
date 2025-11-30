# Purpose: Basic QA comparing raw LL157 borough aggregates against indicator outputs.

source(here::here("code", "00_setup.R"))

summarise_borough_raw <- function(df, class_label) {
  df |>
    filter(geography_type == "borough") |>
    mutate(class = class_label) |>
    group_by(year, geography_name, class) |>
    summarise(
      total_storefronts = sum(total_storefronts, na.rm = TRUE),
      vacant_storefronts = ifelse(
        all(is.na(vacant_storefronts)),
        NA_real_,
        sum(vacant_storefronts, na.rm = TRUE)
      ),
      .groups = "drop"
    )
}

write_ll157_borough_comparison <- function() {
  class2_4 <- readr::read_rds(data_path("storefront", "storefront_stats_class2_4_clean.rds"))
  class1 <- readr::read_rds(data_path("storefront", "storefront_stats_class1_clean.rds"))
  indicators <- readr::read_csv(data_path("indicators", "crgb_storefront_indicators.csv"), show_col_types = FALSE)

  borough_raw <- bind_rows(
    summarise_borough_raw(class2_4, "class2_4"),
    summarise_borough_raw(class1, "class1")
  )

  borough_combined <- borough_raw |>
    group_by(year, geography_name) |>
    summarise(
      total_storefronts_raw = sum(total_storefronts, na.rm = TRUE),
      raw_vacancy_suppressed = any(is.na(vacant_storefronts) & !is.na(total_storefronts)),
      vacant_storefronts_raw = dplyr::case_when(
        raw_vacancy_suppressed ~ NA_real_,
        TRUE ~ sum(dplyr::coalesce(vacant_storefronts, 0), na.rm = TRUE)
      ),
      .groups = "drop"
    )

  indicator_borough <- indicators |>
    filter(geography_type == "borough") |>
    select(
      year,
      geography_name,
      total_storefronts_all,
      vacant_storefronts_all,
      vacancy_rate_all,
      has_full_class1_vacancy,
      has_full_class24_vacancy
    ) |>
    rename(
      total_storefronts_indicators = total_storefronts_all,
      vacant_storefronts_indicators = vacant_storefronts_all,
      vacancy_rate_indicators = vacancy_rate_all
    )

  comparison <- borough_combined |>
    left_join(indicator_borough, by = c("year", "geography_name")) |>
    mutate(
      diff_total_storefronts = total_storefronts_indicators - total_storefronts_raw,
      diff_vacant_storefronts = vacant_storefronts_indicators - vacant_storefronts_raw
    ) |>
    arrange(year, geography_name)

  out_dir <- data_path("qa")
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  out_file <- file.path(out_dir, "ll157_borough_comparison.csv")
  readr::write_csv(comparison, out_file)
  invisible(out_file)
}

if (sys.nframe() == 0) {
  out <- write_ll157_borough_comparison()
  message("Wrote QA comparison to ", out)
}
