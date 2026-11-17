# linear interpolation
# ====================
setwd("/Users/zhengp/Documents/teaching/HMS520/Autumn2026/HMS520-Autumn2026/demo/Module05")
source("functions.R")

# load data ---------------------------------------------------------------
dt_iris <- fread("iris.csv")

# plot data ---------------------------------------------------------------
# use plot_data from functions.R (what does shape 14 mark?)
plot_data(dt_iris)

# build model -------------------------------------------------------------
# approxfun needs unique x values: aggregate the TRAINING rows,
# mean Sepal.Width by Sepal.Length
dt_train <- dt_iris[test == 0, list(Sepal.Width = mean(Sepal.Width)), by = Sepal.Length]
ggplot(dt_train) + geom_point(mapping = aes(x = Sepal.Length, y = Sepal.Width))

# create the interpolation function with approxfun
# (what does rule = 2 do outside the data range?)
fun <- with(dt_train, approxfun(x = Sepal.Length, y = Sepal.Width, rule = 2))

# predict: add the column sepal_width_fit with the function
dt_iris[, sepal_width_fit := fun(Sepal.Length)]

# plot fit ----------------------------------------------------------------
# plot_fit, and overlay the aggregated training points (shape = 12)
plot_fit(dt_iris) +
  geom_point(data = dt_train, mapping = aes(x = Sepal.Length, y = Sepal.Width))

# summarize fit -----------------------------------------------------------
# get_performance: compare in-sample and out-of-sample rmse
performance <- get_performance(dt_iris)
