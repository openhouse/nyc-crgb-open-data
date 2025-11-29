# Purpose: Quick visualization of vacancy rates by borough over time.

source(here::here("code", "00_setup.R"))

indicator_path <- data_path("indicators", "crgb_storefront_indicators.csv")
if (!file.exists(indicator_path)) {
  stop("Indicator file not found. Run code/03_build_indicators.R first.")
}

indicators <- readr::read_csv(indicator_path, show_col_types = FALSE)

boroughs <- indicators |>
  filter(geography_type == "borough") |>
  mutate(vacancy_pct = vacancy_rate * 100)

theme_fun <- function() {
  if (
    requireNamespace("councildown", quietly = TRUE) &&
      "theme_council" %in% getNamespaceExports("councildown")
  ) {
    return(councildown::theme_council())
  }
  theme_minimal()
}

scale_colour_fun <- function() {
  if (
    requireNamespace("councildown", quietly = TRUE) &&
      "scale_colour_council" %in% getNamespaceExports("councildown")
  ) {
    return(councildown::scale_colour_council())
  }
  scale_color_brewer(palette = "Set2")
}

p <- ggplot(boroughs, aes(x = year, y = vacancy_pct, color = geography_name, group = geography_name)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Storefront vacancy rate by borough",
    subtitle = "Illustrative values from LL157 storefront statistics",
    x = "Year",
    y = "Vacancy rate (%)",
    color = "Borough"
  ) +
  scale_colour_fun() +
  theme_fun()

ggsave(filename = viz_path("vacancy_rate_by_borough.png"), plot = p, width = 8, height = 5, dpi = 300)
message("Saved viz/vacancy_rate_by_borough.png")
