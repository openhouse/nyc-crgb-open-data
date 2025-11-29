# Purpose: Read LL157 storefront statistics (Classes 1, 2/4) from NYC Open Data or local fixtures,
# standardize column names, and save cleaned RDS/CSV files.

source(here::here("code", "00_setup.R"))
source(here::here("code", "02_nyc_open_data.R"))

bool_env <- function(x, default = TRUE) {
  val <- Sys.getenv(x, ifelse(default, "true", "false"))
  tolower(val) %in% c("true", "t", "1", "yes", "y")
}

parse_int <- function(x) {
  readr::parse_integer(x, na = c("", "NA", "*"), locale = readr::locale(grouping_mark = ","))
}

parse_num <- function(x) {
  readr::parse_number(x, na = c("", "NA", "*"), locale = readr::locale(grouping_mark = ","))
}

standardize_geography_id <- function(geography_type, geography_name) {
  ifelse(
    geography_type == "borough",
    dplyr::recode(
      stringr::str_to_upper(geography_name),
      "MANHATTAN" = "MN",
      "BRONX" = "BX",
      "BROOKLYN" = "BK",
      "QUEENS" = "QN",
      "STATEN ISLAND" = "SI",
      .default = geography_name
    ),
    geography_name
  )
}

read_storefront_stats <- function(path, open_data_id = NULL, use_open_data = TRUE, refresh = FALSE) {
  if (use_open_data && !is.null(open_data_id)) {
    path <- fetch_nyc_open_data_snapshot(open_data_id, path, refresh = refresh)
  }

  if (!use_open_data && !file.exists(path)) {
    synthetic_path <- here::here(
      "tests", "fixtures", "storefront",
      paste0(tools::file_path_sans_ext(basename(path)), "_synthetic.csv")
    )
    if (file.exists(synthetic_path)) {
      path <- synthetic_path
    }
  }

  if (!file.exists(path)) {
    stop(glue::glue("Expected storefront stats at {path} or a valid open_data_id."))
  }

  df <- readr::read_csv(path, show_col_types = FALSE) |>
    janitor::clean_names()

  required_raw <- c(
    "reporting_year",
    "aggregate_level_citywide",
    "aggregate_level_id",
    "total_storefronts",
    "storefront_reported_not_leased"
  )

  required_clean <- c(
    "year", "geography_type", "geography_id", "geography_name",
    "total_storefronts", "vacant_storefronts", "vacancy_rate", "median_rent_psf"
  )

  has_open_data_schema <- all(required_raw %in% names(df))
  has_canonical_schema <- all(required_clean %in% names(df))

  if (!has_open_data_schema && !has_canonical_schema) {
    stop(glue::glue(
      "Unexpected storefront schema. Expected Open Data columns ({paste(required_raw, collapse = ', ')}) or canonical columns ({paste(required_clean, collapse = ', ')}), got: {paste(names(df), collapse = ', ')}"
    ))
  }

  if (has_open_data_schema) {
    has_rent <- "median_monthly_rent_per_square" %in% names(df)

    df <- df |>
      transmute(
        year = as.integer(parse_int(reporting_year)),
        geography_type = aggregate_level_citywide |>
          stringr::str_to_lower() |>
          stringr::str_replace_all("_", " ") |>
          stringr::str_squish(),
        geography_name = aggregate_level_id |>
          stringr::str_squish() |>
          stringr::str_to_title(),
        geography_id = standardize_geography_id(geography_type, geography_name),
        total_storefronts = parse_int(total_storefronts),
        vacant_storefronts = parse_int(storefront_reported_not_leased),
        median_rent_psf = if (has_rent) parse_num(median_monthly_rent_per_square) else NA_real_
      )
  } else {
    df <- df |>
      transmute(
        year = as.integer(parse_int(year)),
        geography_type = stringr::str_squish(stringr::str_to_lower(geography_type)),
        geography_name = as.character(geography_name),
        geography_id = as.character(geography_id),
        total_storefronts = parse_int(total_storefronts),
        vacant_storefronts = parse_int(vacant_storefronts),
        median_rent_psf = if ("median_rent_psf" %in% names(df)) parse_num(median_rent_psf) else NA_real_
      )
  }

  df <- df |>
    mutate(
      vacancy_rate = dplyr::if_else(total_storefronts > 0, vacant_storefronts / total_storefronts, NA_real_),
      geography_id = as.character(geography_id),
      geography_name = as.character(geography_name)
    )

  missing_clean <- setdiff(required_clean, names(df))
  if (length(missing_clean) > 0) {
    stop(glue::glue("Missing required cleaned columns: {paste(missing_clean, collapse = ', ')}"))
  }

  if (any(df$vacant_storefronts > df$total_storefronts, na.rm = TRUE)) {
    stop("Vacant storefront counts exceed totals in the raw data.")
  }
  if (any(df$vacancy_rate < 0 | df$vacancy_rate > 1, na.rm = TRUE)) {
    stop("Vacancy rate outside [0,1] after computation.")
  }

  df
}

run_ingest_storefronts <- function(use_open_data = bool_env("CRGB_USE_OPEN_DATA", TRUE),
                                   refresh_open_data = bool_env("CRGB_REFRESH_OPEN_DATA", FALSE)) {
  dir.create(data_path("storefront"), showWarnings = FALSE, recursive = TRUE)

  spec_24 <- dataset_spec("storefront_stats_class2_4")
  spec_1 <- dataset_spec("storefront_stats_class1")

  class2_4_raw_path <- data_raw_path(spec_24$raw_path)
  class1_raw_path <- data_raw_path(spec_1$raw_path)

  storefront_stats_class2_4 <- read_storefront_stats(
    class2_4_raw_path,
    open_data_id = spec_24$open_data_id,
    use_open_data = use_open_data,
    refresh = refresh_open_data
  )

  storefront_stats_class1 <- read_storefront_stats(
    class1_raw_path,
    open_data_id = spec_1$open_data_id,
    use_open_data = use_open_data,
    refresh = refresh_open_data
  )

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
