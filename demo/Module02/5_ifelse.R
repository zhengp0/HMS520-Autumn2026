# if, if else, if else if else

# create a vector that contains some NAs
vec <- 1:4
vec <- c(vec, rep(NA, 3))

# if the vector contains any NA, stop with an error,
# otherwise print "everything is ok"
if (any(is.na(vec))) {
  stop("NA detected, please check!")
} else {
  print("Everything is ok")
}

# use switch to map a status code ("S", "R", or "D") to a description,
# stop with an error when there is no match
status <- "R"
switch(status,
  "S" = "susceptible",
  "R" = "recovered",
  "D" = "deceased",
  stop("unrecognized status")
)
