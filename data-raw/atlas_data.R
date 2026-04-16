## code to prepare datasets using atlas of economic complexity data
library(readr)
library(dplyr)
library(arrow)
library(purrr)
library(stringr)
library(ecomplexity)
atlas_trade_data <- function(data, classification) {

  classification <- str_split_1(classification, "_")
  trade_codec <- classification[1]
  digits <- classification[2]

  data |>
    select(contains("code"),
           year,
           export_value,
           export_rca,
           import_value,
           global_market_share,
           distance,
           cog,
           pci) |>
    rename_with(\(x) str_remove(x, "hs[0-9]+_|sitc_"),
                .cols = starts_with("product")) |>
    mutate(classification = trade_codec,
           digits = digits)


}

proximity <- function(data, classification) {

  classification <- str_split_1(classification, "_")
  trade_codec <- classification[1]
  digits <- classification[2]
  year <- classification[3]

  data |>
    pivot_longer(cols = -rowname) |>
    mutate(classification = trade_codec,
           digits = digits,
           year = year)
}

country_product <- list(
  hs92_4 = read_csv("data-raw/atlas_export_data/hs92/hs92_country_product_year_4.csv"),
  hs12_4 = read_csv("data-raw/atlas_export_data/hs12/hs12_country_product_year_4.csv"),
  hs22_4 = read_csv("data-raw/atlas_export_data/hs22/hs22_country_product_year_4.csv")
)

country_product_4 <- imap(.x = country_product,
                          .f = \(x, y) atlas_trade_data(x, classification = y))  |>
  list_rbind()

atlas_raw_6 <- read_csv("data-raw/atlas_export_data/hs22/hs22_country_product_year_6.csv")

country_product_6 <- calculate_complexity_time_series(atlas_raw_6,
                                                      years = unique(atlas_raw_6$year),
                                                      region = "country_iso3_code",
                                                      product = "product_hs22_code",
                                                      value = "export_value") |>
  mutate(classification = "hs22",
         digits = "6",
         distance = 1 - density) |>
  select(country_iso3_code,
         product_code = product_hs22_code,
         year,
         export_value,
         export_rca = rca,
         import_value,
         global_market_share,
         distance,
         cog,
         pci = product_complexity_index,
         classification,
         digits)

bind_rows(country_product_4, country_product_6) |>
  group_by(classification, digits) |>
  write_dataset(path = "data",
                format = "parquet")

