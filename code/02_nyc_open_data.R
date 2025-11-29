# Purpose: Lightweight helpers for reading NYC Open Data CSV endpoints and caching snapshots.

source(here::here("code", "00_setup.R"))

read_nyc_open_data_csv <- function(dataset_id, limit = 500000, app_token = Sys.getenv("NYC_OPEN_DATA_APP_TOKEN", "")) {
  stopifnot(!is.null(dataset_id), nzchar(dataset_id))

  # Format the limit as a plain integer string to avoid scientific notation (e.g., 5e+05)
  limit_int <- as.integer(limit)[1]
  limit_chr <- format(limit_int, scientific = FALSE, trim = TRUE)

  base_url <- glue::glue("https://data.cityofnewyork.us/resource/{dataset_id}.csv")
  query <- glue::glue("$limit={limit_chr}")

  url <- paste0(base_url, "?", query)
  if (nzchar(app_token)) {
    url <- paste0(url, glue::glue("&$$app_token={app_token}"))
  }

  if (tolower(Sys.getenv("CRGB_DEBUG_OPEN_DATA", "false")) %in% c("true", "t", "1", "yes", "y")) {
    message("Fetching NYC Open Data CSV: ", url)
  }

  readr::read_csv(url, show_col_types = FALSE)
}

fetch_nyc_open_data_snapshot <- function(dataset_id,
                                         out_path,
                                         limit = 500000,
                                         app_token = Sys.getenv("NYC_OPEN_DATA_APP_TOKEN", ""),
                                         refresh = FALSE) {
  refresh <- isTRUE(refresh) || identical(tolower(refresh), "true")

  if (!file.exists(out_path) || refresh) {
    dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
    df <- read_nyc_open_data_csv(dataset_id, limit = limit, app_token = app_token)
    readr::write_csv(df, out_path)
  }

  out_path
}
