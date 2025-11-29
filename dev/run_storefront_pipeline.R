#!/usr/bin/env Rscript

# One-command entrypoint to restore packages and run the storefront targets pipeline.

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

renv::restore(prompt = FALSE)

if (requireNamespace("dotenv", quietly = TRUE) && file.exists(".env")) {
  dotenv::load_dot_env(".env")
}

source(here::here("code", "00_setup.R"))

targets::tar_make()
