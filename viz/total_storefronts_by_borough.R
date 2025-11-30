# Purpose: Plot total storefront counts by borough over time.

source(here::here("code", "00_setup.R"))

indicator_path <- data_path("indicators", "crgb_storefront_indicators.csv")
if (!file.exists(indicator_path)) {
  stop("Indicator file not found. Run code/03_build_indicators.R first.")
}

indicators <- readr::read_csv(indicator_path, show_col_types = FALSE)

boroughs <- indicators |>
  filter(geography_type == "borough") |>
  select(year, geography_name, total_storefronts_all) |>
  mutate(total_storefronts_all = as.numeric(total_storefronts_all))

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

p <- ggplot(boroughs, aes(x = year, y = total_storefronts_all, color = geography_name, group = geography_name)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Reported storefront counts by borough",
    subtitle = "Total storefronts reported under LL157, Classes 1 & 2/4",
    x = "Year",
    y = "Total storefronts",
    color = "Borough",
    caption = "Counts reflect LL157 storefront registrations; coverage may vary by borough and year."
  ) +
  scale_colour_fun() +
  theme_fun()

ggsave(filename = viz_path("total_storefronts_by_borough.png"), plot = p, width = 8, height = 5, dpi = 300)
message("Saved viz/total_storefronts_by_borough.png")
