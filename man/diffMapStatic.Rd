% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/polar_diffMap.R
\name{diffMapStatic}
\alias{diffMapStatic}
\title{Bivariate polar plots on a static ggmap}
\usage{
diffMapStatic(
  before,
  after,
  pollutant = NULL,
  ggmap,
  limits = "free",
  x = "ws",
  latitude = NULL,
  longitude = NULL,
  facet = NULL,
  cols = c("#002F70", "#3167BB", "#879FDB", "#C8D2F1", "#F6F6F6", "#F4C8C8", "#DA8A8B",
    "#AE4647", "#5F1415"),
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)
}
\arguments{
\item{before}{A data frame that represents the "before" case. See
\code{\link[openair:polarPlot]{polarPlot()}} for details of different input requirements.}

\item{after}{A data frame that represents the "after" case. See \code{\link[openair:polarPlot]{polarPlot()}}
for details of different input requirements.}

\item{pollutant}{The column name(s) of the pollutant(s) to plot. If multiple
pollutants are specified, they will each form part of a separate panel.}

\item{ggmap}{A \code{ggmap} object obtained using \code{\link[ggmap:get_map]{ggmap::get_map()}} or a similar
function to use as the basemap.}

\item{limits}{One of:
\itemize{
\item \code{"fixed"} which ensures all of the markers use the same colour scale.
\item \code{"free"} (the default) which allows all of the markers to use different
colour scales.
\item A numeric vector in the form \code{c(lower, upper)} used to define the colour
scale. For example, \code{limits = c(0, 100)} would force the plot limits to
span 0-100.
}}

\item{x}{The radial axis variable to plot.}

\item{latitude, longitude}{The decimal latitude/longitude. If not provided,
will be automatically inferred from data by looking for a column named
"lat"/"latitude" or "lon"/"lng"/"long"/"longitude" (case-insensitively).}

\item{facet}{Used for splitting the input data into different panels, passed
to the \code{type} argument of \code{\link[openair:cutData]{openair::cutData()}}. \code{facet} cannot be used if
multiple \code{pollutant} columns have been provided.}

\item{cols}{The colours used for plotting. See \code{\link[openair:openColours]{openair::openColours()}} for
more information.}

\item{alpha}{The alpha transparency to use for the plotting surface (a value
between 0 and 1 with zero being fully transparent and 1 fully opaque).}

\item{key}{Should a key for each marker be drawn? Default is \code{FALSE}.}

\item{facet.nrow}{Passed to the \code{nrow} argument of \code{\link[ggplot2:facet_wrap]{ggplot2::facet_wrap()}}.}

\item{d.icon}{The diameter of the plot on the map in pixels. This will affect
the size of the individual polar markers. Alternatively, a vector in the
form \code{c(width, height)} can be provided if a non-circular marker is
desired.}

\item{d.fig}{The diameter of the plots to be produced using \code{openair} in
inches. This will affect the resolution of the markers on the map.
Alternatively, a vector in the form \code{c(width, height)} can be provided if a
non-circular marker is desired.}

\item{...}{
  Arguments passed on to \code{\link[openair:polarPlot]{openair::polarPlot}}
  \describe{
    \item{\code{wd}}{Name of wind direction field.}
    \item{\code{statistic}}{The statistic that should be applied to each wind
speed/direction bin. Because of the smoothing involved, the colour scale
for some of these statistics is only to provide an indication of overall
pattern and should not be interpreted in concentration units e.g. for
\code{statistic = "weighted.mean"} where the bin mean is multiplied by the
bin frequency and divided by the total frequency. In many cases using
\code{polarFreq} will be better. Setting \code{statistic = "weighted.mean"}
can be useful because it provides an indication of the concentration *
frequency of occurrence and will highlight the wind speed/direction
conditions that dominate the overall mean.Can be:

\itemize{ \item  \dQuote{mean} (default), \dQuote{median}, \dQuote{max}
(maximum), \dQuote{frequency}. \dQuote{stdev} (standard deviation),
\dQuote{weighted.mean}.

\item \code{statistic = "nwr"} Implements the Non-parametric Wind
Regression approach of Henry et al. (2009) that uses kernel smoothers. The
\code{openair} implementation is not identical because Gaussian kernels are
used for both wind direction and speed. The smoothing is controlled by
\code{ws_spread} and \code{wd_spread}.

\item \code{statistic = "cpf"} the conditional probability function (CPF)
is plotted and a single (usually high) percentile level is supplied. The
CPF is defined as CPF = my/ny, where my is the number of samples in the y
bin (by default a wind direction, wind speed interval) with mixing ratios
greater than the \emph{overall} percentile concentration, and ny is the
total number of samples in the same wind sector (see Ashbaugh et al.,
1985). Note that percentile intervals can also be considered; see
\code{percentile} for details.

\item When \code{statistic = "r"} or \code{statistic = "Pearson"}, the
Pearson correlation coefficient is calculated for \emph{two} pollutants.
The calculation involves a weighted Pearson correlation coefficient, which
is weighted by Gaussian kernels for wind direction an the radial variable
(by default wind speed). More weight is assigned to values close to a wind
speed-direction interval. Kernel weighting is used to ensure that all data
are used rather than relying on the potentially small number of values in a
wind speed-direction interval.

\item When \code{statistic = "Spearman"}, the Spearman correlation
coefficient is calculated for \emph{two} pollutants. The calculation
involves a weighted Spearman correlation coefficient, which is weighted by
Gaussian kernels for wind direction an the radial variable (by default wind
speed). More weight is assigned to values close to a wind speed-direction
interval. Kernel weighting is used to ensure that all data are used rather
than relying on the potentially small number of values in a wind
speed-direction interval.

\item \code{"robust_slope"} is another option for pair-wise statistics and
\code{"quantile.slope"}, which uses quantile regression to estimate the
slope for a particular quantile level (see also \code{tau} for setting the
quantile level).

\item \code{"york_slope"} is another option for pair-wise statistics which
uses the \emph{York regression method} to estimate the slope. In this
method the uncertainties in \code{x} and \code{y} are used in the
determination of the slope. The uncertainties are provided by
\code{x_error} and \code{y_error} --- see below.}}
    \item{\code{exclude.missing}}{Setting this option to \code{TRUE} (the default)
removes points from the plot that are too far from the original data. The
smoothing routines will produce predictions at points where no data exist
i.e. they predict. By removing the points too far from the original data
produces a plot where it is clear where the original data lie. If set to
\code{FALSE} missing data will be interpolated.}
    \item{\code{uncertainty}}{Should the uncertainty in the calculated surface be shown?
If \code{TRUE} three plots are produced on the same scale showing the
predicted surface together with the estimated lower and upper uncertainties
at the 95\% confidence interval. Calculating the uncertainties is useful to
understand whether features are real or not.  For example, at high wind
speeds where there are few data there is greater uncertainty over the
predicted values. The uncertainties are calculated using the GAM and
weighting is done by the frequency of measurements in each wind
speed-direction bin. Note that if uncertainties are calculated then the
type is set to "default".}
    \item{\code{percentile}}{If \code{statistic = "percentile"} then \code{percentile}
is used, expressed from 0 to 100. Note that the percentile value is
calculated in the wind speed, wind direction \sQuote{bins}. For this reason
it can also be useful to set \code{min.bin} to ensure there are a
sufficient number of points available to estimate a percentile. See
\code{quantile} for more details of how percentiles are calculated.

\code{percentile} is also used for the Conditional Probability Function
(CPF) plots. \code{percentile} can be of length two, in which case the
percentile \emph{interval} is considered for use with CPF. For example,
\code{percentile = c(90, 100)} will plot the CPF for concentrations between
the 90 and 100th percentiles. Percentile intervals can be useful for
identifying specific sources. In addition, \code{percentile} can also be of
length 3. The third value is the \sQuote{trim} value to be applied. When
calculating percentile intervals many can cover very low values where there
is no useful information. The trim value ensures that values greater than
or equal to the trim * mean value are considered \emph{before} the
percentile intervals are calculated. The effect is to extract more detail
from many source signatures. See the manual for examples. Finally, if the
trim value is less than zero the percentile range is interpreted as
absolute concentration values and subsetting is carried out directly.}
    \item{\code{weights}}{At the edges of the plot there may only be a few data points
in each wind speed-direction interval, which could in some situations
distort the plot if the concentrations are high. \code{weights} applies a
weighting to reduce their influence. For example and by default if only a
single data point exists then the weighting factor is 0.25 and for two
points 0.5. To not apply any weighting and use the data as is, use
\code{weights = c(1, 1, 1)}.

An alternative to down-weighting these points they can be removed
altogether using \code{min.bin}.}
    \item{\code{min.bin}}{The minimum number of points allowed in a wind speed/wind
direction bin.  The default is 1. A value of two requires at least 2 valid
records in each bin an so on; bins with less than 2 valid records are set
to NA. Care should be taken when using a value > 1 because of the risk of
removing real data points. It is recommended to consider your data with
care. Also, the \code{polarFreq} function can be of use in such
circumstances.}
    \item{\code{mis.col}}{When \code{min.bin} is > 1 it can be useful to show where data
are removed on the plots. This is done by shading the missing data in
\code{mis.col}. To not highlight missing data when \code{min.bin} > 1
choose \code{mis.col = "transparent"}.}
    \item{\code{upper}}{This sets the upper limit wind speed to be used. Often there are
only a relatively few data points at very high wind speeds and plotting all
of them can reduce the useful information in the plot.}
    \item{\code{force.positive}}{The default is \code{TRUE}. Sometimes if smoothing data
with steep gradients it is possible for predicted values to be negative.
\code{force.positive = TRUE} ensures that predictions remain positive. This
is useful for several reasons. First, with lots of missing data more
interpolation is needed and this can result in artefacts because the
predictions are too far from the original data. Second, if it is known
beforehand that the data are all positive, then this option carries that
assumption through to the prediction. The only likely time where setting
\code{force.positive = FALSE} would be if background concentrations were
first subtracted resulting in data that is legitimately negative. For the
vast majority of situations it is expected that the user will not need to
alter the default option.}
    \item{\code{k}}{This is the smoothing parameter used by the \code{gam} function in
package \code{mgcv}. Typically, value of around 100 (the default) seems to
be suitable and will resolve important features in the plot. The most
appropriate choice of \code{k} is problem-dependent; but extensive testing
of polar plots for many different problems suggests a value of \code{k} of
about 100 is suitable. Setting \code{k} to higher values will not tend to
affect the surface predictions by much but will add to the computation
time. Lower values of \code{k} will increase smoothing. Sometimes with few
data to plot \code{polarPlot} will fail. Under these circumstances it can
be worth lowering the value of \code{k}.}
    \item{\code{normalise}}{If \code{TRUE} concentrations are normalised by dividing by
their mean value. This is done \emph{after} fitting the smooth surface.
This option is particularly useful if one is interested in the patterns of
concentrations for several pollutants on different scales e.g. NOx and CO.
Often useful if more than one \code{pollutant} is chosen.}
    \item{\code{auto.text}}{Either \code{TRUE} (default) or \code{FALSE}. If \code{TRUE}
titles and axis labels will automatically try and format pollutant names
and units properly e.g.  by subscripting the `2' in NO2.}
    \item{\code{ws_spread}}{The value of sigma used for Gaussian kernel weighting of
wind speed when \code{statistic = "nwr"} or when correlation and regression
statistics are used such as \emph{r}. Default is \code{0.5}.}
    \item{\code{wd_spread}}{The value of sigma used for Gaussian kernel weighting of
wind direction when \code{statistic = "nwr"} or when correlation and
regression statistics are used such as \emph{r}. Default is \code{4}.}
    \item{\code{x_error}}{The \code{x} error / uncertainty used when \code{statistic =
"york_slope"}.}
    \item{\code{y_error}}{The \code{y} error / uncertainty used when \code{statistic =
"york_slope"}.}
    \item{\code{kernel}}{Type of kernel used for the weighting procedure for when
correlation or regression techniques are used. Only \code{"gaussian"} is
supported but this may be enhanced in the future.}
    \item{\code{formula.label}}{When pair-wise statistics such as regression slopes are
calculated and plotted, should a formula label be displayed?}
    \item{\code{tau}}{The quantile to be estimated when \code{statistic} is set to
\code{"quantile.slope"}. Default is \code{0.5} which is equal to the median
and will be ignored if \code{"quantile.slope"} is not used.}
    \item{\code{plot}}{Should a plot be produced? \code{FALSE} can be useful when
analysing data to extract plot components and plotting them in other ways.}
  }}
}
\value{
a \code{ggplot2} plot with a \code{ggmap} basemap
}
\description{
\code{\link[=diffMapStatic]{diffMapStatic()}} creates a \code{ggplot2} map using bivariate "difference" polar
plots as markers. As this function returns a \code{ggplot2} object, further
customisation can be achieved using functions like \code{\link[ggplot2:theme]{ggplot2::theme()}} and
\code{\link[ggplot2:guides]{ggplot2::guides()}}.
}
\section{Further customisation using ggplot2}{


As the outputs of the static directional analysis functions are \code{ggplot2}
figures, further customisation is possible using functions such as
\code{\link[ggplot2:theme]{ggplot2::theme()}}, \code{\link[ggplot2:guides]{ggplot2::guides()}} and \code{\link[ggplot2:labs]{ggplot2::labs()}}.

If multiple pollutants are specified, subscripting (e.g., the "x" in "NOx")
is achieved using the \link[ggtext:ggtext]{ggtext} package. Therefore if you
choose to override the plot theme, it is recommended to use
\verb{[ggplot2::theme()]} and \verb{[ggtext::element_markdown()]} to define the
\code{strip.text} parameter.

When arguments like \code{limits}, \code{percentile} or \code{breaks} are defined, a
legend is automatically added to the figure. Legends can be removed using
\code{ggplot2::theme(legend.position = "none")}, or further customised using
\code{\link[ggplot2:guides]{ggplot2::guides()}} and either \code{color = ggplot2::guide_colourbar()} for
continuous legends or \code{fill = ggplot2::guide_legend()} for discrete
legends.
}

\seealso{
the original \code{\link[openair:polarDiff]{openair::polarDiff()}}

\code{\link[=diffMap]{diffMap()}} for the interactive \code{leaflet} equivalent of
\code{\link[=diffMapStatic]{diffMapStatic()}}

Other static directional analysis maps: 
\code{\link{annulusMapStatic}()},
\code{\link{freqMapStatic}()},
\code{\link{percentileMapStatic}()},
\code{\link{polarMapStatic}()},
\code{\link{pollroseMapStatic}()},
\code{\link{windroseMapStatic}()}
}
\concept{static directional analysis maps}
