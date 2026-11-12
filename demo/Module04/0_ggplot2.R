# ggplot2 examples
# ================
# install.packages("ggplot2")
library("data.table")
library("ggplot2")

# we use the built-in iris data in this demo


# 1. scatter plot -----------------------------------------------------------
# Sepal.Length (x) vs Sepal.Width (y), colored by Species: geom_point
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()


# 2. bar plot ----------------------------------------------------------------
# count the rows for each Species: geom_bar
ggplot(iris, aes(x = Species, fill = Species)) +
  geom_bar()

# plot a value column directly: geom_col
ggplot(iris, aes(x = Species, y = Sepal.Length, fill = Species)) +
  geom_col()

# 3. box plot ----------------------------------------------------------------
# variation of Sepal.Length across Species: geom_boxplot (try fill)
ggplot(iris, aes(x = Species, y = Sepal.Length)) +
  geom_boxplot()

# 4. line plot ---------------------------------------------------------------
# fit Sepal.Width ~ Sepal.Length with lm (check summary)
mod <- lm(Sepal.Width ~ Sepal.Length, iris)
summary(mod)

# convert iris to a data.table (remember copy!) and
# add the prediction as a column with :=
dt_iris <- setDT(copy(iris))
dt_iris[, pred_sepal_width := predict(mod, dt_iris)]

# plot the points and the fitted line on top
ggplot(dt_iris, aes(x = Sepal.Length)) +
  geom_point(aes(y = Sepal.Width, color = Species)) +
  geom_line(aes(y = pred_sepal_width))


# 5. line with uncertainty -----------------------------------------------------
# get the confidence interval: predict(..., interval = "confidence")
# rename lwr/upr and cbind them to the data.table
pred_with_uncertainty <- predict(mod, iris, interval = "confidence")
uncertainty <- pred_with_uncertainty[, c("lwr", "upr")]
colnames(uncertainty) <- c("pred_sepal_width_lwr", "pred_sepal_width_upr")
dt_iris <- cbind(dt_iris, uncertainty)

# add geom_ribbon with ymin/ymax (try alpha)
ggplot(dt_iris, aes(x = Sepal.Length)) +
  geom_point(aes(y = Sepal.Width, color = Species)) +
  geom_line(aes(y = pred_sepal_width)) +
  geom_ribbon(aes(ymin = pred_sepal_width_lwr, ymax = pred_sepal_width_upr), alpha = 0.5)

