# please provide three ways to create a vector containing 1, 2, ..., 10
vec1 <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
vec1 <- 1:10
vec1 <- seq(1, 10)

# please select the first and third elements
vec1[c(1, 3)]

# please access the values that are greater than 5
vec1 > 5
vec1[vec1 > 5]

# please assign all even numbers to 0
vec1 %% 2 == 0
vec1[vec1 %% 2 == 0] <- 0

# remove the 2nd and 5th elements
vec1[-c(2, 5)]

# how to combine two vectors?
vec2 <- c(11, 12)
vec3 <- c(vec1, vec2)

# create a named atomic vector
vec4 <- c(x = 1, y = 2, z = 3)
vec4[c("x", "y")]

# how to get the number of characters of a string?
vec5 <- c("xyz", "abc", "12")
length(vec5)
nchar(vec5)

# quiz
grades <- c("A", "B", "A", "C", "A")
length(unique(grades))
table(grades)

n_sim <- 5

vec6 <- 0:10 / 10
vec6 <- seq(0, 1, by = 0.1)
vec6 <- seq(0, 1, length.out = 11)
vec6

x <- 1L
typeof(x)
class(x)
is.double(x)
