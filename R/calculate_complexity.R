#' Calculate economic complexity indicators
#'
#' @param data data suitable for calculating complexity.
#' @param region  variable in `data` which corresponds to a region.
#' @param product variable in `data` which corresponds to a product.
#' @param value variable in `data` which corresponds to a value.
#' @param year year to calculate complexity indicators.
#'
#' @return dataframe
#' @export
#'
#' @examples \dontrun{
#'
#' calculate_complexity(state_data,
#' region = "location_code",
#' product = "hs_product_code",
#' value = "export_value",
#' year = 1996)
#'
#' }
calculate_complexity <- function(
  data,
  region,
  product,
  value,
  year,
  continuous = F
) {
  data <- data |>
    dplyr::filter(year == {{ year }})

  matrix_to_df <- function(matrix, region, product, values_to) {
    as.matrix(matrix) |>
      dplyr::as_tibble(rownames = region) |>
      tidyr::pivot_longer(
        cols = -region,
        names_to = dplyr::all_of(product),
        values_to = values_to
      )
  }

  rca <- data |>
    dplyr::select({{ product }}, {{ region }}, {{ value }}) |>
    dplyr::mutate(export_value_c = sum(.data[[value]]), .by = {{ region }}) |>
    dplyr::mutate(export_value_p = sum(.data[[value]]), .by = {{ product }}) |>
    dplyr::mutate(
      export_value_cp = sum(.data[[value]]),
      rca_cp = (export_value / export_value_c) /
        (export_value_p / export_value_cp),
      bi = as.numeric(rca_cp >= 1),
      bi_c = rca_cp / (1 + rca_cp)
    )

  countries <- as.factor(data[[region]])
  products <- as.factor(data[[product]])

  matrix_data <- matrix(
    0,
    nrow = length(levels(countries)),
    ncol = length(levels(products)),
    dimnames = list(levels(countries), levels(products))
  )
  indices <- cbind(as.numeric(countries), as.numeric(products))

  if (continuous) {
    matrix_data[indices] <- rca$bi_c
  } else {
    matrix_data[indices] <- rca$bi
  }

  bi <- matrix_data

  complexity <- economiccomplexity::complexity_measures(
    bi,
    method = "eigenvalues"
  )

  prox <- economiccomplexity::proximity(bi)

  outlook <- economiccomplexity::complexity_outlook(
    bi,
    prox$proximity_product,
    complexity$complexity_index_product
  )

  dens <- economiccomplexity::density(bi, prox$proximity_product)

  rca <- rca |>
    dplyr::select({{ product }}, {{ region }}, rca_cp)

  pci <- tibble::enframe(
    complexity$complexity_index_product,
    name = product,
    value = "product_complexity_index"
  )
  eci <- tibble::enframe(
    complexity$complexity_index_country,
    name = region,
    value = "country_complexity_index"
  )
  coi <- tibble::enframe(
    outlook$complexity_outlook_index,
    name = region,
    value = "complexity_outlook_index"
  )
  cog <- outlook$complexity_outlook_gain |>
    matrix_to_df(region = region, product = product, values_to = "cog")
  d <- dens |>
    matrix_to_df(region = region, product = product, values_to = "density")

  out <- dplyr::left_join(data, rca, by = c(region, product)) |>
    dplyr::left_join(pci, by = product) |>
    dplyr::left_join(eci, by = region) |>
    dplyr::left_join(coi, by = region) |>
    dplyr::left_join(cog, by = c(region, product)) |>
    dplyr::left_join(d, by = c(region, product))

  out
}

#' Calculate economic complexity indicators for multiple years
#'
#' @param data data suitable for calculating complexity.
#' @param years years to calculate complexity indicators.
#' @param region  variable in `data` which corresponds to a region.
#' @param product variable in `data` which corresponds to a product.
#' @param value variable in `data` which corresponds to a value.
#'
#' @return dataframe
#' @export
#'
#' @examples \dontrun{
#'
#' calculate_complexity_time_series(state_data,
#' years = unique(state_data$year),
#' region = "location_code",
#' product = "hs_product_code",
#' value = "export_value")
#'
#' }
calculate_complexity_time_series <- function(
  data,
  years,
  region,
  product,
  value
) {
  purrr::map(
    .x = years,
    .f = ~ calculate_complexity(
      data,
      region = {{ region }},
      product = {{ product }},
      value = {{ value }},
      year = .x
    ),
    .progress = TRUE
  ) |>
    purrr::list_rbind()
}
