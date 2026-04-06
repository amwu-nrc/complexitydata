# Create Australia only atlas of economic complexity 6 digit data (HS92 and HS12)

library(dplyr)
library(readr)
devtools::load_all()

rankings <- read_csv("data-raw/atlas_export_data/growth_proj_eci_rankings.csv")

atlas_raw_6 <- read_csv("data-raw/atlas_export_data/hs92_country_product_year_6.csv") |>
  filter(country_id %in% rankings$country_id)



atlas_economic_complexity92_6 <- calculate_complexity_time_series(atlas_raw_6, years = unique(atlas_raw_6$year), region = "country_iso3_code", product = "product_hs92_code", value = "export_value")

usethis::use_data(atlas_economic_complexity92_6, compress = "xz")
