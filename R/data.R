#' Atlas of Economic Complexity and Australian State export data
#'
#' Atlas of Economic complexity data with Australia removed and replaced by
#' Australian State export data. State export data has been converted from the AHECC
#' system to the Harmonised System (1992 version)
#'
#' @format ## `combined_exports`
#' A data frame with 4,667,908 rows and 4 columns:
#' \describe{
#'  \item{year}{Year}
#'  \item{location_code}{3 letter ISO country code}
#'  \item{hs_product_code}{4 digit HS1992 product code}
#'  \item{export_value}{Export value, $US}
#'}
#' @source <https://dataverse.harvard.edu/dataverse/atlas>
#' @source <https://www.qgso.qld.gov.au/statistics/theme/economy/international-trade/exports>
#'
"combined_exports"
