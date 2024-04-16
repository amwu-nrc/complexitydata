#' Update Economic Complexity Data
#'
#' @return NULL
#' @export
#'
update_data <- function() {
  source("data-raw/services_data.R")
  source("data-raw/state_global_export_data.R")
  source("data-raw/state_economic_complexity.R")
}
