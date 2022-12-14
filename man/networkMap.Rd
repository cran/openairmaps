% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/networkMap.R
\name{networkMap}
\alias{networkMap}
\title{Create a leaflet map of air quality measurement network sites}
\usage{
networkMap(
  source = "aurn",
  control = NULL,
  date = Sys.Date(),
  cluster = TRUE,
  provider = c("OpenStreetMap", "Esri.WorldImagery"),
  collapse.control = FALSE
)
}
\arguments{
\item{source}{One or more sources of meta data. Can be \code{aurn}, \code{saqn} (or
\code{saqd}), \code{aqe}, \code{waqn}, \code{ni}, \code{local} (or \code{lmam}), \code{kcl} or \code{europe}; upper
or lower case. See the "details" section for further information about
selecting multiple sites.}

\item{control}{Option to add a "layer control" menu to allow readers to
select between different site types. Can choose between effectively any
column in the \code{\link[openair:importMeta]{openair::importMeta()}} output, such as "variable",
"site_type", or "agglomeration", as well as "network" when more than one
\code{source} was specified.}

\item{date}{By default, \code{\link[=networkMap]{networkMap()}} visualises sites and pollutants which
are currently operational. Specifying \code{date} will visualise sites which
were operational at the chosen date. Dates should be provided in the
"YYYY-MM-DD" format. Alternatively, a single year can be provided ("YYYY")
and \code{\link[=networkMap]{networkMap()}} will visualise sites which were operational at the \emph{end}
of that year (December 31st).}

\item{cluster}{When \code{cluster = TRUE}, markers are clustered together. This
may be useful for sources like "kcl" where there are many markers very
close together. Defaults to \code{TRUE}, and is forced to be \code{TRUE} when \code{source = "europe"} due to the large number of sites.}

\item{provider}{The base map(s) to be used. See
\url{http://leaflet-extras.github.io/leaflet-providers/preview/} for a list of
all base maps that can be used. If multiple base maps are provided, they
can be toggled between using a "layer control" interface.}

\item{collapse.control}{Should the "layer control" interface be collapsed?
Defaults to \code{FALSE}.}
}
\value{
A leaflet object.
}
\description{
This function uses \code{\link[openair:importMeta]{openair::importMeta()}} to obtain metadata for measurement
sites and uses it to create an attractive \code{leaflet} map. By default a map
will be created in which readers may toggle between a vector base map and a
satellite/aerial image, although users can further customise the control menu
using the \code{provider} and \code{control} parameters.
}
\details{
When selecting multiple data sources using \code{source}, please be mindful that
there can be overlap between the different networks. For example, an air
quality site in Scotland may be part of the AURN \emph{and} the SAQN.
\code{\link[=networkMap]{networkMap()}} will only show one marker for such sites, and uses the order
in which \code{source} arguments are provided as the hierarchy by which to assign
sites to networks. The aforementioned AURN & SAQN site will therefore have
its SAQN code displayed if \code{source = c("saqn", "aurn")}, and its AURN code
displayed if \code{source = c("aurn", "saqn")}.

This hierarchy is also reflected when \code{control = "network"} is used. As
\code{leaflet} markers cannot be part of multiple groups, the AURN & SAQN site
will be part of the "SAQN" layer control group when \code{source = c("saqn", "aurn")} and the "AURN" layer control group when \code{source = c("aurn", "saqn")}.
}
\examples{
\dontrun{
# view one network, grouped by site type
networkMap(source = "aurn", control = "site_type")

# view multiple networks, grouped by network
networkMap(source = c("aurn", "waqn", "saqn"), control = "network")
}

}
