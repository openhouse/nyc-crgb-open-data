# Purpose: Visualize Council District vacancy rates for the latest year available.

source(here::here("code", "00_setup.R"))

indicator_path <- data_path("indicators", "crgb_storefront_indicators.csv")
if (!file.exists(indicator_path)) {
  stop("Indicator file not found. Run code/03_build_indicators.R first.")
}

indicators <- readr::read_csv(indicator_path, show_col_types = FALSE)

council <- indicators |>
  filter(geography_type == "council district") |>
  filter(!is.na(vacancy_rate_all))

theme_fun <- function() {
  if (
    requireNamespace("councildown", quietly = TRUE) &&
      "theme_council" %in% getNamespaceExports("councildown")
  ) {
    return(councildown::theme_council())
  }
  theme_minimal()
}

if (nrow(council) == 0) {
  stop("No Council District vacancy data found in indicators.")
}

latest_year <- max(council$year, na.rm = TRUE)
latest <- council |>
  filter(year == latest_year) |>
  mutate(
    vacancy_pct = vacancy_rate_all * 100,
    geography_name = forcats::fct_reorder(geography_name, vacancy_pct)
  )

p <- ggplot(latest, aes(x = vacancy_pct, y = geography_name, fill = vacancy_pct)) +
  geom_col() +
  labs(
    title = "Council District storefront vacancy (latest year)",
    subtitle = glue::glue("Vacant storefronts reported (not leased) / total storefronts, {latest_year}"),
    x = "Vacancy rate (%)",
    y = "Council District",
    fill = "Vacancy rate",
    caption = "Includes districts where LL157 aggregate vacancies are published; suppressed values are omitted."
  ) +
  scale_fill_distiller(palette = "PuBu", direction = 1) +
  theme_fun()

ggsave(filename = viz_path("vacancy_rate_by_council_district.png"), plot = p, width = 9, height = 7, dpi = 300)
message("Saved viz/vacancy_rate_by_council_district.png")
