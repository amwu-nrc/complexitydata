# Create Australia only atlas of economic complexity 6 digit data (HS92 and HS12)

library(dplyr)
library(readr)
devtools::load_all()

rankings <- read_csv(
  "data-raw/atlas_export_data/growth_proj_eci_rankings.csv"
) |>
  filter(year == 2024)


atlas_raw_6 <- read_csv("data-raw/atlas_export_data/hs92_country_product_year_6.csv") |>
  filter(country_iso3_code %in% rankings$country_iso3_code,
         year >= 2004) |>
  select(year, country_iso3_code, product_hs92_code, export_value) |>
  complete(product_hs92_code, nesting(country_iso3_code, year),
           fill = list(export_value = 0))

zero_export_products <- atlas_raw_6 |>
  summarise(export_value = sum(export_value), .by = c(year, product_hs92_code)) |>
  filter(export_value == 0) |>
  mutate(zep = paste(year, product_hs92_code, sep = "-")) |>
  pull(zep)



zero_export_countries <- atlas_raw_6 |>
  summarise(export_value = sum(export_value), .by = c(year, country_iso3_code)) |>
  filter(export_value == 0) |>
  mutate(zec = paste(year, country_iso3_code, sep = "-")) |>
  pull(zec)

atlas_clean_6 <- atlas_raw_6 |>
  mutate(zep = paste(year, product_hs92_code, sep = "-"),
         zec = paste(year, country_iso3_code, sep = "-")) |>
  filter(!zep %in% zero_export_products,
         !zec %in% zero_export_countries)

atlas_economic_complexity92_6 <- calculate_complexity_time_series(atlas_clean_6, years = unique(atlas_clean_6$year), region = "country_iso3_code", product = "product_hs92_code", value = "export_value")

# For Goran

atlas_economic_complexity92_6 |>
  select(-zep, -zec) |>
  group_by(year) |>
  group_walk(.f = ~write_csv(.x, glue::glue("data/atlas_economic_complexity_92_6_{.y}.csv")))

bi <- purrr::map(.x = unique(atlas_clean_6$year),
                 .f = ~economiccomplexity::balassa_index(atlas_clean_6 |> filter(year == .x), country = "country_iso3_code", product = "product_hs92_code", value = "export_value"),
                 .progress = TRUE)

prox <- purrr::map(.x = bi,
                   .f = ~economiccomplexity::proximity(.x, compute = "product"),
                   .progress = TRUE)

purrr::walk2(.x = prox,
             .y = unique(atlas_economic_complexity92_6$year),
             .f = ~write_csv(.x |>  purrr::pluck("proximity_product") |> as.data.frame(row.names = rownames(.x)) |> tibble::rownames_to_column(),  glue::glue("data/proximity_92_6_{.y}.csv")),
             .progress = TRUE)

atlas_economic_complexity92_6_aus <- atlas_economic_complexity92_6 |>
  filter(country_iso3_code == "AUS")

usethis::use_data(atlas_economic_complexity92_6, compress = "xz", overwrite = T)
usethis::use_data(atlas_economic_complexity92_6_aus, compress = "xz", overwrite = T)
