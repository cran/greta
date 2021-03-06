% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_replace_combine.R
\name{extract-replace-combine}
\alias{extract-replace-combine}
\alias{extract}
\alias{replace}
\alias{cbind}
\alias{rbind}
\alias{c}
\alias{rep}
\title{extract, replace and combine greta arrays}
\arguments{
\item{x}{a greta array}

\item{i, j}{indices specifying elements to extract or replace}

\item{n}{a single integer, as in \code{utils::head()} and
\code{utils::tail()}}

\item{nrow, ncol}{optional dimensions for the resulting greta array when x is
not a matrix.}

\item{value}{for \code{`[<-`} a greta array to replace elements, for
\code{`dim<-`} either NULL or a numeric vector of dimensions}

\item{...}{either further indices specifying elements to extract or replace
(\code{[}), or multiple greta arrays to combine (\code{cbind()},
\code{rbind()} & \code{c()}), or additional arguments (\code{rep()},
\code{head()}, \code{tail()})}

\item{drop, recursive}{generic arguments that are ignored for greta arrays}
}
\description{
Generic methods to extract and replace elements of greta arrays,
  or to combine greta arrays.
}
\details{
\code{diag()} can be used to extract or replace the diagonal part of
  a square and two-dimensional greta array, but it cannot be used to create a
  matrix-like greta array from a scalar or vector-like greta array. A static
  diagonal matrix can always be created with e.g. \code{diag(3)}, and then
  converted into a greta array.
}
\section{Usage}{
 \preformatted{
# extract
x[i]
x[i, j, ..., drop = FALSE]
head(x, n = 6L, ...)
tail(x, n = 6L, ...)
diag(x, nrow, ncol)

# replace
x[i] <- value
x[i, j, ...] <- value
diag(x) <- value

# combine
cbind(...)
rbind(...)
abind(...)
c(..., recursive = FALSE)
rep(x, times, ..., recursive = FALSE)

# get and set dimensions
length(x)
dim(x)
dim(x) <- value
}
}

\examples{
\dontrun{

 x <- as_data(matrix(1:12, 3, 4))

 # extract and replace
 x[1:3, ]
 x[, 2:4] <- 1:9
 e <- diag(x)
 diag(x) <- e + 1

 # combine
 cbind(x[, 2], x[, 1])
 rbind(x[1, ], x[3, ])
 abind(x[1, ], x[3, ], along = 1)
 c(x[, 1], x)
 rep(x[, 2], times = 3)
}
}
