# Minimal dependency installer for the nyc-crgb-open-data project.
# Run from the project root: source("code/install_deps.R")

  pkgs <- `c(
    "here",
    "tidyverse",
    "sf",
    "yaml",
    "targets",
    "gt",
    "glue",
    "janitor",
    "councilverse",
    "councildown"
  )`

to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) {
  install.packages(to_install)
}
