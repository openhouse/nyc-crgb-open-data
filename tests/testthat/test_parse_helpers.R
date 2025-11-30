test_that("parse_int handles commas and suppressions", {
  expect_equal(parse_int(c("5,511", "*", "0")), c(5511L, NA_integer_, 0L))
})

test_that("parse_num handles decimals and suppressions", {
  expect_equal(parse_num(c("1,234.5", "*", "10")), c(1234.5, NA_real_, 10))
})
