## code to prepare datasets using atlas of economic complexity data
library(readr)
library(dplyr)


country_details <- read_csv("data-raw/atlas_export_data/location_country.csv")
product_details <- read_csv("data-raw/atlas_export_data/product_hs92.csv")
country_product <- read_csv("data-raw/atlas_export_data/hs92_country_product_year_4.csv")
country_year <- read_csv("data-raw/atlas_export_data/hs92_country_year.csv")
rankings <- read_csv("data-raw/atlas_export_data/growth_proj_eci_rankings.csv")

atlas_economic_complexity <- country_product|>
  inner_join(country_details) |>
  inner_join(product_details) |>
  filter(in_rankings) |>
  select(year,
         export_value,
         location_code = country_iso3_code,
         location_name = country_name_short,
         hs_product_code = product_hs92_code,
         hs_name_short_en = product_name_short)

usethis::use_data(atlas_economic_complexity, compress = "xz", overwrite = TRUE)


atlas_eci_sitc <- rankings |>
  distinct(year, location_code = country_iso3_code, eci_sitc, eci_rank_sitc)

usethis::use_data(atlas_eci_sitc, overwrite = TRUE, compress = "xz")

# Product Level Complexity Data

atlas_complexity_product <- country_product |>
  distinct(year,
           hs_product_code = product_hs92_code,
           product_complexity_index = pci)

usethis::use_data(atlas_complexity_product, overwrite = TRUE, compress = "xz")

atlas_complexity_country <- rankings |>
  inner_join(country_year) |>
  distinct(year, location_code = country_iso3_code, eci, export_value, eci_rank_hs92, growth_proj, coi, diversity)

usethis::use_data(atlas_complexity_country, overwrite = TRUE, compress = "xz")


