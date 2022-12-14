#' Pollution rose plots on interactive leaflet maps
#'
#' [pollroseMap()] creates a `leaflet` map using "pollution roses" as
#' markers. Any number of pollutants can be specified using the `pollutant`
#' argument, and multiple layers of markers can be added and toggled between
#' using `control`. See [openair::pollutionRose()] for more information.
#'
#' @family directional analysis maps
#'
#' @inheritParams polarMap
#' @param statistic The `statistic` to be applied to each data bin in the
#'   plot. Options currently include "prop.count", "prop.mean" and
#'   "abs.count". The default "prop.count" sizes bins according to
#'   the proportion of the frequency of measurements.  Similarly,
#'   "prop.mean" sizes bins according to their relative contribution to
#'   the mean. "abs.count" provides the absolute count of measurements in
#'   each bin.
#' @param breaks Most commonly, the number of break points. If not specified,
#'   each marker will independently break its supplied data at approximately 6
#'   sensible break points. When `breaks` are specified, all markers will
#'   use the same break points. Breaks can also be used to set specific break
#'   points. For example, the argument `breaks = c(0, 1, 10, 100)` breaks
#'   the data into segments <1, 1-10, 10-100, >100.
#' @param draw.legend When `breaks` are specified, should a shared legend
#'   be created at the side of the map? Default is `TRUE`.
#' @inheritDotParams openair::pollutionRose -breaks -mydata -pollutant -plot
#' @return A leaflet object.
#' @export
#'
#' @examples
#' \dontrun{
#' pollroseMap(polar_data,
#'   pollutant = "nox",
#'   statistic = "prop.count",
#'   provider = "Stamen.Toner"
#' )
#' }
pollroseMap <- function(data,
                        pollutant = NULL,
                        statistic = "prop.count",
                        breaks = NULL,
                        latitude = NULL,
                        longitude = NULL,
                        control = NULL,
                        popup = NULL,
                        label = NULL,
                        provider = "OpenStreetMap",
                        cols = "turbo",
                        key = FALSE,
                        draw.legend = TRUE,
                        collapse.control = FALSE,
                        iconWidth = 200,
                        iconHeight = 200,
                        fig.width = 3.5,
                        fig.height = 3.5,
                        type = NULL,
                        ...) {
  if (!is.null(type)) {
    cli::cli_warn(c(
      "!" = "{.code type} is deprecated. Different sites are now automatically identified.",
      "i" = "Please use {.code label} and/or {.code popup} to label sites."
    ))
  }

  # assume lat/lon
  latlon <- assume_latlon(
    data = data,
    latitude = latitude,
    longitude = longitude
  )
  latitude <- latlon$latitude
  longitude <- latlon$longitude

  data <-
    prepMapData(
      data = data,
      type = type,
      pollutant = pollutant,
      control = control,
      "wd",
      "ws",
      latitude,
      longitude,
      popup,
      label
    )

  # work out breaks
  # needs to happen before plotting to ensure same scales
  if (!is.null(breaks)) {
    theBreaks <-
      getBreaks(breaks = breaks, ws.int = NULL, vec = data$conc, polrose = TRUE)
  } else {
    theBreaks <- 6
  }

  # define plotting function
  args <- list(...)
  fun <- function(...) {
    rlang::exec(openair::pollutionRose, annotate = FALSE, statistic = statistic, breaks = theBreaks, !!!args, ...)
  }

  # identify splitting column (defaulting to pollutant)
  if (length(pollutant) > 1) {
    split_col <- "pollutant_name"
  } else if (!is.null(control)) {
    data[control] <- as.factor(data[[control]])
    split_col <- control
  } else {
    split_col <- "pollutant_name"
  }

  # create icons
  icons <-
    data %>%
    dplyr::group_split(.data[[split_col]]) %>%
    rlang::set_names(levels(data[[split_col]])) %>%
    purrr::imap(
      .f = ~ create_icons(
        data = .x, fun = fun, pollutant = "conc", split = .y,
        lat = latitude, lon = longitude, x = x, cols = cols,
        key = key, fig.width = fig.width, fig.height = fig.height,
        iconWidth = iconWidth, iconHeight = iconHeight, ...
      )
    )

  # plot leaflet
  map <-
    makeMap(
      data = data,
      icons = icons,
      provider = provider,
      longitude = longitude,
      latitude = latitude,
      popup = popup,
      label = label,
      split_col = split_col,
      collapse = collapse.control
    )

  if (!is.null(breaks) & draw.legend) {
    map <-
      leaflet::addLegend(
        map,
        pal = leaflet::colorBin(
          palette = openair::openColours(cols),
          domain = theBreaks,
          bins = theBreaks
        ),
        values = theBreaks,
        title = quickTextHTML(paste(pollutant, collapse = ", "))
      )
  }

  map
}
