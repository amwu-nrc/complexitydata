#' Atlas of Economic Complexity and Australian State export data
#'
#' @details
#'
#' Atlas of Economic complexity data with Australia removed and replaced by
#' Australian State export data. State export data has been converted from the AHECC
#' system to the Harmonised System (1992 version)
#'
#' Economic complexity indicators provided by the Atlas of Economic Complexity will not align with the indicators included in this dataset.
#' This is due in part to the inclusion of the state export data and exclusion of Australia. However, export data provided by the Atlas of Economic
#' Complexity dataverse undergoes additional pre-processing before the indicators are calculated (see: \url{https://github.com/cid-harvard/py-ecomplexity/issues/21})
#'
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

#' @format Tibble with columns:
#' \describe{
#' \item{year}
#' \item{location_code}{3-digit ISO country code and short Australian state identifier. See [`atlas_countries`].}
#' \item{hs_product_code}{4-digit Harmonised System 1992 product code}
#' \item{export_value}{Export value in US dollars}
#' \item{rca}{Revealed comparative advantage. An RCA greater than or equal to 1 indicates that the product is 'present' in that countries export basket.}
#' \item{product_complexity_index}{Standardised product complexity index}
#' \item{country_complexity_index}{Standardised country complexity index}
#' \item{complexity_outlook_index}{Standardised potential for country complexity to increase}
#' \item{cog}{Complexity outlook gain.
#' Benefit to the country in terms of increased opportunities to diversify into more complex products from developing
#' a specialisation in the product}
#' \item{density}{How "near" the product is to the existing set of capabilities in the country}
#' \item{eci_rank}{Within year rank of the countries economic complexity index}
#' }
#'
#' @details
#' Economic Complexity data for Australian states and Northern Territory.
#' Complexity indicators are calculated using the full data set [`combined_exports`]
#' As such these indicators compare Australian states and the NT with the 133 countries
#' Included in the Atlas of Economic Complexity. The included countries can be seen in [`atlas_countries`]
#'
#'
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

#' ABS Employment Data
#'
#' @name absemployment
#' @format Tibble with columns
"sa3_indp1_occp1"

#' ABS Employment by Industry by Occupation (SA2, 1-digit Industry, 1-digit Occupation)
#' @rdname absemployment
"sa2_indp1_occp1"

#' ABS Employment by Industry (SA3, 4-digit Industry)
#' @rdname absemployment
"sa3_indp4"

#' ABS Employment by Occupation (SA3, 4-digit Occupation)
#' @rdname absemployment
"sa3_occp4"

#' @rdname absemployment
"sa3_indp2_occp1"
