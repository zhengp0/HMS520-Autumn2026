# create a data frame
df <- data.frame(a = 1:3, b = c("a", "b", "c"))

# peek into a data frame
str(df)
View(df)

# dimensions: number of rows and columns
dim(df)

# access column(s) in a data frame
df[, "a"]
df$a
df[["a"]]

# access row(s) in a data frame
df[c(1, 2), ]

# assign values for the data frame
df[1, ] <- 3

# append a row to a data frame
df_new <- data.frame(a = 4, b = "d")
df <- rbind(df, df_new)

df[nrow(df) + 1, ] <- list(a = 5, b = "e")

# how to remove a column or row?
df$b <- NULL
df[, -c(2)]
df[-c(1, 2), ]
