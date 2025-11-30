# Methods

- **Data source:** Aggregated Local Law 157 storefront registration statistics published by NYC Department of Finance on NYC Open Data:
  - `Storefront Registration Class 2 and 4 Statistics` (`dxru-eun8`)
  - `Storefront Registration Statistics for Designated Class One` (`x3n4-h56k`)
  Snapshots are cached under `data-raw/storefront/` via `fetch_nyc_open_data_snapshot()` and refreshed when `CRGB_REFRESH_OPEN_DATA=true`. The default path always uses these public tables; synthetic fixtures live only under `tests/fixtures/storefront/` for offline development and require `CRGB_USE_OPEN_DATA=false` to engage. The helper forces `$limit` to a plain integer string to avoid scientific-notation queries (e.g., `5e+05`) that Socrata rejects. Parsing problems reported by `readr::read_csv()` are written to `data/qa/ll157_parsing_issues.csv` with dataset identifiers for easier triage.
- **Column mapping (Open Data schema → canonical):**
  - `reporting_year` → `year`
  - `aggregate_level_citywide` → `geography_type` (lower case, spaces instead of underscores)
  - `aggregate_level_id` → `geography_name`, with `geography_id` recoded to borough abbreviations (`MN`, `BX`, `BK`, `QN`, `SI`) when `geography_type == "borough"`
  - `total_storefronts` → `total_storefronts`
  - `storefront_reported_not_leased` → `vacant_storefronts`; `vacancy_rate` recomputed as `vacant_storefronts / total_storefronts`
  - `median_monthly_rent_per_square` → `median_rent_psf` (Classes 2/4 only; set to `NA` for Class 1)
- **Fallback schema:** For tiny synthetic fixtures or tests shaped like the canonical output (`year`, `geography_type`, `geography_id`, `geography_name`, `total_storefronts`, `vacant_storefronts`, `median_rent_psf`), the ingest step parses types and recomputes `vacancy_rate` before validation.
- **Data quirks:** Portal values may include commas or `*` suppressions; these are parsed as integers/doubles with `NA` where appropriate. Count fields are parsed with `parse_number()` using a comma grouping mark, coerced to integers, and guarded for any non-whole values. Parsing issues detected by `readr::problems()` are logged for inspection under `data/qa/ll157_parsing_issues.csv`. Geographies arrive at multiple levels (borough, citywide, census tract, Council District, etc.); we retain them for downstream use. Counts are validated to ensure `vacant_storefronts <= total_storefronts` and `vacancy_rate` remains within [0, 1].
- **Public-only scope:** The repository works exclusively with public aggregates—no confidential microdata (e.g., RPIE filings) are ingested. Property-level LL157 data (`Storefronts Reported Vacant or Not`, `92iy-9c3n`) will only be used once an open-data–appropriate path is defined.
- **Cleaning:** Column names are standardized to snake_case with `janitor::clean_names()`. Core identifiers (`year`, `geography_type`, `geography_id`, `geography_name`) and counts are cast to consistent types. If upstream count or rent fields change, extend the ingest coalescing logic before typing.
- **Indicators:**
  - Class-specific fields: `*_class1` and `*_class2_4` totals, vacancies, and vacancy rates.
  - Combined fields: `total_storefronts_all`, `vacant_storefronts_all`, and `vacancy_rate_all` (aliased to `total_storefronts`, `vacant_storefronts`, and `vacancy_rate` for compatibility). When vacancy counts are suppressed for a component class (e.g., borough-level Class 2/4 vacants), combined vacancies and rates are set to `NA` rather than zero. Coverage flags (`has_full_class1_vacancy`, `has_full_class24_vacancy`) highlight where vacancy rates are based on published counts.
  - `median_rent_psf_class2_4` reflects Classes 2/4 storefront statistics only; Class 1 does not report rent in this scaffold.
- **Outputs:** `data/indicators/crgb_storefront_indicators.csv` provides one row per geography-year with totals, class breakdowns, vacancy rate, and median rent per square foot. A QA comparison table at `data/qa/ll157_borough_comparison.csv` compares borough-level totals from the raw aggregates to the indicators. This forms the first slice of the “minimum open data foundation” envisioned for a future CRGB; see `docs/indicator_roadmap.md` for planned extensions (additional geographies, rent deltas, property-level QA).
