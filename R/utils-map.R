#' Check input & prep data
#' @author David Carslaw
#' @noRd
checkMapPrep <-
  function(mydata,
           Names,
           remove.calm = TRUE,
           remove.neg = TRUE,
           wd = "wd") {
    ## deal with conditioning variable if present, if user-defined, must exist
    ## in data pre-defined types existing conditioning variables that only
    ## depend on date (which is checked)
    conds <- c(
      "default",
      "year",
      "hour",
      "month",
      "season",
      "weekday",
      "week",
      "weekend",
      "monthyear",
      "gmtbst",
      "bstgmt",
      "dst",
      "daylight",
      "yearseason",
      "seasonyear"
    )
    all.vars <- unique(c(names(mydata), conds))

    varNames <- c(Names) ## names we want to be there
    matching <- varNames %in% all.vars

    if (any(!matching)) {
      ## not all variables are present
      stop(
        "Can't find the variable(s): ",
        paste(varNames[!matching], collapse = ", "),
        "\n"
      )
    }

    ## just select data needed
    mydata <- mydata[, Names]

    ## if site is in the data set, check none are missing
    ## seems to be a problem for some KCL data...
    if ("site" %in% names(mydata)) {
      ## split by site

      ## remove any NA sites
      if (anyNA(mydata$site)) {
        id <- which(is.na(mydata$site))
        mydata <- mydata[-id, ]
      }
    }


    ## sometimes ratios are considered which can results in infinite values
    ## make sure all infinite values are set to NA
    mydata[] <- lapply(mydata, function(x) {
      replace(x, x == Inf | x == -Inf, NA)
    })

    if ("ws" %in% Names) {
      if ("ws" %in% Names & is.numeric(mydata$ws)) {
        ## check for negative wind speeds
        if (any(sign(mydata$ws[!is.na(mydata$ws)]) == -1)) {
          if (remove.neg) {
            ## remove negative ws only if TRUE
            warning("Wind speed <0; removing negative data")
            mydata$ws[mydata$ws < 0] <- NA
          }
        }
      }
    }

    ## round wd to make processing obvious
    ## data already rounded to nearest 10 degress will not be affected
    ## data not rounded will be rounded to nearest 10 degrees
    ## assumes 10 is average of 5-15 etc
    if (wd %in% Names) {
      if (wd %in% Names & is.numeric(mydata[, wd])) {
        ## check for wd <0 or > 360
        if (any(sign(mydata[[wd]][!is.na(mydata[[wd]])]) == -1 |
          mydata[[wd]][!is.na(mydata[[wd]])] > 360)) {
          warning("Wind direction < 0 or > 360; removing these data")
          mydata[[wd]][mydata[[wd]] < 0] <- NA
          mydata[[wd]][mydata[[wd]] > 360] <- NA
        }

        if (remove.calm) {
          if ("ws" %in% names(mydata)) {
            mydata[[wd]][mydata$ws == 0] <-
              NA ## set wd to NA where there are calms
            mydata$ws[mydata$ws == 0] <- NA ## remove calm ws
          }
          mydata[[wd]][mydata[[wd]] == 0] <-
            360 ## set any legitimate wd to 360

          ## round wd for use in functions - except windRose/pollutionRose
          mydata[[wd]] <- 10 * ceiling(mydata[[wd]] / 10 - 0.5)
          mydata[[wd]][mydata[[wd]] == 0] <-
            360 # angles <5 should be in 360 bin
        }
        mydata[[wd]][mydata[[wd]] == 0] <-
          360 ## set any legitimate wd to 360
      }
    }


    ## make sure date is ordered in time if present
    if ("date" %in% Names) {
      if ("POSIXlt" %in% class(mydata$date)) {
        stop("date should be in POSIXct format not POSIXlt")
      }

      ## try and work with a factor date - but probably a problem in original data
      if (is.factor(mydata$date)) {
        warning("date field is a factor, check date format")
        mydata$date <- as.POSIXct(mydata$date, "GMT")
      }

      mydata <- dplyr::arrange(mydata, date)

      ## make sure date is the first field
      if (names(mydata)[1] != "date") {
        mydata <- mydata[c("date", setdiff(names(mydata), "date"))]
      }

      ## check to see if there are any missing dates, stop if there are
      ids <- which(is.na(mydata$date))
      if (length(ids) > 0) {
        mydata <- mydata[-ids, ]
        warning(
          paste(
            "Missing dates detected, removing",
            length(ids), "lines"
          ),
          call. = FALSE
        )
      }

      ## daylight saving time can cause terrible problems - best avoided!!

      if (any(lubridate::dst(mydata$date))) {
        message("Detected data with Daylight Saving Time.")
      }
    }

    ## return data frame
    return(mydata)
  }

#' Prep data for mapping
#' @noRd
prepMapData <-
  function(data, pollutant, control, ..., .to_narrow = TRUE) {
    # check pollutant is there
    if (is.null(pollutant)) {
      cli::cli_abort(
        c(
          "x" = "{.code pollutant} is missing with no default.",
          "i" = "Please provide a column of {.code data} which represents the pollutant(s) of interest."
        )
      )
    }

    ## extract variables of interest
    vars <- unique(c(pollutant, control, ...))

    # check and select variables
    data <- checkMapPrep(data, vars)

    # check to see if variables exist in data
    if (length(intersect(vars, names(data))) != length(vars)) {
      stop(paste(vars[which(!vars %in% names(data))], "not found in data"), call. = FALSE)
    }

    # check if more than one pollutant & is.null split
    if (length(pollutant) > 1 & !is.null(control)) {
      cli::cli_warn(
        c(
          "!" = "Multiple pollutants {.emph and} {.code control/facet} option specified",
          "i" = "Please only specify multiple pollutants {.emph or} a {.code control/facet} option",
          "i" = "Defaulting to splitting by {.code pollutant}"
        )
      )
    }

    if (.to_narrow) {
      # pollutants to long
      data <-
        tidyr::pivot_longer(
          data = data,
          cols = dplyr::all_of(pollutant),
          names_to = "pollutant_name",
          values_to = "conc"
        )

      # make pollutant names factors
      data <-
        dplyr::mutate(
          .data = data,
          pollutant_name = as.factor(.data$pollutant_name)
        )
    }

    return(data)
  }

#' guess latlon
#' @noRd
assume_latlon <- function(data, latitude, longitude) {
  guess_latlon <- function(data, latlon = c("lat", "lon")) {
    x <- names(data)
    if (latlon == "lat") {
      name <- "latitude"
      str <- c("latitude", "latitud", "lat")
    } else if (latlon == "lon") {
      name <- "longitude"
      str <- c("longitude", "longitud", "lon", "long", "lng")
    }
    str <-
      c(
        str,
        toupper(str),
        tolower(str),
        stringr::str_to_title(str)
      )
    id <- x %in% str
    out <- x[id]
    len <- length(out)
    if (len > 1) {
      cli::cli_abort("Cannot identify {name}: Multiple possible matches ({out})",
        call = NULL
      )
      return(NULL)
    } else if (len == 0) {
      cli::cli_abort("Cannot identify {name}: No clear match.", call = NULL)
      return(NULL)
    } else {
      cli::cli_alert_info("Assuming {name} is '{out}'")
      return(out)
    }
  }

  if (is.null(latitude) | is.null(longitude)) {
    if (is.null(latitude)) {
      latitude <- guess_latlon(data, "lat")
    } else {
      cli::cli_alert_success("Latitude provided as '{latitude}'")
    }
    if (is.null(longitude)) {
      longitude <- guess_latlon(data, "lon")
    } else {
      cli::cli_alert_success("Latitude provided as '{longitude}'")
    }
  }

  out <- list(
    latitude = latitude,
    longitude = longitude
  )
}

#' get breaks for the "rose" functions
#' @param breaks as given by windrose
#' @param ws.int as given by windrose
#' @param vec the vector to calc max/min/q90
#' @param polrose use pollutionrose method? T/F
#' @noRd
getBreaks <- function(breaks, ws.int, vec, polrose) {
  if (is.numeric(breaks) & length(breaks) == 1 & polrose) {
    breaks <- unique(pretty(
      c(
        min(vec, na.rm = TRUE),
        stats::quantile(vec, probs = 0.9, na.rm = TRUE)
      ),
      breaks
    ))
  }
  if (length(breaks) == 1) {
    breaks <- 0:(breaks - 1) * ws.int
  }
  if (max(breaks) < max(vec, na.rm = T)) {
    breaks <- c(breaks, max(vec, na.rm = T))
  }
  breaks <- unique(breaks)
  breaks <- sort(breaks)
  breaks
}

#' make leaflet map from scratch
#' @noRd
make_leaflet_map <-
  function(data,
           latitude,
           longitude,
           provider,
           d.icon,
           popup,
           label,
           split_col,
           collapse.control) {
    # create map
    map <- leaflet::leaflet(data)

    # add provider tiles
    if (is.null(names(provider)) | "" %in% names(provider)) {
      names(provider) <- provider
    }
    for (i in seq_along(provider)) {
      map <- leaflet::addProviderTiles(map,
        provider[[i]],
        group = names(provider)[[i]]
      )
    }

    # work out width/height
    if (length(d.icon) == 1) {
      width <- height <- d.icon
    }
    if (length(d.icon) == 2) {
      width <- d.icon[[1]]
      height <- d.icon[[2]]
    }

    # add markers
    marker_arg <- list(
      map = map,
      lat = data[[latitude]],
      lng = data[[longitude]],
      icon = leaflet::makeIcon(
        iconUrl = data$url,
        iconHeight = height,
        iconWidth = width,
        iconAnchorX = width / 2,
        iconAnchorY = height / 2
      ),
      group = quickTextHTML(data[[split_col]])
    )

    if (!is.null(popup)) {
      marker_arg <- append(marker_arg, list(popup = data[[popup]]))
    }
    if (!is.null(label)) {
      marker_arg <- append(marker_arg, list(label = data[[label]]))
    }

    map <- rlang::exec(leaflet::addMarkers, !!!marker_arg)

    # add layer control menu
    flag_provider <- dplyr::n_distinct(provider) > 1
    flag_split <- dplyr::n_distinct(data[[split_col]]) > 1
    opts <-
      leaflet::layersControlOptions(collapsed = collapse.control, autoZIndex = FALSE)

    if (flag_provider & flag_split) {
      map <-
        leaflet::addLayersControl(
          map,
          baseGroups = quickTextHTML(unique(data[[split_col]])),
          overlayGroups = names(provider),
          options = opts
        ) %>%
        leaflet::hideGroup(group = names(provider)[-1])
    } else if (flag_provider & !flag_split) {
      map <-
        leaflet::addLayersControl(map, baseGroups = names(provider), options = opts) %>%
        leaflet::hideGroup(group = names(provider)[-1])
    } else if (!flag_provider & flag_split) {
      map <-
        leaflet::addLayersControl(map, baseGroups = quickTextHTML(unique(data[[split_col]])), options = opts)
    }

    return(map)
  }

#' theme for static maps
#' @noRd
theme_static <- function() {
  ggplot2::`%+replace%`(
    ggplot2::theme_minimal(),
    ggplot2::theme(panel.border = ggplot2::element_rect(fill = NA, color = "black"))
  )
}

#' Create markers for the static plots
#' @param fun function of "data" to create plot
#' @param dir directory (created in function)
#' @param latitude,longitude,split_col,d.fig inherited from parent
#' @noRd
create_polar_markers <-
  function(fun,
           data = data,
           latitude = latitude,
           longitude = longitude,
           split_col = split_col,
           popup = NULL,
           label = NULL,
           d.fig,
           dropcol = "conc") {
    # make temp directory
    dir <- tempdir()

    # unique id
    id <- gsub(" |:|-", "", as.character(Sys.time()))

    # sort out popups/labels
    if (is.null(popup)) {
      data$popup <- "NA"
      popup <- "popup"
    }
    if (is.null(label)) {
      data$label <- "NA"
      label <- "label"
    }

    # drop missing data
    data <- tidyr::drop_na(data, dplyr::all_of(dropcol))

    # get number of rows
    valid_rows <-
      nrow(dplyr::distinct(data, .data[[latitude]], .data[[longitude]], .data[[split_col]]))

    # nest data
    nested_df <- data %>%
      tidyr::nest(data = -dplyr::all_of(c(
        latitude, longitude, split_col, popup, label
      )))

    # check for popup issues
    if (nrow(nested_df) > valid_rows) {
      cli::cli_abort(
        c(
          "x" = "Multiple popups/labels per {.code latitude}/{.code longitude}/{.code control} combination.",
          "i" = "Have you used a numeric column, e.g., a pollutant concentration?",
          "i" = "Consider using {.fun buildPopup} to easily create distinct popups per marker."
        )
      )
    }

    # create plots
    plots_df <-
      nested_df %>%
      dplyr::mutate(
        plot = purrr::map(data, fun, .progress = "Creating Polar Markers"),
        url = paste0(dir, "/", .data[[latitude]], "_", .data[[longitude]], "_", .data[[split_col]], "_", id, ".png")
      )

    # work out w/h
    if (length(d.fig) == 1) {
      width <- height <- d.fig
    }
    if (length(d.fig) == 2) {
      width <- d.fig[[1]]
      height <- d.fig[[2]]
    }

    purrr::pwalk(list(plots_df[[latitude]], plots_df[[longitude]], plots_df[[split_col]], plots_df$plot),
      .f = ~ {
        grDevices::png(
          filename = paste0(dir, "/", ..1, "_", ..2, "_", ..3, "_", id, ".png"),
          width = width * 300,
          height = height * 300,
          res = 300,
          bg = "transparent",
          type = "cairo",
          antialias = "none"
        )

        plot(..4)

        grDevices::dev.off()
      }
    )

    return(plots_df)
  }

#' if ggmap is not provided, have a guess
#' @param data `plots_df` input
#' @param ggmap,latitude,longitude,zoom inherited from parent
#' @noRd
estimate_ggmap <-
  function(ggmap = ggmap,
           data,
           latitude = latitude,
           longitude = longitude,
           zoom = zoom) {
    if (is.null(ggmap)) {
      lat_d <- abs(diff(range(data[[latitude]])) / 2)
      lon_d <- abs(diff(range(data[[longitude]])) / 2)
      d <- max(lon_d, lat_d)
      if (d == 0) d <- 0.05

      minlat <- min(data[[latitude]]) - d
      maxlat <- max(data[[latitude]]) + d

      minlon <- min(data[[longitude]]) - d
      maxlon <- max(data[[longitude]]) + d

      ggmap <-
        ggmap::get_stamenmap(
          bbox = c(minlon, minlat, maxlon, maxlat),
          zoom = zoom
        )
    }

    return(ggmap)
  }

#' Create static map
#' @param ggmap:facet.nrow inherited from parent
#' @param plots_df `plots_df`
#' @noRd
create_static_map <-
  function(ggmap,
           plots_df,
           latitude,
           longitude,
           split_col,
           pollutant,
           d.icon,
           facet,
           facet.nrow) {
    # work out width/height
    if (length(d.icon) == 1) {
      width <- d.icon
      height <- d.icon
    }
    if (length(d.icon) == 2) {
      width <- d.icon[[1]]
      height <- d.icon[[2]]
    }

    # don't turn facet levels into chr, keep as fct
    if (length(pollutant) > 1 | !is.null(facet)) {
      levels(plots_df[[split_col]]) <- quickTextHTML(levels(plots_df[[split_col]]))
    }

    # make plot
    plt <-
      ggmap::ggmap(ggmap) +
      ggtext::geom_richtext(
        data = dplyr::mutate(
          plots_df,
          url = stringr::str_glue("<img src='{url}' width='{width}' height='{height}'/>")
        ),
        ggplot2::aes(.data[[longitude]], .data[[latitude]], label = .data$url),
        fill = NA,
        color = NA
      ) +
      ggplot2::labs(x = NULL, y = NULL) +
      theme_static()

    if (length(pollutant) > 1 | !is.null(facet)) {
      plt <-
        plt + ggplot2::facet_wrap(ggplot2::vars(.data[[split_col]]), nrow = facet.nrow) +
        ggplot2::theme(strip.text = ggtext::element_markdown())
    }

    return(plt)
  }

#' function to quickly combine multiple popups together
#' @param data,popup,latitude,longitude,control inherited from parent
#' @noRd
quick_popup <- function(data, popup, latitude, longitude, control) {
  nice_popup <-
    stringr::str_replace_all(popup, "\\_|\\.|\\-", " ") %>%
    stringr::str_to_title()

  names <- stats::setNames(popup, nice_popup)

  buildPopup(
    data,
    cols = popup,
    latitude = latitude,
    longitude = longitude,
    names = names,
    control = control
  )
}

#' does 'cutdata'
#' @param data,type inherited from parent function
#' @noRd
quick_cutdata <- function(data, type) {
  if (is.null(type)) type <- "default"
  openair::cutData(data, type = type)
}

#' checks if multiple pollutants have been provided with a "fixed" scale
#' @noRd
check_multipoll <- function(vec, pollutant){
  if ("fixed" %in% vec & length(pollutant) > 1) {
    cli::cli_warn("{.code 'fixed'} limits only work with a single given {.field pollutant}")
    "free"
  } else {
    vec
  }
}

#' check if ggmap has been provided
#' @noRd
check_ggmap <- function(missing) {
  if (missing) {
    cli::cli_abort(
      c("!" = "No {.field ggmap} provided.",
        "i" = "Please use {.fun ggmap::get_map} or similar to get a tileset."),
      call = NULL
    )
  }
}
