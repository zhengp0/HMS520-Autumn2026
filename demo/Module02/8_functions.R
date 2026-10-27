# call a function with arguments by position and by name
seq(0, 5)
seq(from = 0, to = 5)

# call a function with a list of arguments (do.call)
args <- list(from = 0, to = 5)
do.call(seq, args)

# an operator is also a function
1 + 2
`+`(1, 2)

# define a function that adds 2 to its input
add_2 <- function(x) {
  x + 2
}

# improve the function: stop with an error when the input is not numeric
add_2 <- function(x) {
  if (!is.numeric(x)) {
    stop(paste0("Please provide a numeric value, the current argument type is ", typeof(x)))
  }
  x + 2
}

# default arguments and lazy evaluation: b can depend on a
my_mul <- function(a = 1, b = a * 3) {
  a * b
}

my_mul()
my_mul(b = 6)
my_mul(a = 3)

# use missing() to handle an absent argument (early return with return())
add_2 <- function(x) {
  if (missing(x)) {
    print("x is missing, we treat x = 0")
    return(2)
  }
  if (!is.numeric(x)) {
    stop(paste0("Please provide a numeric value, the current argument type is ", typeof(x)))
  }
  x + 2
}

plot_x_y <- function(x, y) {
  if (missing(x) & !missing(y)) {
    x <- seq_along(y)
  }
  if (missing(y)) {
    y <- x
    x <- seq_along(y)
  }
  plot(x, y)
}

plot_x_y(y = c(1, 5, 2, 4))
plot_x_y(c(1, 5, 2, 4))

# ellipsis (...): capture the extra arguments into a list
extra_to_list <- function(a = 1, b = 2, ...) {
  print(paste0("a = ", a))
  print(paste0("b = ", b))
  list(...)
}
extra_to_list(c = 5, d = 6)

# write file_path(..., fsep = "/") that combines all its arguments
# into a single file path

file_path <- function(..., fsep = .Platform$file.sep) {
  paste0(fsep, paste(..., sep = fsep))
}

file_path("mnt", "my", "disk")


# hide the output of a function with invisible()
extra_to_list <- function(a = 1, b = 2, ...) {
  print(paste0("a = ", a))
  print(paste0("b = ", b))
  invisible(list(...))
}
extra_list <- extra_to_list(c = 5, d = 6)
