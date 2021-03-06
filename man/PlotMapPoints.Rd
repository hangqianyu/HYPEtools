% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/function_PlotMapPoints.R
\name{PlotMapPoints}
\alias{PlotMapPoints}
\title{Plot function for mapped point information}
\usage{
PlotMapPoints(x, sites, sites.subid.column = 1, bg = NULL,
  map.adj = 0, plot.legend = T, legend.pos = "right",
  legend.title = NULL, legend.outer = F, legend.inset = c(0, 0),
  col = NULL, col.breaks = NULL, plot.scale = T, plot.arrow = T,
  pt.cex = 1, par.cex = 1, par.mar = rep(0, 4) + 0.1, add = FALSE,
  restore.par = FALSE)
}
\arguments{
\item{x}{Information to plot, typically model performances from imported HYPE 'subassX.txt' files. Data frame object 
with two columns, first column containing SUBIDs and second column containing model results to plot. See details.}

\item{sites}{A \code{SpatialPointsDataFrame} object. Typically an imported outlet point shape file, shape file import requires 
additional packages, e.g. \code{rgdal}.}

\item{sites.subid.column}{Integer, column index in the \code{sites} 'data' \code{\link{slot}} holding SUBIDs (sub-catchment IDs).}

\item{bg}{A \code{SpatialPolygonsDataFrame} object to plot as grey background. Typically an imported sub-basin shape file. 
For plots with several background layers, use \code{add = TRUE} and plot background layer(s) first.}

\item{map.adj}{Numeric, map adjustion in direction where it is smaller than the plot window. A value of \code{0} means left-justified 
or bottom-justified, \code{0.5} (the default) means centered, and \code{1} means right-justified or top-justified.}

\item{plot.legend}{Logical, plot a legend along with the map. Uses function \code{\link{legend}}.}

\item{legend.pos}{Legend, scale, and north arrow position, keyword string. One of \code{"left"}, \code{"topleft"}, \code{"topright"}, 
\code{"right"}, \code{"bottomright"}, \code{"bottomleft"}.}

\item{legend.title}{Character string or mathematical expression. An optional title for the legend. If none is provided here, \code{var.name}
is used as legend title string. For select HYPE variables, pretty legend titles are in-built.}

\item{legend.outer}{Logical. If \code{TRUE}, outer break point values will be plotted in legend.}

\item{legend.inset}{Numeric, inset distance(s) from the margins as a fraction of the plot region for legend, scale and north arrow. 
See \code{\link{legend}} and details below.}

\item{col}{Colors to use on the map. One of the following: \itemize{
\item \code{NULL}, to use a default purple-red-yellow-blue color ramp, best used with \code{col.breaks = NULL}.
\item A color ramp palette function, e.g. as returned from a call to \code{\link{colorRampPalette}}
\item A vector of colors. This can be a character vector of R's built-in color names or hexadecimal strings as returned by 
\code{\link{rgb}}, or an integer vector of current \code{\link{palette}} indices.
}}

\item{col.breaks}{A numeric vector, specifying break points for discretisation of model result values into classes. Class boundaries will be
interpreted as right-closed, i.e upper boundaries included in class. Lowest class boundary included in lowest class as well.
Meaningful results require the lowest and uppermost breaks to bracket all model result values, otherwise there will be 
unclassified white spots on the map plot. If \code{NULL} (the default), \code{col.breaks} covers a range from 0 to 1 
with 9 intervals, and an additional interval for negative values. This is suitable for e.g. NSE performances.}

\item{plot.scale}{Logical, plot a scale bar below legend (i.e. position defined by legend position). NOTE: works only with 
projected maps based on meter units, not geographical projections}

\item{plot.arrow}{Logical, plot a North arrow below legend (i.e. position defined by legend position).}

\item{pt.cex}{Numeric, plot point size expansion factor, works on top of \code{par.cex}.}

\item{par.cex}{Numeric, character expansion factor. See description of \code{cex} in \code{\link{par}}.}

\item{par.mar}{Plot margins as in \code{\link{par}} argument \code{mar}. Defaults to a nearly margin-less plot. 
In standard use cases of this function, plot margins do not need to be changed.}

\item{add}{Logical, default \code{FALSE}. If \code{TRUE}, add to existing plot. In that case \code{map.adj} has no effect.}

\item{restore.par}{Logical, if \code{TRUE}, par settings will be restored to original state on function exit.}
}
\value{
\code{PlotMapPoints} returns a plot to the currently active plot device, and invisibly an object of class 
\code{\link{SpatialPointsDataFrame}} as provided in argument \code{sites}, with plotted values and color codes added as columns 
in the data slot.
}
\description{
Plot mapped point information, e.g. model performances at observation sites.
}
\details{
\code{PlotMapPoints} can be used to print point information on a mapped surface. The primary target are model performance 
measures as written to 
\href{http://www.smhi.net/hype/wiki/doku.php?id=start:hype_file_reference:subassx.txt}{HYPE 'subassX.txt' files}, but 
color scale and break point arguments are flexible enough to also be used with e.g. HYPE output variables or other data.

\code{PlotMapPoints} per default works with a margin-less figure and positions map and legend items close to the plot boundaries. 
In order to move map and legend closer to each other, change the plot device width. 

Legends are positioned by keyword through argument \code{legend.pos}, defaulting to the right side of the map. \code{legend.pos} and 
\code{map.adj} should be chosen so that legend and map do not overlap. Additionally, the legend position can be fine-tuned using 
argument \code{legend.inset}. This is particularly useful for legend titles with more than one line. For details on inset 
specification see \code{inset} in \code{\link{legend}}.
}
\examples{
\dontrun{require(rgdal)
x11(width = 5, height = 8)
mysites <- readOGR(dsn = "../gisdata", layer = "myHYPEoutlets")
mybg <- readOGR(dsn = "../gisdata", layer = "myHYPEsubids")
PlotMappoints(x = mysubass, sites = mysites, map.subid.column = 2, bg = mybg)}

}
\seealso{
\code{\link{ReadSubass}} for HYPE result import; \code{\link{ReadMapOutput}} for a similar plot function
}
