library(testthat)
here::i_am("tests/testthat.R")
source(here::here("code", "01_ingest_storefronts.R"))

testthat::test_dir(here::here("tests", "testthat"))
