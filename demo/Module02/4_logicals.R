# logical values and their type
TRUE
typeof(TRUE)
FALSE
typeof(FALSE)

# and, or, not
TRUE & TRUE
TRUE & FALSE
FALSE & FALSE

TRUE | TRUE
TRUE | FALSE
FALSE | FALSE

!TRUE
!FALSE

# check if all elements of a vector are strictly greater than 1
vec <- c(0, 0, 0, 1, 1, 1, 2, 2, 2)
all(vec > 1)

# check if any element of a vector is negative
vec <- c(-2, -1, 0, 1, 2)
any(vec < 0)