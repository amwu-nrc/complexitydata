## code to prepare `atlas_pci` dataset goes here
library(haven)
library(dplyr)

country_hsproduct4digit_year <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/country_hsproduct4digit_year.dta")

atlas_pci <- country_hsproduct4digit_year |>
  distinct(year, hs_product_code, pci)

usethis::use_data(atlas_pci, overwrite = TRUE, compress = "xz")


atlas_eci <- country_hsproduct4digit_year |>
  distinct(year, location_code, hs_eci)

usethis::use_data(atlas_eci, overwrite = TRUE, compress = "xz")


atlas_economic_complexity <- country_hsproduct4digit_year |>
  select(year, export_value, location_code, hs_product_code)

usethis::use_data(atlas_economic_complexity, compress = "xz", overwrite = TRUE)

country_sitcproduct4digit_year <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/country_sitcproduct4digit_year.dta")

atlas_eci_sitc <- country_sitcproduct4digit_year |>
  distinct(year, location_code, sitc_eci)

usethis::use_data(atlas_eci_sitc, overwrite = TRUE, compress = "xz")

