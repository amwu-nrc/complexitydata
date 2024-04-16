## code to prepare `state_global_export_data` dataset goes here
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(stringr)
library(purrr)



years <- list.files("data-raw/state_export_data")
years <- years[str_detect(years, ".csv")]

#Not interested in 2021-22 data yet
years <- years[years != "2021-22.csv"]

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

ahecc_to_hs <- function(year) {
  #Read the state data for a year
  df <- read_csv(paste0("data-raw/state_export_data/", year),
                 show_col_types = FALSE) |>
    rename(AHECC_8 = 1,
           CND = 3,
           FRX = 4,
           QLD = 7,
           TAS = 9,
           VIC = 10,
           TOT = 12) |>
    separate(AHECC_8, into = c("AHECC", "AHECC_DESC"), sep = 8) |>
    mutate(AHECC_DESC = trimws(AHECC_DESC),
           AHECC_6 = str_sub(AHECC, 0L, 6L))

  # #Merge with the concordance, group by hs, summarise
  df_hs <- left_join(df, hs_92_92, by = c("AHECC_6" = "h3"))

  err <- sum(is.na(df_hs$h0))

  while (err > 0) {

    print(year)

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(AHECC_6)

    new_concordance <- bind_rows(
      hs_92_92,
      hs_96_92[hs_96_92$h3 %in% missing, ])

    df_hs <- left_join(df, new_concordance, by = c("AHECC_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(AHECC_6)

    err <- length(missing) #Check if the addition of 96-92 codes solved the problem. If err == 0 the loop ends
    print(err)

    #96-92 not enough, so add in the 02-92
    new_concordance <- bind_rows(
      new_concordance,
      hs_02_92[hs_02_92$h3 %in% missing, ]) |>
      distinct()

    df_hs <- left_join(df, new_concordance, by = c("AHECC_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(AHECC_6)

    err <- length(missing) #Check if the addition of 02-92 solved the problem. If err == 0, the loop ends
    print(err)

    #02-92 and 96-92 not enough! so add in the 07-92
    new_concordance <- bind_rows(
      new_concordance,
      hs_07_92[hs_07_92$h3 %in% missing, ])  |>
      distinct()

    df_hs <- left_join(df, new_concordance, by = c("AHECC_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(AHECC_6)

    err <- length(missing)
    print(err)


    new_concordance <- bind_rows(
      new_concordance,
      hs_12_92[hs_12_92$h3 %in% missing, ]) |>
      distinct()

    df_hs <- left_join(df, new_concordance, by = c("AHECC_6" = "h3"))

    missing <- df_hs  |>
      filter(is.na(h0))  |>
      pull(AHECC_6)

    err <- length(missing)
    print(err)


    #if this doesnt work, will need a newer concordance
    new_concordance <- bind_rows(
      new_concordance,
      hs_17_92[hs_17_92$h3 %in% missing, ])  |> distinct()

    df_hs <- left_join(df, new_concordance, by = c("AHECC_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0))  |>
      pull(AHECC_6)

    err <- length(missing)
    print(err)


    #Add 2022 to 1992 concordance
    new_concordance <- bind_rows(
      new_concordance,
      hs_22_92[hs_22_92$h3 %in% missing, ]) |> distinct()

    df_hs <- left_join(df, new_concordance, by = c("AHECC_6" = "h3"))

    missing <- df_hs |>
      filter(is.na(h0)) |>
      pull(AHECC_6)

    err <- length(missing)
    print(err)


  }

  df_hs <- df_hs |>
    group_by(hs_product_code = h0) |>
    summarise(across(c(ACT, NSW, NT, QLD, SA, TAS, VIC, WA), \(x) sum(x, na.rm = TRUE))) |>
    ungroup()|>
    mutate(year = as.integer(str_sub(year,0,4)) + 1)


  df_states <- bind_rows(list(df_states, df_hs))

}

df_states <- map(years, ~ahecc_to_hs(.x)) |>
  list_rbind()

exchr <- read_csv("data-raw/misc/historical_exchange_rate_rba.csv", show_col_types = FALSE) |>
  mutate(date = dmy(date),
         year = as.integer(str_sub(quarter(date, fiscal_start = 7, type = "year.quarter"), 0, 4))) |>
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
