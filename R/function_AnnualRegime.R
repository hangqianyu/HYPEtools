
#' @export
#' @title
#' Calculate annual regimes
#'
#' @description
#' Calculate annual regimes based on long-term time series, typically imported HYPE basin output and time output result files.
#'
#' @param x Data frame, with column-wise equally-spaced time series. Date-times in \code{\link{POSIXct}} format in first column.
#' Typically an imported basin or time output file from HYPE. See details.
#' @param ts.in Character string, timestep of \code{x}, one of \code{"month"}, \code{"week"}, \code{"day"}, or 
#' \code{"nhour"} (n = number of hours). If not provided, an attribute \code{timestep} is required in \code{x}.
#' @param ts.out Character string, timestep for results, defaults to \code{ts.in}. This timestep must be equal to or longer than 
#' \code{ts.in}.
#' @param start.mon Integer between 1 and 12, starting month of the hydrological year, used to order the output.
#' @param incl.leap Logical, leap days (Mar 29) are removed from results per default, set to \code{TRUE} to keep them. Applies 
#' to daily and shorter time steps only.
#' @param na.rm Logical, indicating if \code{NA} values should be stripped before averages are calculated.
#' 
#' @details
#' \code{AnnualRegime} uses \code{\link{aggregate}} to calculate long-term average regimes for all data columns provided in \code{x}, 
#' including long-term arithmetic means, minima and maxima, and 25% and 75% percentiles. In a HYPE context, \code{AnnualRegime} 
#' is particularly applicable to model basin and time results imported using \code{\link{ReadBasinOutput}} and 
#' \code{\link{ReadTimeOutput}}. The function currently does not check if equally spaced time steps are provided in \code{x} or if the 
#' overall time period in \code{x} covers full years so that the calculated averages are based on the same number of values.
#' 
#' @note
#' If weekly data are provided in \code{x}, \code{AnnualRegime} will inflate \code{x} to daily time steps before computing 
#' results. Values in \code{x} will be assigned to the preceeding week days, corresponding to HYPE file output, where weekly 
#' values are conventionally printed on the last day of the week. If \code{NA} values are present in the original weekly data, 
#' these will be filled with the next available value as a side effect of the inflation.
#' 
#' If weekly output time steps are computed in combination with a user-defined start month, the function will round up weeks when 
#' determining first week of the hydrological year. 
#' 
#' @return 
#' \code{AnnualRegime} returns a list with 5 data frames and a two-element POSIXct vector containing start and end dates of the 
#' source data. 
#' 
#' @examples
#' \dontrun{AnnualRegime(x = mybasinoutput)}

AnnualRegime <- function(x, ts.in = NULL, ts.out = NULL, start.mon = 1, incl.leap = FALSE, na.rm = TRUE) {
  
  ## identify timestep of x and choose posix element for averaging
  # conditional: get timestep of x from attribute if argument ts.in is not provided, with error handling
  if (is.null(ts.in)) {
    ts.in <- attr(x, "timestep")
    if (is.null(ts.in)) {
      stop("No attribute 'timestep' found in 'x', and no argument 'timestep' provided.")
    }
  }
  # check if timestep is acceptable, abort otherwise
  if (!(length(grep("hour", ts.in)) == 1 | ts.in == "day" | ts.in == "week" | ts.in == "month")) {
    stop(paste("Timestep '", ts.in, "' not accepted.", sep = ""))
  }
  
  # weekly data will be expanded to daily data for calculations and later re-collapsed, HYPE writes weekly values to 
  # last day of the week
  if (ts.in == "week") {
    # create daily date vector over time period
    days <- data.frame(DATE = seq(x[1, 1], x[nrow(x), 1], by = "day"))
    x <- merge(days, x, by = 1, all.x = T)
    # use internal function to fill NAs fith next available value, apply to all columns
    x <- data.frame(DATE = x[, 1], apply(x[, -1], 2, .FillWeek))
    tformat <- format(x[, 1], format = "%j")
  }
  
  # assign and check output timestep
  if (is.null(ts.out)) {
    ts.out <- ts.in
  } else {
    if (ts.out != ts.in) {
      if ((ts.in == "month" & ts.out != "month") | 
          (ts.in == "week" & !(ts.out %in% c("week", "month"))) | 
          (ts.in == "day" & !(ts.out %in% c("day", "week", "month")))) {
        stop("Output timestep cannot be shorter than input timestep.")
      }
    }
  }
  
  # format index vector for calculations below
  if (length(grep("hour", ts.out)) == 1) {
    tformat <- format(x[, 1], format = "%m-%d %H")
  } else if (ts.out == "day") {
    tformat <- format(x[, 1], format = "%m-%d")
  } else if (ts.out == "week") {
    tformat <- format(x[, 1], format = "%W")
  } else if (ts.out == "month") {
    tformat <- format(x[, 1], format = "%m")
  } else { # this should never occur, leave it just for safety...
    stop(paste("Timestep '", ts.out, "' not known.", sep = ""))
  }
  
  # calculate results
  res_ave <- aggregate(x[, -1], list(tformat), mean, na.rm = na.rm)
  res_min <- aggregate(x[, -1], list(tformat), min, na.rm = na.rm)
  res_max <- aggregate(x[, -1], list(tformat), max, na.rm = na.rm)
  res_25p <- aggregate(x[, -1], list(tformat), quantile, probs = 0.25, na.rm = na.rm)
  res_75p <- aggregate(x[, -1], list(tformat), quantile, probs = 0.75, na.rm = na.rm)
  
  # prettify header
  names(res_ave)[1] <- ts.out
  names(res_min)[1] <- ts.out
  names(res_max)[1] <- ts.out
  names(res_25p)[1] <- ts.out
  names(res_75p)[1] <- ts.out
  
  # remove leap day from daily results
  if (ts.out == "day" & !incl.leap) {
    res_ave <- res_ave[-60, ]
    res_min <- res_min[-60, ]
    res_max <- res_max[-60, ]
    res_25p <- res_25p[-60, ]
    res_75p <- res_75p[-60, ]
  }
  
  # order results according to a user-requested starting month to reflect the hydrological year rather than the calender year
  if (start.mon != 1) {
    
    # catch user input errors
    if (start.mon > 12 || start.mon < 1) {
      stop("start.mon not valid.")
    }
    
    # create date string of first day in the hydrological year
    if (length(grep("hour", ts.out)) == 1) {
      sm <- paste(formatC(start.mon, width=2, flag = "0"), "-01 00", sep = "")
    } else if (ts.out == "day") {
      sm <- paste(formatC(start.mon, width=2, flag = "0"), "-01", sep = "")
    } else if (ts.out == "week") {
      # look-up table for starting weeks
      te <- data.frame(mon = 2:12, week = c(4,9,13,18,22,26,31,35,40,44,49))
      sm <- te[which(te[, 1] == start.mon), 2]
    } else if (ts.out == "month") {
      sm <- formatC(start.mon, width=2, flag = "0")
    }
    
    # find row index of start date string
    ind.sm <- which(res_ave[, 1] == sm)
    ind.nrow <- nrow(res_ave)
    
    # re-order all results
    res_ave <- res_ave[c(ind.sm:ind.nrow, 1:(ind.sm - 1)), ]
    res_min <- res_min[c(ind.sm:ind.nrow, 1:(ind.sm - 1)), ]
    res_max <- res_max[c(ind.sm:ind.nrow, 1:(ind.sm - 1)), ]
    res_25p <- res_25p[c(ind.sm:ind.nrow, 1:(ind.sm - 1)), ]
    res_75p <- res_75p[c(ind.sm:ind.nrow, 1:(ind.sm - 1)), ]
  }
  
  # combine to result list
  res <- list(mean = res_ave, minimum = res_min, maximum = res_max, p25 = res_25p, p75 = res_75p, period = as.POSIXct(c(x[1, 1], x[nrow(x), 1]), tz="GMT"))
  
  return(res)
}

## DEBUG
# x <- ReadBasinOutput("//winfs-proj/data/proj/Fouh/Sweden/S-HYPE/Projekt/cleo/WP_3/2014-04_SHYPE_combined_scenarios/hadley/BUS/period1/res_ts/0013478.txt")
# gd <- ReadGeoData("//winfs-proj/data/proj/Fouh/Sweden/S-HYPE/Projekt/cleo/WP_3/2014-04_SHYPE_combined_scenarios/hadley/BUS/period1/GeoData.txt")
# ts.in <- NULL
# ts.out <- NULL
# na.rm <- TRUE
# incl.leap <- F
# start.mon <- 10
# remove(.FillWeek); remove(list = ls())
# te <- AnnualRegime(x = x, ts.out = "month")