# Problem 1 --------------------------------------------------------------------
# Create a function called `is_string` that takes in a variable and returns
# `TRUE` if the variable is a string. We say a variable is a string if it is a
# character vector with length 1. Here is the function's signature.
# * Arguments
#   * `x`: Given variable.
# * Returns
#   * Returns `TRUE` if `x` is a string and `FALSE` otherwise.

is_string <- function(x) {
  is.character(x) & (length(x) == 1)
}

# Problem 2 --------------------------------------------------------------------
# Create a function called `my_cumsum` that mimics the functionality of `cumsum`
# in base R using a **for-loop**. For example, if our input is `c(1, 2, 3)`, we
# expect the output to be `c(1, 3, 6)`. Here is the signature of the `my_cumsum`
# function.
# * Arguments
#   * `x`: A numeric vector.
# * Exceptions
#   * Throw an error if the vector is not a numeric vector. The error message
#     should be `x must be a numeric vector`. (Use the `stop` function)
# * Returns
#   * Returns the cumulative sum of the vector.

my_cumsum <- function(x) {
  if (!is.numeric(x)) stop("x must be a numeric vector")
  y <- as.vector(x)
  for (i in seq_along(y)) {
    if (i == 1) {
      y[1] <- x[1]
    } else {
      y[i] <- y[i] + y[i - 1]
    }
  }
  y
}

# Problem 3 --------------------------------------------------------------------
# Create a function called `rmse` that will return the root mean square error of
# a given numeric vector.
#
# For example, if our input is `c(1, 2, 3)`, the expected output is
# `sqrt((1^2 + 2^2 + 3^2)/3)`. Here is the signature of the `rmse` function.
# * Arguments
#   * `x`: A numeric vector.
#   * `na_rm`: A boolean variable; if `TRUE`, ignore the `NA` values in `x`.
#     Optional, defaults to `TRUE`.
# * Exceptions
#   * Throw an error if the vector is not a numeric vector. The error message
#     should be `x must be a numeric vector`.
# * Returns
#   * Returns the root mean square error as a scalar value.

rmse <- function(x, na_rm = TRUE) {
  if (!is.numeric(x)) stop("x must be a numeric vector")
  if (na_rm) x <- x[!is.na(x)]

  sqrt(mean(x^2))
}

# Problem 4 --------------------------------------------------------------------
# Create a function called `describe_difference` that takes in two strings and
# compares their lengths. Here is the signature.
# * Arguments
#   * `x`: Your first string.
#   * `y`: Your second string.
# * Exceptions
#   * Throw an error if `x` or `y` is not a string. The error messages should be
#     `x must be a string` or `y must be a string`.
# * Returns
#   * **Silently** returns the length difference between the first and second
#     string (with sign, length of `x` minus length of `y`), check `invisible()`.
#   * If the first string is longer, print
#     `Your first string is longer by N characters`
#   * If the second string is longer, print
#     `Your second string is longer by N characters`
#   * If they have the same length, print
#     `Your strings are the same length`
#   * Here `N` should be replaced by the absolute value of the length difference

describe_difference <- function(x, y) {
  if (!is_string(x)) stop("x must be a string")
  if (!is_string(y)) stop("y must be a string")

  n_x <- nchar(x)
  n_y <- nchar(y)
  diff <- n_x - n_y

  if (diff > 0) {
    print(paste("Your first string is longer by", diff, "characters"))
  } else if (diff < 0) {
    print(paste("Your second string is longer by", -diff, "characters"))
  } else {
    print("Your strings are the same length")
  }

  invisible(diff)
}
