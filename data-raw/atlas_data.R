## code to prepare datasets using atlas of economic complexity data
library(readr)
library(dplyr)
library(purrr)
library(zoo)

country_details <- read_csv("data-raw/atlas_export_data/location_country.csv")

product_details <- list(hs92 = read_csv("data-raw/atlas_export_data/product_hs92.csv"),
                        hs12 = read_csv("data-raw/atlas_export_data/product_hs12.csv"))
country_product <- list(hs92 = read_csv("data-raw/atlas_export_data/hs92_country_product_year_4.csv"),
                        hs12 = read_csv("data-raw/atlas_export_data/hs12_country_product_year_4.csv"))

country_year <- list(hs92 = read_csv("data-raw/atlas_export_data/hs92_country_year.csv"),
                     hs12 = read_csv("data-raw/atlas_export_data/hs12_country_year.csv"))

rankings <- read_csv("data-raw/atlas_export_data/growth_proj_eci_rankings.csv")

atlas_economic_complexity92 <-  country_product$hs92 |>
  inner_join(country_details) |>
  inner_join(product_details$hs92) |>
  filter(in_rankings) |>
  select(year,
         export_value,
         export_rca,
         location_code = country_iso3_code,
         location_name = country_name_short,
         hs_product_code = product_hs92_code,
         hs_name_short_en = product_name_short)

smooth_economic_complexity92 <- atlas_economic_complexity92 |>
  arrange(year) |>
  group_by(location_name, location_code, hs_name_short_en, hs_product_code) |>
  mutate(export_value = rollmeanr(export_value, k = 3, fill = NA)) |>
  ungroup() |>
  mutate(export_value_p = sum(export_value), .by = c(hs_product_code, hs_name_short_en)) |>
  mutate(export_value_c = sum(export_value), .by = c(location_code, location_name)) |>
  mutate(export_value_cp = sum(export_value), .by = c(location_code, hs_product_code, location_name, hs_name_short_en)) |>
  mutate(export_rca = (export_value_p/export_value)/(export_value_c/export_value_cp)) |>
  select(year, export_value, export_rca, location_code, location_name, hs_product_code, hs_name_short_en) |>
  filter(!is.na(export_value))


atlas_economic_complexity12 <-  country_product$hs12 |>
  inner_join(country_details) |>
  inner_join(product_details$hs12) |>
  filter(in_rankings) |>
  select(year,
         export_value,
         export_rca,
         location_code = country_iso3_code,
         location_name = country_name_short,
         hs_product_code = product_hs12_code,
         hs_name_short_en = product_name_short)

smooth_economic_complexity12 <- atlas_economic_complexity12 |>
  arrange(year) |>
  group_by(location_name, location_code, hs_name_short_en, hs_product_code) |>
  mutate(export_value = rollmeanr(export_value, k = 3, fill = NA)) |>
  ungroup() |>
  mutate(export_value_p = sum(export_value), .by = c(hs_product_code, hs_name_short_en)) |>
  mutate(export_value_c = sum(export_value), .by = c(location_code, location_name)) |>
  mutate(export_value_cp = sum(export_value), .by = c(location_code, hs_product_code, location_name, hs_name_short_en)) |>
  mutate(export_rca = (export_value_p/export_value)/(export_value_c/export_value_cp)) |>
  select(year, export_value, export_rca, location_code, location_name, hs_product_code, hs_name_short_en) |>
  filter(!is.na(export_value))

usethis::use_data(atlas_economic_complexity92, compress = "xz", overwrite = TRUE)
usethis::use_data(smooth_economic_complexity92, compress = "xz", overwrite = TRUE)

usethis::use_data(atlas_economic_complexity12, compress = "xz", overwrite = TRUE)
usethis::use_data(smooth_economic_complexity12, compress = "xz", overwrite = TRUE)



# Use hs92/sitc/hs12 rankings as given by the atlas data. Also calculate them using the smooth data.

eci_ranking_smooth92 <- smooth_economic_complexity92 |>
  calculate_complexity_time_series(years = unique(smooth_economic_complexity92$year), region = "location_code", product = "hs_product_code", value = "export_value") |>
  distinct(year, location_code, location_name, country_complexity_index) |>
  mutate(eci_rank_hs92_smooth = rank(-country_complexity_index), .by = year) |>
  select(year, location_code, location_name, eci_hs92_smooth = country_complexity_index, eci_rank_hs92_smooth)

eci_ranking_smooth12 <- smooth_economic_complexity12 |>
  calculate_complexity_time_series(years = unique(smooth_economic_complexity12$year), region = "location_code", product = "hs_product_code", value = "export_value") |>
  distinct(year, location_code, location_name, country_complexity_index) |>
  mutate(eci_rank_hs12_smooth = rank(-country_complexity_index), .by = year) |>
  select(year, location_code, location_name, eci_hs12_smooth = country_complexity_index,  eci_rank_hs12_smooth)

eci_rankings <- rankings |>
  distinct(year, location_code = country_iso3_code, eci_sitc, eci_rank_sitc, eci_hs92, eci_rank_hs92, eci_hs12, eci_rank_hs12) |>
  inner_join(eci_ranking_smooth92) |>
  inner_join(eci_ranking_smooth12)

usethis::use_data(eci_rankings, overwrite = TRUE, compress = "xz")

# Product Level Complexity Data

atlas_complexity_product92 <- country_product$hs92 |>
  distinct(year,
           hs_product_code = product_hs92_code,
           product_complexity_index = pci,
           cog,
           distance)


atlas_complexity_product12 <- country_product$hs12 |>
  distinct(year,
           hs_product_code = product_hs12_code,
           product_complexity_index = pci)

usethis::use_data(atlas_complexity_product92, overwrite = TRUE, compress = "xz")
usethis::use_data(atlas_complexity_product12, overwrite = TRUE, compress = "xz")

atlas_complexity_country92 <- rankings |>
  inner_join(country_year$hs92) |>
  distinct(year, location_code = country_iso3_code, eci, export_value, eci_rank_hs92, growth_proj, coi, diversity)

atlas_complexity_country12 <- rankings |>
  inner_join(country_year$hs12) |>
  distinct(year, location_code = country_iso3_code, eci, export_value, eci_rank_hs12, growth_proj, coi, diversity)

usethis::use_data(atlas_complexity_country92, overwrite = TRUE, compress = "xz")
usethis::use_data(atlas_complexity_country12, overwrite = TRUE, compress = "xz")


