# Indicator roadmap (draft)

This checklist tracks how the nyc-crgb-open-data scaffold grows from the
current LL157 storefront sample into a fuller open-data foundation for a
future Commercial Rent Guidelines Board (CRGB).

## Phase 0 – Environment and reproducibility
- [ ] Set up `renv` and commit a stable `renv.lock` for the project.
- [ ] Confirm `targets::tar_make()` runs from a clean clone via `renv::restore()`.
- [ ] Keep visualization dependencies optional (graceful fallback when `councildown` is absent).

## Phase 1 – LL157 storefront indicators (current scaffold)
- [x] Ingest synthetic LL157 storefront statistics for tax Class 1 and Classes 2/4 from `data-raw/storefront/*.csv` and write cleaned RDS/CSV files to `data/storefront/`.
- [x] Build `data/indicators/crgb_storefront_indicators.csv` with:
  - [x] `total_storefronts` and `vacant_storefronts` by geography and year.
  - [x] `vacancy_rate = vacant_storefronts / total_storefronts`.
  - [x] `median_rent_psf` for Classes 2/4.
- [x] Produce a borough-level vacancy-rate chart (`viz/vacancy_rate_by_borough.png`) as an end-to-end smoke test.
- [ ] Align ingest column names and types to the official NYC Open Data LL157 aggregates:
  - `Storefront Registration Class 2 and 4 Statistics` (`dxru-eun8`).
  - `Storefront Registration Statistics for Designated Class One` (`x3n4-h56k`).
- [ ] Extend geographies beyond boroughs as the aggregates allow (e.g., Council Districts, corridors/BIDs) while keeping validation checks (`vacancy_rate` within [0, 1], `vacant_storefronts <= total_storefronts`).

## Phase 2 – Property-level storefront registry (NYC Open Data)
- [ ] Define ingest and validation for the property-level `Storefronts Reported Vacant or Not` dataset (`92iy-9c3n`).
- [ ] Aggregate the property-level data to geography-year and compare against the published LL157 aggregate tables for consistency.
- [ ] Document the joins and caveats in `docs/methods.md` and `spec/datasets.yml` once available.

## Phase 3 – Extended indicator families (rent levels and change)
- [ ] Add rent distribution and change measures (e.g., quartiles, 1/3/5-year deltas) alongside median rent psf.
- [ ] Add simple year-over-year vacancy deltas and quality/coverage indicators.
- [ ] Ensure indicator definitions and units are captured in `spec/indicators.yml` with source dataset references.

## Phase 4 – Context, equity, and governance
- [ ] Join storefront indicators to land-use context (PLUTO or similar) for corridor-level metrics (commercial floor area, counts of ground-floor lots).
- [ ] Add hooks for equity and small-business questions (e.g., pairing rent pressure with public measures of neighborhood precarity).
- [ ] Expand `docs/user_guide.md` with applied examples and `docs/methods.md` with indicator-by-indicator definitions, suppression rules, and caveats.
- [ ] Prepare publication-ready metadata so `data/indicators/crgb_storefront_indicators.csv` can eventually align with NYC Open Data expectations.
