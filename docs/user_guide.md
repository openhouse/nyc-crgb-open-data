# User guide

## Quick start
1. Drop updated LL157 storefront statistics into `data-raw/storefront/`. Sample CSVs in the repo are **synthetic placeholders** that mirror the NYC Open Data aggregates for:
   - `Storefront Registration Class 2 and 4 Statistics` (`dxru-eun8`)
   - `Storefront Registration Statistics for Designated Class One` (`x3n4-h56k`)
2. From the project root in R, install dependencies with renv (recommended):
   ```r
   install.packages("renv")
   renv::restore()
   ```
   If you prefer a manual install, run `source("code/install_deps.R")` instead.
3. Build the pipeline:
   ```r
   source("code/00_setup.R")
   source("code/01_ingest_storefronts.R")
   source("code/03_build_indicators.R")
   source("code/04_qa_ll157.R")
   ```
   This writes cleaned storefront files to `data/storefront/`, a combined indicator table to `data/indicators/crgb_storefront_indicators.csv`, and a QA comparison table to `data/qa/ll157_borough_comparison.csv`.
4. Optional: run the whole pipeline (including the example viz) with `targets::tar_make()`.
5. Optional: create the sample charts with `source("viz/vacancy_rate_by_borough.R")`, `source("viz/total_storefronts_by_borough.R")`, and `source("viz/vacancy_rate_by_council_district.R")` to save the respective PNGs under `viz/`.

## Interpreting the indicator table
`data/indicators/crgb_storefront_indicators.csv` contains one row per geography (borough or Council District) per year. Key fields:

- `year`: reporting year of the storefront registry statistics.
- `geography_type`, `geography_id`, `geography_name`: geography identifiers and labels.
- Combined counts and rates: `total_storefronts_all` (aliased to `total_storefronts`), `vacant_storefronts_all` (aliased to `vacant_storefronts`), and `vacancy_rate_all` (aliased to `vacancy_rate`). Combined vacancy is set to `NA` where component vacancies are suppressed.
- Class-specific breakdowns and rates (`total_storefronts_class1`, `total_storefronts_class2_4`, `vacancy_rate_class1`, `vacancy_rate_class2_4`) to support auditing and extensions.
- `median_rent_psf_class2_4`: median monthly rent per square foot (Class 2/4 only in this scaffold; `NA` elsewhere).
- Coverage flags: `has_full_class1_vacancy` and `has_full_class24_vacancy` indicate whether vacancy counts were published for each component class.

See `docs/indicator_roadmap.md` for the planned extensions (additional geographies, property-level LL157 data, and broader CRGB indicator families).

## Example questions you can answer
- Compare vacancy rates by borough between 2022 and 2023.
- Identify geographies where vacancy exceeds a chosen threshold.
- Explore rent per square foot alongside vacancy for boroughs with available Class 2/4 data.
