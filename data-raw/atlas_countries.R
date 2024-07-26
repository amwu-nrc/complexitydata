## code to prepare `atlas_countries` dataset goes here
library(readr)
library(dplyr)

atlas_included <- read_tsv("data-raw/misc/rankings.tab") |>
  distinct(location_code = code) |>
  pull()

atlas_countries <- read_tsv("data-raw/misc/location.tab") |>
  filter(location_code %in% atlas_included) |>
  distinct(location_code, location_name_short_en)


usethis::use_data(atlas_countries, overwrite = TRUE)
