## code to prepare `atlas_economic_complexity` dataset goes here
library(haven)
library(dplyr)

country_hsproduct4digit_year <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/country_hsproduct4digit_year.dta") |>
  select(year, export_value, location_code, hs_product_code)

usethis::use_data(atlas_economic_complexity, compress = "xz", overwrite = TRUE)
