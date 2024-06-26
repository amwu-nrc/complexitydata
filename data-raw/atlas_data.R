## code to prepare `atlas_pci` dataset goes here
library(haven)
library(dplyr)

country_hsproduct4digit_year <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/country_hsproduct4digit_year.dta")

atlas_pci <- country_hsproduct4digit_year |>
  distinct(year, hs_product_code, pci)

usethis::use_data(atlas_pci, overwrite = TRUE, compress = "xz")


atlas_eci <- country_hsproduct4digit_year |>
  distinct(year, loction_code, eci)

usethis::use_data(atlas_eci, overwrite = TRUE, compress = "xz")

