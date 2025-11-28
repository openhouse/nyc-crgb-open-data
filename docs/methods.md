# Methods

- **Data source:** Local Law 157 storefront registration statistics published by NYC Department of Finance (aggregated CSVs). Sample CSVs in `data-raw/storefront/` are synthetic placeholders for pipeline testing.
- **Cleaning:** Column names are standardized to snake_case with `janitor::clean_names()`. Core identifiers (`year`, `geography_type`, `geography_id`, `geography_name`) and counts are cast to consistent types. If DOF renames upstream count fields, extend the ingest coalescing logic before typing.
- **Indicators:**
  - `vacancy_rate = vacant_storefronts / total_storefronts` (set to `NA` when totals are zero).
  - `median_rent_psf` currently reflects Classes 2/4 storefront statistics only; Class 1 does not report rent in this scaffold.
- **Outputs:** `data/indicators/crgb_storefront_indicators.csv` provides one row per geography-year with totals, class breakdowns, vacancy rate, and median rent per square foot.
