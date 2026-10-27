# apply: compute the row sums and the column sums of a matrix
mat <- matrix(1:12, ncol = 4)
apply(mat, MARGIN = 1, FUN = sum)
apply(mat, MARGIN = 2, FUN = sum)

# sapply: get the length of each element of a list
john <- list(
  name = "John",
  phone_number = 1:3,
  email = "john@uw.edu",
  address = list(
    city = "Seattle",
    state = "WA"
  )
)
sapply(john, length)

# lapply: compute the mean of each column of a data frame
df <- data.frame(a = 1:5, b = 6:10)
lapply(df, mean)

# what is the difference between lapply and sapply on a data frame?
# lapply returns a list, sapply simplifies the result to a vector
sapply(df, mean)

# mapply: compute sqrt(x^2 + y^2) for pairs of values from two vectors
x <- 1:10
y <- 1:10
mapply(function(x, y) sqrt(x^2 + y^2), x, y)
