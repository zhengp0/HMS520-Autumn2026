# for loop
vec <- c("a", "b", "c")
# loop over the elements of a vector
for (x in vec) {
  print(x)
}

# loop over the indices of a vector
for (i in seq_along(vec)) {
  print(vec[i])
}

# use a for loop to sum all numbers from 1 to 20 that are divisible by 3
s <- 0
for (x in 1:20) {
  if (x %% 3 == 0) {
    print(x)
    s <- s + x
  }
}
print(s)

# do the same computation without a loop (logical filter + sum)
vec <- 1:20
sum(vec[vec %% 3 == 0])

# use next to skip the odd numbers and break to exit the loop early
vec <- 1:100

for (x in vec) {
  if (x %% 2 == 1) {
    next
  }
  if (x > 5) {
    break
  }
  print(x)
}

# do the same computation with a while loop
i <- 1
x <- vec[i]
while (x <= 5) {
  if (x %% 2 == 1) {
    i <- i + 1
    x <- vec[i]
    next
  }
  print(x)
  i <- i + 1
  x <- vec[i]
}

# do the same computation with a repeat loop
i <- 1
repeat {
  x <- vec[i]
  if (x > 5) {
    break
  }
  if (x %% 2 == 0) {
    print(x)
  }
  i <- i + 1
}
