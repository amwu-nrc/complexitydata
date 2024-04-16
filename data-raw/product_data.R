## code to prepare `product_data` dataset goes here
library(haven)
library(dplyr)
library(readr)

atlas_product_complexity <- read_dta("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/country_hsproduct4digit_year.dta") |>
  distinct(year, hs_product_code, pci)

product_data <- read_tsv("S:/CBGL-AITI/~General/~Data/Economic complexity/Atlas Data (2021)/hs_product.tab",
                         show_col_types = FALSE)

product_data_section <- product_data |>
  filter(level == "section") |>
  select(product_id, section_name = hs_product_name_short_en)

product_data_two <- product_data |>
  filter(level == '2digit') |>
  select(product_id, parent_id, group_name = hs_product_name_short_en) |>
  left_join(product_data_section, by = c("parent_id" = "product_id")) |>
  select(-parent_id)

product_data_four <- product_data |>
  filter(level == "4digit") |>
  select(product_id, parent_id, hs_product_name_short_en) |>
  left_join(product_data_two, by = c("parent_id" = "product_id"))

product_data_six <- product_data |>
  filter(level == "6digit") |>
  select(product_id, parent_id, six_name = hs_product_name_short_en)


usethis::use_data(product_data, overwrite = TRUE)
