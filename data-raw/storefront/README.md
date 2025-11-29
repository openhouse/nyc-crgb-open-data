Snapshots of the Local Law 157 storefront aggregate tables downloaded from
NYC Open Data live here. These CSVs are written automatically by the targets
pipeline via `fetch_nyc_open_data_snapshot()` and should **always** represent
public data from:

- `Storefront Registration Class 2 and 4 Statistics` (`dxru-eun8`)
- `Storefront Registration Statistics for Designated Class One` (`x3n4-h56k`)

Synthetic fixtures have been moved to `tests/fixtures/storefront/` to avoid
confusion. If you need to refresh the snapshots, set `CRGB_REFRESH_OPEN_DATA=true`
and rerun the pipeline.
