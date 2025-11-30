# Purpose: Build CRGB storefront indicators from cleaned LL157 storefront statistics.

source(here::here("code", "00_setup.R"))

summarise_storefronts <- function(df, class_label) {
  df |>
    mutate(class = class_label) |>
    group_by(year, geography_type, geography_id, geography_name, class) |>
    summarise(
      total_storefronts = sum(total_storefronts, na.rm = TRUE),
      vacant_storefronts = ifelse(
        all(is.na(vacant_storefronts)),
        NA_integer_,
        sum(vacant_storefronts, na.rm = TRUE)
      ),
      median_rent_psf = ifelse(
        all(is.na(median_rent_psf)),
        NA_real_,
        weighted.mean(median_rent_psf, w = total_storefronts, na.rm = TRUE)
      ),
      vacancy_rate = dplyr::if_else(
        !is.na(vacant_storefronts) & total_storefronts > 0,
        vacant_storefronts / total_storefronts,
        NA_real_
      ),
      .groups = "drop"
    )
}

build_storefront_indicators <- function() {
  class2_4 <- readr::read_rds(data_path("storefront", "storefront_stats_class2_4_clean.rds"))
  class1 <- readr::read_rds(data_path("storefront", "storefront_stats_class1_clean.rds"))

  validate_required_columns(class2_4, "storefront_stats_class2_4")
  validate_required_columns(class1, "storefront_stats_class1")

  combined <- bind_rows(
    summarise_storefronts(class2_4, "class2_4"),
    summarise_storefronts(class1, "class1")
  ) |>
    tidyr::pivot_wider(
      names_from = class,
      values_from = c(total_storefronts, vacant_storefronts, vacancy_rate, median_rent_psf),
      names_glue = "{.value}_{class}",
      values_fill = list(
        total_storefronts = NA_integer_,
        vacant_storefronts = NA_integer_,
        vacancy_rate = NA_real_,
        median_rent_psf = NA_real_
      )
    ) |>
    mutate(
      total_storefronts_all = rowSums(
        dplyr::select(., starts_with("total_storefronts_")),
        na.rm = TRUE
      ),
      total_storefronts_all = if_else(
        if_all(starts_with("total_storefronts_"), is.na),
        NA_real_,
        total_storefronts_all
      ),
      class24_vacancy_suppressed = is.na(vacant_storefronts_class2_4) & !is.na(total_storefronts_class2_4),
      class1_vacancy_suppressed = is.na(vacant_storefronts_class1) & !is.na(total_storefronts_class1),
      vacant_storefronts_all = dplyr::case_when(
        class24_vacancy_suppressed | class1_vacancy_suppressed ~ NA_real_,
        TRUE ~ rowSums(
          dplyr::select(., starts_with("vacant_storefronts_")) |>
            dplyr::mutate(dplyr::across(everything(), ~ dplyr::coalesce(.x, 0))),
          na.rm = TRUE
        )
      ),
      vacancy_rate_all = dplyr::if_else(
        !is.na(vacant_storefronts_all) & total_storefronts_all > 0,
        vacant_storefronts_all / total_storefronts_all,
        NA_real_
      ),
      median_rent_psf_class2_4 = median_rent_psf_class2_4,
      has_full_class24_vacancy = !class24_vacancy_suppressed | is.na(total_storefronts_class2_4),
      has_full_class1_vacancy = !class1_vacancy_suppressed | is.na(total_storefronts_class1),
      vacancy_rate = vacancy_rate_all,
      total_storefronts = total_storefronts_all,
      vacant_storefronts = vacant_storefronts_all
    ) |>
    select(
      year,
      geography_type,
      geography_id,
      geography_name,
      total_storefronts,
      vacant_storefronts,
      vacancy_rate,
      median_rent_psf_class2_4,
      total_storefronts_class1,
      vacant_storefronts_class1,
      vacancy_rate_class1,
      total_storefronts_class2_4,
      vacant_storefronts_class2_4,
      vacancy_rate_class2_4,
      total_storefronts_all,
      vacant_storefronts_all,
      vacancy_rate_all,
      has_full_class1_vacancy,
      has_full_class24_vacancy
    ) |>
    arrange(year, geography_type, geography_id)

  validate_required_columns(combined, "crgb_storefront_indicators")

  if (any(combined$vacancy_rate_all < 0 | combined$vacancy_rate_all > 1, na.rm = TRUE)) {
    stop("Vacancy rate outside expected [0,1] range.")
  }
  if (any(combined$vacant_storefronts_all > combined$total_storefronts_all, na.rm = TRUE)) {
    stop("Vacant storefronts exceed totals for at least one geography.")
  }
  if (any(combined$vacant_storefronts_class2_4 > combined$total_storefronts_class2_4, na.rm = TRUE)) {
    stop("Vacant storefronts exceed totals for at least one geography in Class 2/4.")
  }
  if (any(combined$vacant_storefronts_class1 > combined$total_storefronts_class1, na.rm = TRUE)) {
    stop("Vacant storefronts exceed totals for at least one geography in Class 1.")
  }

  output_path <- data_path("indicators")
  dir.create(output_path, showWarnings = FALSE, recursive = TRUE)
  output_file <- file.path(output_path, "crgb_storefront_indicators.csv")

  readr::write_csv(combined, output_file)
  invisible(output_file)
}

if (sys.nframe() == 0) {
  output_file <- build_storefront_indicators()
  message("Wrote indicators to ", output_file)
}
