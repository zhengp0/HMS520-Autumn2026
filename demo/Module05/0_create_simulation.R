# create the train/test split used in the demos
# ==============================================
library("data.table")

seed <- 123L
set.seed(seed)

dt_iris <- setDT(copy(iris))

# mark 10% of the rows as test data:
# - sample the row indices (sample.int)
# - add a test column: 0 for training rows, 1 for test rows

n <- nrow(dt_iris)
n_test <- as.integer(0.1 * n)
i_test <- sample.int(n, size=n_test)
dt_iris[, test := 0]
dt_iris[i_test, test := 1]

# save as "iris.csv" (fwrite)
setwd("/Users/zhengp/Documents/teaching/HMS520/Autumn2026/HMS520-Autumn2026/demo/Module05")
fwrite(dt_iris, "iris.csv")
