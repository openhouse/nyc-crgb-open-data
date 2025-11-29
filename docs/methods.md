# Methods

- **Data source:** Aggregated Local Law 157 storefront registration statistics published by NYC Department of Finance on NYC Open Data:
  - `Storefront Registration Class 2 and 4 Statistics` (`dxru-eun8`)
  - `Storefront Registration Statistics for Designated Class One` (`x3n4-h56k`)
  Sample CSVs in `data-raw/storefront/` are synthetic placeholders shaped to those schemas for pipeline testing.
- **Public-only scope:** The repository works exclusively with public aggregates—no confidential microdata (e.g., RPIE filings) are ingested. Property-level LL157 data (`Storefronts Reported Vacant or Not`, `92iy-9c3n`) will only be used once an open-data–appropriate path is defined.
- **Cleaning:** Column names are standardized to snake_case with `janitor::clean_names()`. Core identifiers (`year`, `geography_type`, `geography_id`, `geography_name`) and counts are cast to consistent types. If upstream count or rent fields change, extend the ingest coalescing logic before typing.
- **Indicators:**
  - `vacancy_rate = vacant_storefronts / total_storefronts` (set to `NA` when totals are zero).
  - `median_rent_psf` currently reflects Classes 2/4 storefront statistics only; Class 1 does not report rent in this scaffold.
- **Outputs:** `data/indicators/crgb_storefront_indicators.csv` provides one row per geography-year with totals, class breakdowns, vacancy rate, and median rent per square foot. This forms the first slice of the “minimum open data foundation” envisioned for a future CRGB; see `docs/indicator_roadmap.md` for planned extensions (additional geographies, rent deltas, property-level QA).
