# User guide

## Quick start
1. Drop updated LL157 storefront statistics into `data-raw/storefront/` (sample CSVs in the repo are illustrative, not official DOF numbers).
2. From the project root in R, run:
   ```r
   source("code/00_setup.R")
   source("code/01_ingest_storefronts.R")
   source("code/03_build_indicators.R")
   ```
   This writes cleaned storefront files to `data/storefront/` and a combined indicator table to `data/indicators/crgb_storefront_indicators.csv`.
3. Optional: run the whole pipeline (including the example viz) with `targets::tar_make()`.
4. Optional: create the sample chart with `source("viz/vacancy_rate_by_borough.R")`, which saves `viz/vacancy_rate_by_borough.png`.

## Interpreting the indicator table
`data/indicators/crgb_storefront_indicators.csv` contains one row per geography (borough or Council District) per year. Key fields:

- `year`: reporting year of the storefront registry statistics.
- `geography_type`, `geography_id`, `geography_name`: geography identifiers and labels.
- `total_storefronts`, `vacant_storefronts`: counts from LL157 storefront statistics (Class 1 plus Classes 2/4).
- `vacancy_rate`: `vacant_storefronts / total_storefronts`.
- `median_rent_psf`: median monthly rent per square foot (Class 2/4 only in this scaffold; `NA` elsewhere).
- Class-specific breakdowns (`total_storefronts_class1`, `total_storefronts_class2_4`, etc.) to support auditing and extensions.

## Example questions you can answer
- Compare vacancy rates by borough between 2022 and 2023.
- Identify geographies where vacancy exceeds a chosen threshold.
- Explore rent per square foot alongside vacancy for boroughs with available Class 2/4 data.
