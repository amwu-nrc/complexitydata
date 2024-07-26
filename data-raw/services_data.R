library(readabs)
library(strayr)
library(tidyverse)
library(readxl)

download_abs_data_cube("international-trade-supplementary-information-financial-year",
                       path = "data-raw/state_export_data",
                       cube = "536805500303.xlsx")

fys <- as.numeric(str_sub(colnames(read_excel("data-raw/state_export_data/536805500303.xlsx", sheet = 2, skip = 5, n_max = 0)), 1L, 4L)) + 1
fys <- fys[!is.na(fys)]

service_cats <- tribble(
  ~"ABS_cat", ~"hs_product_code",
  "Manufacturing services on physical inputs owned by others", "other",
  "Maintenance and repair services n.i.e", "other",
  "Transport",  "transport",
  "Travel",  "travel",
  "Construction", "other",
  "Insurance and Pension services", "financial",
  "Financial Services", "financial",
  "Charges for the use of intellectual property n.i.e", "other",
  "Telecommunications, computer and information services", "ict",
  "Other business services", "other",
  "Personal, cultural, and recreational services", "other",
  "Government goods and services n.i.e", "other")

sheets <- paste0("Table 3.", 1:8)
states <- str_to_upper(clean_state(x = 1:8, to = "state_abbr"))


read_services_data <- function(sheet, state) {

  read_excel("data-raw/state_export_data/536805500303.xlsx",
             sheet = {{sheet}},
             skip = 5,
             n_max = 50,
             col_names = c("ABS_cat", fys)) |>
    pivot_longer(cols = -ABS_cat,
                 names_to = "year",
                 values_to = "export_value") |>
    mutate(location_code = {{state}},
           export_value = case_when(export_value == "-" ~ "0",
                                    export_value == "np" ~ NA_character_,
                                    TRUE ~ export_value),
           export_value = 1e6*as.numeric(export_value),
           year = as.integer(year)) |>
    filter(ABS_cat %in% service_cats$ABS_cat,
           year <= 2021) |>
    left_join(service_cats, by = join_by(ABS_cat)) |>
    group_by(location_code, year, hs_product_code) |>
    summarise(export_value = sum(export_value, na.rm = TRUE),
              .groups = "drop")

}

state_service_data <- map2(.x = sheets, .y = states, .f = ~read_services_data(.x, .y)) |>
  list_rbind()

usethis::use_data(state_service_data, compress = "xz", overwrite = TRUE)


