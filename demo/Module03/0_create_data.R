# create the datasets that will be used in the demo
# ==================================================

# set random seed
set.seed(0L)

# create characteristics for the data
keys <- list(
    location_id = 1:5,
    age_group_id = 1:5,
    sex_id = 1:2
)

# create a cartesian grid using the keys
# ?expand.grid
dat <- do.call(expand.grid, keys)

# simulate population and number of deaths
population <- rpois(nrow(dat), 1000L)
prob <- 0.1
deaths <- rbinom(nrow(dat), population, prob)

# create population and deaths data frames
df_population <- cbind(dat, population)
df_deaths <- cbind(dat, deaths)

# create work hours and pay rate tables
project <- 1:5

df_hours <- data.frame(
  project = project,
  A = rpois(length(project), 5),
  B = rpois(length(project), 5),
  C = rpois(length(project), 6),
  D = rpois(length(project), 10)
)

df_pay <- data.frame(
  project = project,
  dollar_per_hour = rpois(length(project), 40)
)

# save the data frames as csv files (write.csv)
write_csv <- function(..., row.names = FALSE) {
  write.csv(..., row.names = row.names)
}

data_dir <- "/Users/zhengp/Documents/teaching/HMS520/Autumn2026/HMS520-Autumn2026/demo/Module03"

write_csv(df_population, file.path(data_dir, "population.csv"))
write_csv(df_deaths, file.path(data_dir, "deaths.csv"))
write_csv(df_hours, file.path(data_dir, "hours.csv"))
write_csv(df_pay, file.path(data_dir, "pay.csv"))
