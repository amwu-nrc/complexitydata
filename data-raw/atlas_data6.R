# Create Australia only atlas of economic complexity 6 digit data (HS92 and HS12)

library(dplyr)
library(readr)
devtools::load_all()

rankings <- read_csv(
  "data-raw/atlas_export_data/growth_proj_eci_rankings.csv"
) |>
  filter(year == 2024)

atlas_raw_6 <- read_csv(
  "data-raw/atlas_export_data/hs12_country_product_year_6.csv"
) |>
  filter(country_id %in% rankings$country_id, year == 2024)


atlas_economic_complexity12_6 <- calculate_complexity(
  atlas_raw_6,
  region = "country_iso3_code",
  product = "product_hs12_code",
  value = "export_value",
  year = 2024
)

atlas_economic_complexity12_6 <- atlas_economic_complexity12_6 |>
  rename(location_code = country_iso3_code)
usethis::use_data(atlas_economic_complexity12_6, overwrite = T, compress = "xz")
