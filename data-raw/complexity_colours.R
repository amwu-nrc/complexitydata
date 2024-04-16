## code to prepare `complexity_colours` dataset goes here
library(stringr)
library(tibble)
library(readr)
library(dplyr)

complexity_colours <- tribble(
  ~sector,  ~colour,
  "Agriculture", "f5cf23",
  "Minerals", "bb968a",
  "Chemicals", "c57bd9",
  "Textiles", "7ddaa1",
  "Stone", "dab47d",
  "Metals", "d97b7b",
  "Machinery", "7ba2d9",
  "Electronics", "7ddada",
  "Vehicles", "8d7bd8",
  "Other", "2a607c",
  "Services", "b23d6d"
) |>
  mutate(colour = paste0("#", colour))

complexity_classification <- read_tsv("data-raw/misc/complexity_classification.txt",
                                      show_col_types = FALSE) |>
  mutate(code = str_pad(Code, "left", pad = "0", width = 4)) |>
  select(code, sector = Sector) |>
  left_join(complexity_colours)



usethis::use_data(complexity_classification, overwrite = TRUE)
