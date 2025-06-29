## code to prepare `state_economic_complexity` dataset goes here
library(stringr)
library(dplyr)
library(strayr)
library(devtools)
library(ecomplexity)

load_all()

#ACT is removed due to insufficient export value
data("combined_exports")

state_data <- combined_exports |>
  filter(!location_code %in% c("ACT"))

economic_complexity <- calculate_complexity_time_series(data = state_data,
                                                              region = "location_code",
                                                              product = "hs_product_code",
                                                              value = "export_value",
                                                              years = unique(state_data$year))

complexity_rank <- economic_complexity |>
  distinct(year, location_code, country_complexity_index) |>
  mutate(eci_rank = order(order(country_complexity_index, decreasing = TRUE)), .by = year)

state_economic_complexity <- economic_complexity |>
  left_join(complexity_rank , by = join_by(year, location_code, country_complexity_index)) |>
  filter(location_code %in% clean_state(1:8))


usethis::use_data(state_economic_complexity, compress = "xz", overwrite = TRUE)
