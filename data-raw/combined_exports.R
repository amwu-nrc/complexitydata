## code to prepare `combined_exports` dataset goes here
library(readxl)
library(readr)
library(stringr)
library(strayr)
library(dplyr)
library(tidyr)
library(cli)
library(purrr)
library(lubridate)

hs_92_92 <- read_csv("data-raw/concordance/hs92_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))

hs_96_92 <- read_csv("data-raw/concordance/hs96_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))

hs_02_92 <- read_csv("data-raw/concordance/hs02_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))

hs_07_92 <- read_csv("data-raw/concordance/hs07_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))

hs_12_92 <- read_csv("data-raw/concordance/hs12_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))

hs_17_92 <- read_csv("data-raw/concordance/hs17_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))

hs_22_92 <- read_csv("data-raw/concordance/hs22_to_hs92.csv",
                     col_types = list(h3 = "c", h0 = "c")) |>
  mutate(across(everything(), \(x) ifelse(str_length(x) == 5, str_pad(x, 6, "left", "0"), x)))



df_states <- tibble(
  "year" = integer(),
  "hs_product_code" = character(),
  "ACT" = numeric(),
  "NSW" = numeric(),
  "NT" = numeric(),
  "QLD" = numeric(),
  "SA" = numeric(),
  "TAS" = numeric(),
  "VIC" = numeric(),
  "WA" = numeric()
)

df <- read_excel("data-raw/state_export_data/abs_calendar_year_request.xlsx",
                 sheet = "Table 1",
                 skip = 7,
                 n_max = 802034,
                 col_names = c("year", "ahecc_8", "ahecc_description", "state", "fob_aud")) |>
  mutate(year = as.integer(str_extract(year, "[0-9]*")),
         state = case_when(
           state == "Re-exports" ~ "RX",
           state == "No state details" ~ "CND",
           TRUE ~ clean_state(state)
           ),
         ahecc_8 = str_pad(ahecc_8, width = 8, side = "left", pad = "0"),
         ahecc_6 = str_sub(ahecc_8, 0L, 6L)) |>
  filter(ahecc_8 != "98888888") |>  #Can't find any information about this code.
  pivot_wider(names_from = state, values_from = fob_aud, values_fill = 0)

ahecc_to_hs <- function(data, year) {
  #Read the state data for a year

  cli_alert("Converting data for {year}")

  df <- data |>
    filter(year == {{year}})

  # #Merge with the concordance, group by hs, summarise
  df_hs <- left_join(df, hs_92_92, by = c("ahecc_6" = "h3"))

  err <- sum(is.na(df_hs$h0))

  while (err > 0) {


    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(ahecc_6)

    new_concordance <- bind_rows(
      hs_92_92,
      hs_96_92[hs_96_92$h3 %in% missing, ])

    df_hs <- left_join(df, new_concordance, by = c("ahecc_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(ahecc_6)

    err <- length(missing) #Check if the addition of 96-92 codes solved the problem. If err == 0 the loop ends

    #96-92 not enough, so add in the 02-92
    new_concordance <- bind_rows(
      new_concordance,
      hs_02_92[hs_02_92$h3 %in% missing, ]) |>
      distinct()

    df_hs <- left_join(df, new_concordance, by = c("ahecc_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(ahecc_6)

    err <- length(missing) #Check if the addition of 02-92 solved the problem. If err == 0, the loop ends

    #02-92 and 96-92 not enough! so add in the 07-92
    new_concordance <- bind_rows(
      new_concordance,
      hs_07_92[hs_07_92$h3 %in% missing, ])  |>
      distinct()

    df_hs <- left_join(df, new_concordance, by = c("ahecc_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(ahecc_6)

    err <- length(missing)


    new_concordance <- bind_rows(
      new_concordance,
      hs_12_92[hs_12_92$h3 %in% missing, ]) |>
      distinct()

    df_hs <- left_join(df, new_concordance, by = c("ahecc_6" = "h3"))

    missing <- df_hs  |>
      filter(is.na(h0))  |>
      pull(ahecc_6)

    err <- length(missing)


    #if this doesnt work, will need a newer concordance
    new_concordance <- bind_rows(
      new_concordance,
      hs_17_92[hs_17_92$h3 %in% missing, ])  |> distinct()

    df_hs <- left_join(df, new_concordance, by = c("ahecc_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(ahecc_6)

    err <- length(missing)


    #Add 2022 to 1992 concordance
    new_concordance <- bind_rows(
      new_concordance,
      hs_22_92[hs_22_92$h3 %in% missing, ]) |> distinct()

    df_hs <- left_join(df, new_concordance, by = c("ahecc_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0)) |>
      pull(ahecc_6)

    err <- length(missing)


  }

  df_hs <- df_hs |>
    group_by(year, hs_product_code = h0) |>
    summarise(across(c(ACT, NSW, NT, Qld, SA, Tas, Vic, WA), \(x) sum(x, na.rm = TRUE)),
              .groups = "drop")


  df_states <- bind_rows(list(df_states, df_hs))


}

df_states <- map(1994:2023, ~ahecc_to_hs(df, .x)) |>
  list_rbind()

# df_states_check <- df_states |>
#   pivot_longer(cols = -c(year, hs_product_code),
#                names_to = 'state',
#                values_to = 'fob_aud') |>
#   group_by(year, state) |>
#   summarise(value_hs = sum(fob_aud, na.rm = T), .groups = 'drop')
# df_check <- df |>
#   select(-ahecc_description, -ahecc_6) |>
#   pivot_longer(cols = -c(year, ahecc_8),
#                names_to = 'state',
#                values_to = 'fob_aud') |>
#   group_by(year, state) |>
#   summarise(value_ahecc = sum(fob_aud, na.rm = T), .groups = 'drop')

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

exchr <- read_csv("data-raw/misc/historical_exchange_rate_rba.csv", show_col_types = FALSE) |>
  mutate(date = dmy(date),
         year = year(date)) |>
  summarise(aud_to_usd = mean(aud_to_usd), .by = year)


clean_states <- df_states |>
  pivot_longer(cols = -c(year, hs_product_code), names_to = 'location_code', values_to = 'export_value') |>
  group_by(year, location_code, hs_product_code = str_sub(hs_product_code, 0L, 4L)) |>
  summarise(export_value = sum(export_value),
            .groups = "drop") |>
  bind_rows(state_service_data) |>
  left_join(exchr, by = "year") |>
  mutate(export_value = export_value * aud_to_usd) |>
  select(-aud_to_usd)

atlas_rankings <- read_tsv("data-raw/misc/rankings.tab",
                           show_col_types = FALSE) |>
  mutate(year_location_code = paste0(year, code))

product_rankings <- readxl::read_excel("data-raw/misc/classifications.xlsx",
                                       sheet = "hs_product_id")



atlas <- get(load("data-raw/atlas_export_data/country_hsproduct4digit_year.rda")) |>
  select(year, export_value, location_code, hs_product_code) |>
  mutate(year_location_code = paste0(year, location_code)) |>
  filter(location_code != "AUS",
         !is.na(export_value),
         year_location_code %in% atlas_rankings$year_location_code,
         hs_product_code %in% product_rankings$hs_product_code) |>
  select(-year_location_code)



complexity_input_data <- bind_rows(atlas, clean_states) |>
  complete(year, location_code, hs_product_code) |>
  replace_na(list(export_value = 0)) |>
  arrange(year, hs_product_code, location_code)

#Identify year-country pairs with 0 exports
country_filter <- complexity_input_data |>
  group_by(year, location_code) |>
  summarise(country_test = sum(export_value, na.rm = T), .groups = "drop")  |>
  filter(country_test == 0) |>
  mutate(country_test = str_c(year, location_code, sep = "-")) |>
  pull(country_test)

#Identify year-product pairs with 0 exports
product_filter <- complexity_input_data |>
  group_by(year, hs_product_code) |>
  summarise(product_test = sum(export_value, na.rm = T), .groups = "drop") |>
  filter(product_test == 0) |>
  mutate(product_test = str_c(year, hs_product_code, sep = "-")) |>
  pull(product_test)

complexity_input_data <- complexity_input_data |>
  mutate(country_test = str_c(year, location_code, sep = "-"),
         product_test = str_c(year, hs_product_code, sep = "-"))  |>
  filter(!country_test %in% country_filter,
         !product_test %in% product_filter) |>
  select(-country_test, -product_test)


combined_exports <- complexity_input_data

usethis::use_data(combined_exports, compress = "xz", overwrite = TRUE)
usethis::use_data(state_service_data, compress = "xz", overwrite = TRUE)

