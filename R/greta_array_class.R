# define a greta_array S3 class for the objects users manipulate

# nolint start

# coerce to greta_array class if optional = TRUE don't error if we fail, just
# return original x, which we pass along explicitly
as.greta_array <- function(x, optional = FALSE, original_x = x, ...) {
  UseMethod("as.greta_array", x)
}

# safely handle self-coercion
#' @export
as.greta_array.greta_array <- function(x, optional = FALSE, original_x = x, ...) {
  x
}

# coerce logical vectors to numerics
#' @export
as.greta_array.logical <- function(x, optional = FALSE, original_x = x, ...) {
  x[] <- as.numeric(x[])
  as.greta_array.numeric(x,
    optional = optional,
    original_x = original_x,
    ...
  )
}

# coerce dataframes if all columns can safely be converted to numeric, error
# otherwise
#' @export
as.greta_array.data.frame <- function(x, optional = FALSE,
                                      original_x = x, ...) {
  classes <- vapply(x, class, "")
  valid <- classes %in% c("numeric", "integer", "logical")

  if (!optional & !all(valid)) {
    invalid_types <- unique(classes[!valid])
    msg <- cli::format_error(
      c(
        "{.cls greta_array} must contain the same type",
        "Cannot coerce a {.cls data.frame} to a {.cls greta_array} unless \\
        all columns are {.cls numeric, integer} or {.cls logical}. This \\
        dataframe had columns of type: {.cls {invalid_types}}"
      )
    )
    stop(
      msg,
      call. = FALSE
    )
  }

  as.greta_array.numeric(as.matrix(x),
    optional = optional,
    original_x = original_x,
    ...
  )
}

# coerce logical matrices to numeric matrices, and error if they aren't logical
# or numeric
#' @export
as.greta_array.matrix <- function(x, optional = FALSE, original_x = x, ...) {
  if (!is.numeric(x)) {
    if (is.logical(x)) {
      x[] <- as.numeric(x[])
    } else if (!optional) {
      msg <- cli::format_error(
        c(
          "{.cls greta_array} must contain the same type",
          "Cannot coerce {.cls matrix} to a {.cls greta_array} unless it is \\
          {.cls numeric}, {.cls integer} or {.cls logical}. This \\
          {.cls matrix} had type:",
          "{.cls {class(as.vector(x))}}"
        )
      )
      stop(
        msg,
        call. = FALSE
      )
    }
  }

  as.greta_array.numeric(x,
    optional = optional,
    original_x = original_x,
    ...
  )
}

# coerce logical arrays to numeric arrays, and error if they aren't logical
# or numeric
#' @export
as.greta_array.array <- function(x, optional = FALSE, original_x = x, ...) {
  if (!optional & !is.numeric(x)) {
    if (is.logical(x)) {
      x[] <- as.numeric(x[])
    } else {
      msg <- cli::format_error(
        c(
          "{.cls greta_array} must contain the same type",
          "Cannot coerce {.cls array} to a {.cls greta_array} unless it is \\
          {.cls numeric}, {.cls integer} or {.cls logical}. This {.cls array} \\
          had type:",
          "{.cls {class(as.vector(x))}}"
        )
      )
      stop(
        msg,
        call. = FALSE
      )
    }
  }

  as.greta_array.numeric(x,
    optional = optional,
    original_x = original_x,
    ...
  )
}

# finally, reject if there are any missing values, or set up the greta_array
#' @export
as.greta_array.numeric <- function(x, optional = FALSE, original_x = x, ...) {
  if (!optional & any(!is.finite(x))) {
    msg <- cli::format_error(
      c(
        "{.cls greta_array} must not contain missing or infinite values"
      )
    )
    stop(
      msg,
      call. = FALSE
    )
  }
  as.greta_array.node(data_node$new(x),
    optional = optional,
    original_x = original_x,
    ...
  )
}

# node method (only one that does anything)
#' @export
as.greta_array.node <- function(x, optional = FALSE, original_x = x, ...) {
  ga <- x$value()
  attr(ga, "node") <- x
  class(ga) <- c("greta_array", "array")
  ga
}

# otherwise error
#' @export
as.greta_array.default <- function(x, optional = FALSE, original_x = x, ...) {
  if (!optional) {
    msg <- cli::format_error(
      c(
        "Object cannot be coerced to {.cls greta_array}",
        "Objects of class {.cls {paste(class(x), collapse = ' or ')}} cannot \\
        be coerced to a {.cls greta_array}"
      )
    )
    stop(
      msg,
      call. = FALSE
    )
  }

  # return x before we started messing with it
  original_x
}

# print method
#' @export
print.greta_array <- function(x, ...) {
  node <- get_node(x)
  text <- glue::glue(
    "greta array ({node$description()})\n\n\n"
  )

  cat(text)
  print(node$value(), ...)
}

# summary method
#' @export
summary.greta_array <- function(object, ...) {
  node <- get_node(object)

  sry <- list(
    type = node_type(node),
    length = length(object),
    dim = dim(object),
    distribution_name = node$distribution$distribution_name,
    values = node$value()
  )

  class(sry) <- "summary.greta_array"
  sry
}

# summary print method
#' @export
#' @method print summary.greta_array
print.summary.greta_array <- function(x, ...) {

  # array type
  type_text <- glue::glue(
    "'{x$type}' greta array"
  )

  if (x$length == 1) {
    shape_text <- "with 1 element"
  } else {
    dim_text <- glue::glue_collapse(x$dim, sep = "x")
    shape_text <- glue::glue(
      "with {x$length} elements ({dim_text})"
    )
  }

  # distribution info
  if (!is.null(x$distribution_name)) {
    distribution_text <- glue::glue(
      "following a {x$distribution_name} distribution"
    )
  } else {
    distribution_text <- ""
  }

  if (inherits(x$values, "unknowns")) {
    values_text <- "\n  (values currently unknown)"
  } else {
    values_print <- capture.output(summary(x$values))
    values_text <- paste0("\n", paste(values_print, collapse = "\n"))
  }

  text <- glue::glue(
    "{type_text} {shape_text} {distribution_text} \n {values_text}"
  )
  cat(text)
  invisible(x)
}

# str method
#' @export
#' @importFrom utils str
str.greta_array <- function(object, ...) {
  value <- get_node(object)$value()
  array <- unclass(value)
  string <- capture.output(str(array))
  string <- gsub("NA", "?", string)
  string <- glue::glue("'greta_array' {string}")
  cat(string)
}

# return the unknowns array for this greta array
#' @export
as.matrix.greta_array <- function(x, ...) {
  get_node(x)$value()
}

# nolint end

# extract the node from a greta array
get_node <- function(x) {
  attr(x, "node")
}

# check for and get representations
representation <- function(x, name, error = TRUE) {
  if (inherits(x, "greta_array")) {
    x_node <- get_node(x)
  } else {
    x_node <- x
  }
  repr <- x_node$representations[[name]]
  if (error && is.null(repr)) {
    msg <- cli::format_error(
      "{.cls greta_array} has no representation {.var name}"
    )
    stop(
      msg,
      call. = FALSE
    )
  }
  repr
}

has_representation <- function(x, name) {
  repr <- representation(x, name, error = FALSE)
  !is.null(repr)
}

# helper function to make a copy of the greta array & tensor
copy_representation <- function(x, name) {
  repr <- representation(x, name)
  identity(repr)
}

greta_array_module <- module(as.greta_array,
  get_node,
  has_representation,
  representation,
  copy_representation,
  unknowns = unknowns_module
)
