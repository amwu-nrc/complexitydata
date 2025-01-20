## code to prepare `atlas_pci` dataset goes here
library(haven)
library(dplyr)
library(readr)

country_hsproduct4digit_year <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2022)/hs92_country_product_year_4.dta")
atlas_classification <- read_tsv("data-raw/misc/rankings.tab")
atlas_product_classification <- read_tsv("data-raw/misc/product_hs92.tab")

atlas_pci <- country_hsproduct4digit_year |>
  distinct(year, product_id, pci) |>
  inner_join(atlas_product_classification)

usethis::use_data(atlas_pci, overwrite = TRUE, compress = "xz")

atlas_country_classification <- read_tsv("data-raw/misc/location_country.tab")
atlas_eci <- atlas_classification |>
  distinct(year, country_id, hs_eci) |>
  inner_join(atlas_country_classification)

usethis::use_data(atlas_eci, overwrite = TRUE, compress = "xz")


atlas_economic_complexity <- country_hsproduct4digit_year |>
  inner_join(atlas_product_classification) |>
  rename(hs_name_short_en = name_short_en) |>
  inner_join(atlas_country_classification) |>
  select(year, export_value, location_code = iso3_code, location_name = name_short_en, hs_name_short_en, hs_product_code = code)

usethis::use_data(atlas_economic_complexity, compress = "xz", overwrite = TRUE)

country_sitcproduct4digit_year <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/country_sitcproduct4digit_year.dta")

atlas_eci_sitc <- country_sitcproduct4digit_year |>
  distinct(year, location_code, sitc_eci)

usethis::use_data(atlas_eci_sitc, overwrite = TRUE, compress = "xz")

