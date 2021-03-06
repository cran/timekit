## ---- echo = FALSE, message = FALSE, warning = FALSE---------------------
knitr::opts_chunk$set(
    # message = FALSE,
    # warning = FALSE,
    fig.width = 8, 
    fig.height = 4.5,
    fig.align = 'center',
    out.width='95%', 
    dpi = 200
)
library(tidyquant)
library(timekit)
library(forecast)
# devtools::load_all() # Travis CI fails on load_all()

## ---- eval = F-----------------------------------------------------------
#  library(tidyquant)
#  library(timekit)

## ------------------------------------------------------------------------
ten_year_treasury_rate_tbl <- tq_get("DGS10", 
                                     get  = "economic.data", 
                                     from = "1997-01-01", 
                                     to   = "2016-12-31") %>%
    rename(pct = price) %>%
    mutate(pct = pct / 100)
ten_year_treasury_rate_tbl

## ---- message=F, warning=F-----------------------------------------------
ten_year_treasury_rate_tbl <- ten_year_treasury_rate_tbl %>%
    tq_transmute(pct, mutate_fun = to.period, period = "quarters")
ten_year_treasury_rate_tbl

## ------------------------------------------------------------------------
# date column gets coerced to numeric
ts(ten_year_treasury_rate_tbl, start = 1997, freq = 4) %>%
    head()

## ------------------------------------------------------------------------
ten_year_treasury_rate_ts_stats <- ts(ten_year_treasury_rate_tbl[,"pct"], 
                                      start = 1997, 
                                      freq  = 4)
ten_year_treasury_rate_ts_stats

## ------------------------------------------------------------------------
# No date index attribute
str(ten_year_treasury_rate_ts_stats)

## ------------------------------------------------------------------------
# Regularized numeric sequence
index(ten_year_treasury_rate_ts_stats)

## ------------------------------------------------------------------------
# date automatically dropped and user is warned
ten_year_treasury_rate_ts_timekit <- tk_ts(ten_year_treasury_rate_tbl, 
                                         start = 1997, 
                                         freq  = 4)
ten_year_treasury_rate_ts_timekit

## ------------------------------------------------------------------------
# More attributes including time index, time class, time zone
str(ten_year_treasury_rate_ts_timekit)

## ------------------------------------------------------------------------
# Can now retrieve the original date index
timekit_index <- tk_index(ten_year_treasury_rate_ts_timekit, timekit_idx = TRUE)
head(timekit_index)
class(timekit_index)

## ------------------------------------------------------------------------
# Coercion back to tibble using the default index (regularized)
ten_year_treasury_rate_ts_timekit %>%
    tk_tbl(index_rename = "date", timekit_idx = FALSE)

## ------------------------------------------------------------------------
# Coercion back to tibble now using the timekit index (date / date-time)
ten_year_treasury_rate_tbl_timekit <- ten_year_treasury_rate_ts_timekit %>%
    tk_tbl(index_rename = "date", timekit_idx = TRUE)
ten_year_treasury_rate_tbl_timekit

## ------------------------------------------------------------------------
# Comparing the coerced tibble with the original tibble
identical(ten_year_treasury_rate_tbl_timekit, ten_year_treasury_rate_tbl)

## ------------------------------------------------------------------------
# Start:
ten_year_treasury_rate_tbl

## ------------------------------------------------------------------------
# End
ten_year_treasury_rate_xts <- tk_xts(ten_year_treasury_rate_tbl) 
head(ten_year_treasury_rate_xts)

## ------------------------------------------------------------------------
# End - Using `select` and `date_var` args
tk_xts(ten_year_treasury_rate_tbl, select = -date, date_var = date) %>%
    head()

## ------------------------------------------------------------------------
# End - Using `silent` to silence warnings
tk_xts(ten_year_treasury_rate_tbl, silent = TRUE) %>%
    head()

## ------------------------------------------------------------------------
# End
ten_year_treasury_rate_zoo <- tk_zoo(ten_year_treasury_rate_tbl, silent = TRUE) 
head(ten_year_treasury_rate_zoo)

## ------------------------------------------------------------------------
# End
ten_year_treasury_rate_zooreg <- tk_zooreg(ten_year_treasury_rate_tbl, 
                                           start  = 1997, 
                                           freq   = 4,
                                           silent = TRUE) 
head(ten_year_treasury_rate_zooreg)

## ------------------------------------------------------------------------
# Retrieve original time-based index
tk_index(ten_year_treasury_rate_zooreg, timekit_idx = TRUE) %>%
    str()

## ------------------------------------------------------------------------
# End
ten_year_treasury_rate_ts <- tk_ts(ten_year_treasury_rate_tbl, 
                                   start  = 1997, 
                                   freq   = 4,
                                   silent = TRUE) 
ten_year_treasury_rate_ts

## ------------------------------------------------------------------------
# Retrieve original time-based index
tk_index(ten_year_treasury_rate_ts, timekit_idx = TRUE) %>%
    str()

## ------------------------------------------------------------------------
# Start
head(ten_year_treasury_rate_xts)

## ------------------------------------------------------------------------
# End
tk_tbl(ten_year_treasury_rate_xts)

## ------------------------------------------------------------------------
# Start
head(ten_year_treasury_rate_zoo)

## ------------------------------------------------------------------------
# End
tk_tbl(ten_year_treasury_rate_zoo)

## ------------------------------------------------------------------------
# Start
head(ten_year_treasury_rate_zooreg)

## ------------------------------------------------------------------------
# End - with default regularized index
tk_tbl(ten_year_treasury_rate_zooreg)

## ------------------------------------------------------------------------
# End - with timekit index that is the same as original time-based index
tk_tbl(ten_year_treasury_rate_zooreg, timekit_idx = TRUE)

## ------------------------------------------------------------------------
# Start
ten_year_treasury_rate_ts

## ------------------------------------------------------------------------
# End - with default regularized index
tk_tbl(ten_year_treasury_rate_ts)

## ------------------------------------------------------------------------
# End - with timekit index 
tk_tbl(ten_year_treasury_rate_ts, timekit_idx = TRUE)

## ------------------------------------------------------------------------
# Data coerced with stats::ts() has no timekit index
has_timekit_idx(ten_year_treasury_rate_ts_stats)

## ------------------------------------------------------------------------
tk_index(ten_year_treasury_rate_ts_stats, timekit_idx = TRUE)

## ------------------------------------------------------------------------
tk_tbl(ten_year_treasury_rate_ts_stats, timekit_idx = TRUE)

## ------------------------------------------------------------------------
# Data coerced with tk_ts() has timekit index
has_timekit_idx(ten_year_treasury_rate_ts_timekit)

## ------------------------------------------------------------------------
tk_index(ten_year_treasury_rate_ts_timekit, timekit_idx = TRUE)

## ------------------------------------------------------------------------
tk_tbl(ten_year_treasury_rate_ts_timekit, timekit_idx = TRUE)

## ------------------------------------------------------------------------
has_timekit_idx(ten_year_treasury_rate_xts)

## ------------------------------------------------------------------------
tk_index(ten_year_treasury_rate_xts, timekit_idx = TRUE)

## ------------------------------------------------------------------------
tk_index(ten_year_treasury_rate_xts, timekit_idx = FALSE)

## ------------------------------------------------------------------------
# Start with a date or date-time indexed data frame
data_tbl <- tibble::tibble(
    date = seq.Date(as.Date("2016-01-01"), by = 1, length.out = 5),
    x    = cumsum(11:15) * rnorm(1))
data_tbl

## ------------------------------------------------------------------------
# Coerce to ts 
data_ts <- tk_ts(data_tbl, start = 2016, freq = 365, silent = TRUE)
data_ts

## ------------------------------------------------------------------------
# Inspect timekit index
has_timekit_idx(data_ts)

## ------------------------------------------------------------------------
# No need to specify order.by arg
data_xts <- tk_xts(data_ts)
data_xts

## ------------------------------------------------------------------------
str(data_xts)

## ------------------------------------------------------------------------
# No need to specify order.by arg
data_zoo <- tk_zoo(data_ts)
data_zoo

## ------------------------------------------------------------------------
str(data_zoo)

## ------------------------------------------------------------------------
tk_tbl(data_ts, timekit_idx = TRUE)

## ------------------------------------------------------------------------
yearqtr_tbl <- ten_year_treasury_rate_tbl %>%
    mutate(date = as.yearqtr(date))
yearqtr_tbl

## ------------------------------------------------------------------------
yearqtr_xts <- tk_xts(yearqtr_tbl)
yearqtr_xts %>%
    head()

## ------------------------------------------------------------------------
yearqtr_ts <- tk_ts(yearqtr_xts, start = 1997, freq = 4)
yearqtr_ts %>%
    head()

## ------------------------------------------------------------------------
yearqtr_ts %>%
    tk_tbl(timekit_idx = TRUE)

## ------------------------------------------------------------------------
library(forecast)
fit_arima <- ten_year_treasury_rate_ts %>%
    auto.arima()

## ------------------------------------------------------------------------
tk_index(fit_arima)

## ------------------------------------------------------------------------
tk_index(fit_arima, timekit_idx = TRUE)

