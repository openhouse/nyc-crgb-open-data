# Purpose: Quick visualization of vacancy rates by borough over time.

source(here::here("code", "00_setup.R"))

indicator_path <- data_path("indicators", "crgb_storefront_indicators.csv")
indicators <- readr::read_csv(indicator_path, show_col_types = FALSE)

boroughs <- indicators |>
  filter(geography_type == "borough") |>
  mutate(vacancy_pct = vacancy_rate * 100)

theme_fun <- function() {
  if (requireNamespace("councildown", quietly = TRUE)) {
    return(councildown::theme_council())
  }
  theme_minimal()
}

p <- ggplot(boroughs, aes(x = year, y = vacancy_pct, color = geography_name, group = geography_name)) +
  geom_line(size = 1) +
  geom_point() +
  labs(
    title = "Storefront vacancy rate by borough",
    subtitle = "Illustrative values from LL157 storefront statistics",
    x = "Year",
    y = "Vacancy rate (%)",
    color = "Borough"
  ) +
  theme_fun()

ggsave(filename = viz_path("vacancy_rate_by_borough.png"), plot = p, width = 8, height = 5, dpi = 300)
message("Saved viz/vacancy_rate_by_borough.png")
