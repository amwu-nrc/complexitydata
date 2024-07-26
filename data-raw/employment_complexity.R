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
         sa2 != "Total")


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
         sa3 != "Total")

sa3_occp4 <- employment_complexity("data-raw/abs/sa3-pow-occp-4-digit.csv", region = "SA3", activity = "occp", digits = 4)
sa3_indp4 <- employment_complexity("data-raw/abs/sa3-pow-indp-4-digit-codes.csv", region = "SA3", activity = "indp", digits = 4)


usethis::use_data(sa2_indp1_occp1, sa3_indp1_occp1, sa3_indp4, sa3_occp4, overwrite = TRUE, compress = "xz")
