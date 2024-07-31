## code to prepare `employment-complexity` dataset goes here
library(rlang)
library(tidyverse)



employment_complexity <- function(data, region, activity, digits, remove_totals = TRUE) {


  region_name <- paste({{region}}, "(POW)")

  activity_name <- switch(activity,
                          "indp" = "INDP Industry of Employment",
                          "occp" = "OCCP Occupation")
  activity_name <- paste0(digits, "-digit level ", activity_name)

  nmax <- suppressWarnings(min(which(is.na(readr::read_csv(name_repair = 'unique_quiet',data, show_col_types = F,skip = 9)$Count)))-1)

  region <- tolower(region)

  df <- readr::read_csv(data,
                        skip = 9,
                        n_max = nmax,
                        show_col_types = FALSE,
                        name_repair = 'unique_quiet') |>
    dplyr::select({{region}} := region_name,
                  {{activity}} := activity_name,
                  count = Count)  |>
    dplyr::filter(.data[[region]] != "Total",
                  !str_detect(.data[[region]], "POW|Migratory"),
                  !.data[[activity]] %in% c("Inadequately described", "Not stated", "Not applicable", "Total"))

  return(df)
}


# sa2 ---------------------------------------------------------------------

sa2_indp1_occp1 <- read_csv("data-raw/abs/sa2-pow-occp-indp-1-digit.csv.csv",
                            skip = 9,
                            n_max = 625922,
                            col_select = c(sa2 = "SA2 (POW)",
                                           anzsic_division = "1-digit level INDP Industry of Employment",
                                           anzsco_major = "1-digit level OCCP Occupation",
                                           count = Count)) |>
  filter(!anzsic_division %in% c("Inadequately described", "Not stated",
                                 "Not applicable", "Total"),
         !anzsco_major %in% c("Inadequately described", "Not stated",
                              "Not applicable", "Total"),
         !str_detect(sa2, "Total|POW|Migratory")) |>
  mutate(anzsic_division = fct_inorder(anzsic_division),
         anzsco_major = fct_inorder(anzsco_major),
         industry_occupation = paste0(anzsic_division, " (", anzsco_major,")"),
         industry_occupation = fct_inorder(industry_occupation)) |>
  group_by(sa2, industry_occupation) |>
  summarise(count = sum(count), .groups = "drop")


# sa3 ---------------------------------------------------------------------
sa3_indp1_occp1 <- read_csv("data-raw/abs/sa3-pow-occp-indp-1-digit.csv",
                            skip = 9,
                            n_max = 99360,
                            col_select = c(sa3 = "SA3 (POW)",
                                           anzsic_division = "1-digit level INDP Industry of Employment",
                                           anzsco_major = "1-digit level OCCP Occupation",
                                           count = Count)) |>
  filter(!anzsic_division %in% c("Inadequately described", "Not stated",
                                 "Not applicable", "Total"),
         !anzsco_major %in% c("Inadequately described", "Not stated",
                              "Not applicable", "Total"),
         !str_detect(sa3, "Total|POW|Migratory")) |>
  mutate(anzsic_division = fct_inorder(anzsic_division),
         anzsco_major = fct_inorder(anzsco_major),
         industry_occupation = paste0(anzsic_division, " (", anzsco_major,")"),
         industry_occupation = fct_inorder(industry_occupation)) |>
  group_by(sa3, industry_occupation) |>
  summarise(count = sum(count), .groups = "drop")

sa3_indp2_occp1 <- read_csv("data-raw/abs/sa3-pow-indp-2-occp-1-digit.csv",
                            skip = 9,
                            n_max = 431640,
                            col_select = c(sa3 = "SA3 (POW)",
                                           anzsic_subdivision = "2-digit level INDP Industry of Employment",
                                           anzsco_major = "1-digit level OCCP Occupation",
                                           count = Count)) |>
  filter(!anzsic_subdivision %in% c("Inadequately described", "Not stated", "Not applicable", "Total"),
         !anzsco_major %in% c("Inadequately described", "Not stated", "Not applicable", "Total"),
         !str_detect(sa3, "Total|POW|Migratory")) |>
  mutate(anzsic_subdivision = fct_inorder(anzsic_subdivision),
         anzsco_major = fct_inorder(anzsco_major),
         industry_occupation = paste0(anzsic_subdivision, " (", anzsco_major,")"),
         industry_occupation = fct_inorder(industry_occupation)) |>
  group_by(sa3, industry_occupation) |>
  summarise(count = sum(count), .groups = "drop")

sa3_occp4 <- employment_complexity("data-raw/abs/sa3-pow-occp-4-digit.csv", region = "SA3", activity = "occp", digits = 4)
sa3_indp4 <- employment_complexity("data-raw/abs/sa3-pow-indp-4-digit-codes.csv", region = "SA3", activity = "indp", digits = 4)


usethis::use_data(sa2_indp1_occp1,
                  sa3_indp1_occp1,
                  sa3_indp2_occp1,
                  sa3_indp4,
                  sa3_occp4,
                  overwrite = TRUE, compress = "xz")
devtools::document()
