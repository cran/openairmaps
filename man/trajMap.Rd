% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trajMap.R
\name{trajMap}
\alias{trajMap}
\title{Trajectory line plots in leaflet}
\usage{
trajMap(
  data,
  longitude = "lon",
  latitude = "lat",
  colour,
  control = "default",
  cols = "default",
  alpha = 0.5,
  npoints = 12,
  provider = "OpenStreetMap"
)
}
\arguments{
\item{data}{Data frame, the result of importing a trajectory file using
\code{\link[openair:importTraj]{openair::importTraj()}}.}

\item{longitude}{Column containing the longitude, as a decimal.}

\item{latitude}{Column containing the latitude, as a decimal.}

\item{colour}{Column to be used for colouring each trajectory. This column
may be numeric, character or factor. This will commonly be a pollutant
concentration which has been joined (e.g., by \code{\link[dplyr:mutate-joins]{dplyr::left_join()}}) to the
trajectory data by \dQuote{date}.}

\item{control}{Column to be used for splitting the trajectories into
different groups which can be selected between using a "layer control"
menu.}

\item{cols}{Colours to be used for plotting. Options include
\dQuote{default}, \dQuote{increment}, \dQuote{heat}, \dQuote{jet} and
\code{\link[RColorBrewer:ColorBrewer]{RColorBrewer::brewer.pal()}} colours — see the \code{\link[openair:openColours]{openair::openColours()}}
function for more details. For user defined the user can supply a list of
colour names recognised by R (type \code{\link[grDevices:colors]{grDevices::colours()}} to see the full
list). An example would be \code{cols = c("yellow", "green", "blue")}. If
the \code{"colour"} argument was not used, a single colour can be named
which will be used consistently for all lines/points (e.g., \code{cols =
  "red"}).}

\item{alpha}{Opacity of lines/points. Must be between \code{0} and \code{1}.}

\item{npoints}{A dot is placed every \code{npoints} along each full
trajectory. For hourly back trajectories points are plotted every
\code{npoints} hours. This helps to understand where the air masses were at
particular times and get a feel for the speed of the air (points closer
together correspond to slower moving air masses). Defaults to \code{12}.}

\item{provider}{The base map to be used. See
\url{http://leaflet-extras.github.io/leaflet-providers/preview/} for a list
of all base maps that can be used.}
}
\value{
A leaflet object.
}
\description{
This function plots back trajectories on a \code{leaflet} map. This function
requires that data are imported using the \code{\link[openair:importTraj]{openair::importTraj()}} function.
Options are provided to colour the individual trajectories (e.g., by
pollutant concentrations) or create "layer control" menus to show/hide
different layers.
}
\examples{
\dontrun{
trajMap(traj_data, colour = "nox")
}

}