# nyc-crgb-open-data

Open-source prototype of a minimum public data foundation for a future Commercial Rent Guidelines Board (CRGB) in New York City. The project packages key commercial rent and vacancy indicators derived from public sources so small businesses, advocates, and policymakers share a common baseline. Code and documentation aim to be reproducible, transparent, and ready for NYC Open Data publication.

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

# restore R environment (after renv has been initialized)
# in R
 renv::restore()

# run pipeline from repo root
# in R
 source("code/01_ingest_storefronts.R")
 source("code/03_build_indicators.R")
```

## Notes
- Only aggregated, public data is stored in this repo; drop updated CSVs into `data-raw/storefront/` before running scripts.
- The initial example focuses on LL157 storefront statistics; additional geographies and indicators will be layered on in later iterations.
