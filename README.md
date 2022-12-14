
<!-- README.md is generated from README.Rmd. Please edit that file -->

# openairmaps <img src="man/figures/logo.png" align="right" height="134" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/davidcarslaw/openairmaps/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/davidcarslaw/openairmaps/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/openairmaps)](https://CRAN.R-project.org/package=openairmaps)
<!-- badges: end -->

The goal of `{openairmaps}` is to combine the robust analytical methods
found in [openair](https://davidcarslaw.github.io/openair/) with the
highly capable `{leaflet}` package. `{openairmaps}` is thoroughly
documented in the [openair
book](https://bookdown.org/david_carslaw/openair/maps-overview.html).

## Installation

You can install the release version of `{openairmaps}` from CRAN with:

``` r
install.packages("openairmaps")
```

You can install the development version of `{openairmaps}` from GitHub
with:

``` r
# install.packages("devtools")
devtools::install_github("davidcarslaw/openairmaps")
```

## Overview

The `openairmaps` package is thoroughly documented in the [openair
book](https://bookdown.org/david_carslaw/openair/maps-overview.html),
which goes into great detail about its various functions. Functionality
includes visualising UK AQ networks (`networkMap()`), putting “polar
directional markers” on maps (e.g., `polarMap()`) and overlaying HYSPLIT
trajectories on maps (e.g., `trajMap()`).

``` r
library(openairmaps)
polar_data %>%
  openair::cutData("daylight") %>%
  buildPopup(
    c("site", "site_type"),
    names = c("Site" = "site", "Site Type" = "site_type"),
    control = "daylight"
  ) %>%
  polarMap(
    control = "daylight",
    pollutant = "no2",
    limits = c(0, 180),
    cols = "turbo",
    popup = "popup"
  )
```

![An example `polarMap()` showing NO2 concentrations in central
London.](man/figures/README-examplemap.png)
