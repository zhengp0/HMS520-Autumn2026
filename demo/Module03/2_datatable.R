# data.table exercise
# ===================
# install.packages("data.table")
setwd("~/Documents/teaching/HMS520/Autumn2026/HMS520-Autumn2026/demo/Module03/")
library("data.table")

df_population <- fread("population.csv")
df_deaths <- fread("deaths.csv")
df_hours <- fread("hours.csv")
df_pay <- fread("pay.csv")

# 1. subset ---------------------------------------------------------------
# subset rows: i expression
# - rows with location_id equal to 1
df_deaths_sub <- df_deaths[location_id == 1]
# - rows with deaths greater than 100
df_deaths_sub <- df_deaths[deaths > 100]
# - rows that satisfy both conditions
df_deaths_sub <- df_deaths[(location_id == 1) & (deaths > 100)]

# how to filter out all rows with NAs: complete.cases
df_deaths_sub <- df_deaths[complete.cases(sex_id, location_id, age_group_id)]

# subset cols: j expression
# - a vector of column names
col_names <- names(df_deaths)
df_deaths_sub <- df_deaths[, c("location_id", "age_group_id")]
# - a list of column "variables" (list or .())
df_deaths_sub <- df_deaths[, list(location_id, age_group_id)]
df_deaths_sub <- df_deaths[, .(location_id, age_group_id)]
# - a variable holding the column names (with = FALSE, or ..)
col_names <- c("location_id", "age_group_id")
df_deaths_sub <- df_deaths[, col_names, with = FALSE]
df_deaths_sub <- df_deaths[, ..col_names]
# - .SD + .SDcols
df_deaths_sub <- df_deaths[, .SD, .SDcols = col_names]

# 2. modify ---------------------------------------------------------------
# order rows: order() inside the i expression (- for descending)
df_deaths_ordered <- df_deaths[order(-deaths)]

# rename columns: j expression, setnames (in place!)
df_deaths_renamed <- df_deaths[, .(age = age_group_id)]
df_deaths_renamed <- copy(df_deaths)
setnames(df_deaths_renamed, c("age_group_id"), c("age"))

# 3. add ------------------------------------------------------------------
# add columns: j expression with := (remember copy() first if you
# do not want to change the original)
df_deaths_added <- copy(df_deaths)
df_deaths_added[, deaths2 := deaths^2]

# combine data tables: rbind, cbind


# 4. join -----------------------------------------------------------------
# merge deaths and population (which join is merge by default?)
df_combined <- merge(
  df_deaths,
  df_population,
  by = c("location_id", "age_group_id", "sex_id")
)
df_combined[, mortality_rate := deaths / population]

# what if there are columns with the same name: suffixes
df_deaths_second <- copy(df_deaths)
df_combined <- merge(
  df_deaths,
  df_deaths_second,
  by = c("location_id", "age_group_id", "sex_id"),
  suffixes = c("", "_second")
)

# what if the number of rows are different: all.x, all.y, all
df_deaths_extra <- data.table(
  location_id = 6,
  age_group_id = 1,
  sex_id = 1,
  deaths = 5
)
df_deaths_added <- rbind(df_deaths, df_deaths_extra)

df_combined <- merge(
  df_deaths_added,
  df_population,
  by = c("location_id", "age_group_id", "sex_id"),
  all = TRUE
)

# what if there are multiple matches?
df_1 = data.table(
  index = c(1, 1, 2, 2),
  value = c(1, 2, 3, 4)
)

df_2 = data.table(
  index = c(1, 1, 2),
  meta_info = c("a", "b", "c")
)

df_combined <- merge(
  df_1, df_2, by = "index"
)

# what if the names you try to match are different: by.x, by.y
df_1 = data.table(
  index_1 = c(1, 1, 2, 2),
  value = c(1, 2, 3, 4)
)

df_2 = data.table(
  index_2 = c(1, 2),
  meta_info = c("a", "c")
)

df_combined <- merge(
  df_1, df_2, by.x = "index_1", by.y = "index_2"
)

# 5. group and summarize ---------------------------------------------------
# sum deaths by location_id, then by location_id and age_group_id
df_group <- df_deaths[, list(deaths_sum = sum(deaths)), by = c("location_id", "age_group_id")]

# sum several columns at once with lapply(.SD, ...) and .SDcols
df_combined <- merge(
  df_deaths, df_population, by = c("location_id", "age_group_id", "sex_id")
)
df_group <- df_combined[, lapply(.SD, sum), by = "location_id"]


# 6. chaining ---------------------------------------------------------------
# filter location 1 and add log_deaths by chaining [][]

# compute the average death rate for locations 1, 2, 3, 4 and
# rank the data table by descending order of the death rate


# 7. pivot ----------------------------------------------------------------
# melt df_hours longer: one row per project and employee
df_hours_long <- melt(
  df_hours,
  id.vars = "project",
  measure.vars = c("A", "B", "C", "D"),
  variable.name = "employee",
  value.name = "hours"
)

# compute how much we pay each employee
# (merge df_pay, add pay with :=, summarize by employee)
df_combined <- merge(
  df_hours_long,
  df_pay,
  all = TRUE
)
df_combined[, pay := hours * dollar_per_hour]
df_pay_employee <- df_combined[, .(employee_pay = sum(pay)), by = "project"]

# dcast wider back: one column per employee
df_hours_orig <- dcast(
  df_hours_long,
  project ~ employee,
  value.var = "hours"
)

# which religion earns the most? (tidyr::relig_income)
install.packages("tidyr")
library("tidyr")

View(relig_income)
class(relig_income)
dt_relig_income <- as.data.table(relig_income)

valid_income_cols <- names(dt_relig_income)
valid_income_cols <- valid_income_cols[!(valid_income_cols %in% c("religion", "Don't know/refused"))]

dt_long <- melt(
  dt_relig_income,
  id.vars = "religion",
  measure.vars = valid_income_cols,
  variable.name = "income",
  value.name = "count"
)

dt_long[, total_count := sum(count), by = "religion"]
dt_long[, prop := count / total_count]

dt_wide <- dcast(
  dt_long,
  religion ~ income,
  value.var = "prop"
)

View(dt_wide[order(-`>150k`)])
