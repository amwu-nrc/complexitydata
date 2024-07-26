#' Atlas of Economic Complexity and Australian State export data
#'
#' Atlas of Economic complexity data with Australia removed and replaced by
#' Australian State export data. State export data has been converted from the AHECC
#' system to the Harmonised System (1992 version)
#'
#' @format Tibble with columns:
#' \describe{
#'  \item{year}{Year that product was exported.}
#'  \item{location_code}{3 letter ISO country code.}
#'  \item{hs_product_code}{4 digit HS1992 product code. }
#'  \item{export_value}{Export value in US dollars.}
#'}
#' @source <https://dataverse.harvard.edu/dataverse/atlas>
#' @source <https://www.qgso.qld.gov.au/statistics/theme/economy/international-trade/exports>
#'
"combined_exports"

#' Australian State and territory services data
#'
#' Services data for Australian states and territories. From the ABS international trade supplementary information release
#' Table 3. International trade in services, credits, state by financial year, $m
#' @format Tibble with columns
#' \describe{
#' \item{location_code}{Abbreviated state/territory name.}
#' \item{year}{Year the service was exported. Data covers the period between 1999 and 2021.}
#' \item{hs_product_code}{Aggregated EBOPS service categories.
#'  Categories include communications, insurance and finance, transportation, travel and other.}
#' \item{export_value}{Export value in Australian dollars.}
#' }
#'
#' @details
#' ## Conversion between ABS service categories and EBOPS categories
#' | ABS Category | EBOPS |
#' |------------|-------|
#' | Manufacturing services on physical inputs owned by others | Other |
#' | Maintenance and repair services n.i.e | Other |
#' | Transport | Transport |
#' | Travel | Travel |
#' | Construction | Other |
#' | Insurance and Pension Services | Financial |
#' | Charges for the use of intellectual property n.i.e | Other |
#' | Telecommunications, computer and information services | ICT |
#' | Other Business Services | Other |
#' | Personal, Cultural, and Recreational Services | Other |
#' | Government Goods and Services n.i.e | Other |
#'
#' @source Australian Bureau of Statistics, International Trade: Supplementary Information, Financial Year
#'  <https://www.abs.gov.au/statistics/economy/international-trade/international-trade-supplementary-information-financial-year/2022-23>
"state_service_data"

#' Australian State Economic Complexity data
#' Economic Complexity data for Australian states and Northern Territory.
#' Complexity indicators are calculated using the full data set [`combined_exports`]
#' As such these indicators compare Australian states and the NT with the 133 countries
#' Included in the Atlas of Economic Complexity. The included countries can be seen in [`atlas_countries`]
"state_economic_complexity"

#' Atlas of Economic Complexity Countries.
#'
#' The name and ISO-3 representation of countries included in the Atlas of Economic Complexity
#'
#' @format Tibble with columns
#' \describe{
#' \item{location_code}{3-digit ISO country code}
#' \item{location_name_short_en}{English location name}
#' }
"atlas_countries"

#' Atlas of Economic Complexity Product Complexity Index
#'
"atlas_pci"

#' Atlas of Economic Complexity Economic Complexity Index
"atlas_eci"

#' ABS Employment by Industry by Occupation (SA3, 1-digit Industry, 1-digit Occupation)
"sa3_indp1_occp1"

#' ABS Employment by Industry by Occupation (SA2, 1-digit Industry, 1-digit Occupation)
"sa2_indp1_occp1"

#' ABS Employment by Industry (SA3, 4-digit Industry)
"sa3_indp4"

#' ABS Employment by Occupation (SA3, 4-digit Occupation)
"sa3_occp4"
