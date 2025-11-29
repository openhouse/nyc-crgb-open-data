# nyc-crgb-open-data

Open-source prototype of a minimum public data foundation for a future Commercial Rent Guidelines Board (CRGB) in New York City. The project packages key commercial rent and vacancy indicators derived from public sources so small businesses, advocates, and policymakers share a common baseline. Code and documentation aim to be reproducible, transparent, and ready for NYC Open Data publication. Each run starts from Local Law 157 storefront registration statistics (sample CSVs are included) and outputs a tidy indicator table with vacancy and rent per square foot by geography and year.

## Repository structure
- `docs/` – narrative documentation including problem framing, methods, and user guidance.
- `spec/` – machine-readable indicator and dataset definitions.
- `data-raw/` – source extracts (public only), organized by domain.
- `data/` – cleaned and derived tables ready for analysis and publication.
- `code/` – R scripts to move from raw inputs to indicators.
- `viz/` – exported charts and maps.

## Getting started
```bash
# clone
 git clone <repo-url>
 cd nyc-crgb-open-data

# install dependencies (recommended)
# in R
 install.packages("renv")
 renv::restore()

# manual fallback (if you prefer base R installs)
# in R
 source("code/install_deps.R")

# run pipeline from repo root
# in R
 source("code/00_setup.R")
 source("code/01_ingest_storefronts.R")
 source("code/03_build_indicators.R")

# optional: rebuild everything (including viz) with targets
# in R
 targets::tar_make()
```

The pipeline reads public LL157 storefront CSVs from `data-raw/storefront/`, writes cleaned RDS/CSV files into `data/storefront/`, and produces `data/indicators/crgb_storefront_indicators.csv` with vacancy and rent-per-square-foot indicators by geography and year.

## Notes
- Only aggregated, public data is stored in this repo; drop updated CSVs into `data-raw/storefront/` before running scripts.
- The initial example uses synthetic LL157 storefront statistics shaped to match NYC Open Data aggregates; swap in official exports without changing code.
- The initial example focuses on LL157 storefront statistics; additional geographies and indicators will be layered on in later iterations.
- See `docs/indicator_roadmap.md` for the planned indicator suite and implementation status.
