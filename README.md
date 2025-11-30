# nyc-crgb-open-data

Open-source prototype of a minimum public data foundation for a future Commercial Rent Guidelines Board (CRGB) in New York City. The pipeline starts from the official Local Law 157 storefront aggregates on NYC Open Data and produces vacancy and rent-per-square-foot indicators by geography and year—no synthetic placeholders in the default run.

## Quick start (one command)

From a clean clone:

```bash
git clone <repo-url>
cd nyc-crgb-open-data
Rscript dev/run_storefront_pipeline.R
```

The script will:

1. Install `{renv}` if needed and restore the project library.
2. Download LL157 storefront aggregate snapshots from NYC Open Data (`dxru-eun8` and `x3n4-h56k`).
3. Ingest, standardize, and validate the tables.
4. Build the indicator CSV, QA table, and example visualizations via `targets::tar_make()`.

Key outputs after it finishes:

- `data-raw/storefront/*.csv` – cached NYC Open Data snapshots (Classes 2/4 and Class 1).
- `data/storefront/storefront_stats_class2_4_clean.rds` and `storefront_stats_class1_clean.rds` (+ CSV mirrors).
- `data/indicators/crgb_storefront_indicators.csv` – vacancy and rent indicators by geography-year (combined and class-specific, with coverage flags).
- `data/qa/ll157_borough_comparison.csv` – borough-level QA comparing raw LL157 aggregates to indicator totals.
- `viz/vacancy_rate_by_borough.png`, `viz/total_storefronts_by_borough.png`, `viz/vacancy_rate_by_council_district.png` – reference charts built from the indicator table.

Prefer to run inside R? Execute:

```r
renv::restore()
targets::tar_make()
```

## Data sources

The default pipeline always fetches public NYC Open Data storefront aggregates (no token required, though an app token improves rate limits):

- `Storefront Registration Class 2 and 4 Statistics` (`dxru-eun8`)
- `Storefront Registration Statistics for Designated Class One` (`x3n4-h56k`)

Snapshots are written under `data-raw/storefront/` automatically. Synthetic fixtures now live only in `tests/fixtures/storefront/` for offline development and are ignored unless you explicitly opt out of Open Data.

## Environment variables

- `NYC_OPEN_DATA_APP_TOKEN` (optional): improves API rate limits. Set it in your shell or `~/.Renviron`. If `{dotenv}` is installed, a project-root `.env` will be loaded by `dev/run_storefront_pipeline.R`.
- `CRGB_USE_OPEN_DATA` (default `true`): developer escape hatch to bypass the portal; leave unset for real data.
- `CRGB_REFRESH_OPEN_DATA` (default `false`): set to `true` to force new snapshots.

## Repository structure

- `code/` – R scripts to move from raw inputs to indicators.
- `spec/` – dataset definitions and metadata.
- `data-raw/` – cached public snapshots.
- `data/` – cleaned and derived tables ready for analysis.
- `docs/` – narrative documentation (methods, roadmap, user guides).
- `viz/` – exported charts.

See `docs/indicator_roadmap.md` and `docs/methods.md` for more on the current scope and validation rules.
