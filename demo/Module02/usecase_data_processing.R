# Use case: processing a small blood pressure study
#
# This example integrates everything from Module 2 so far:
# vectors, matrices, lists, data frames, logicals, if-else, switch,
# for/while loops, next/break, the apply family, and writing functions.
# Run it top to bottom and make sure every step makes sense!


# 1. Raw data ----------------------------------------------------------
# Six patients: id, age, and systolic blood pressure at three visits.
# The measurements are all the same type (numbers), so a matrix fits.

id <- c("A01", "A02", "A03", "A04", "A05", "A06")
age <- c(34, 51, 28, 63, 45, 39)

bp <- matrix(
    c(118, 122, 120,
      141, 138,  -1,
      109, 112, 110,
      152,  NA, 149,
      133, 131, 135,
      125, 127, 124),
    nrow = 6, byrow = TRUE
)
rownames(bp) <- id
colnames(bp) <- c("visit1", "visit2", "visit3")
bp


# 2. Quality control ---------------------------------------------------
# A negative blood pressure is a data entry error: turn it into NA
# with a logical filter (no loop needed -- comparisons are vectorized).

bp[bp < 0] <- NA

# Warn if any measurement is missing (any() collapses a logical
# matrix into a single TRUE/FALSE, which is what `if` requires).

if (any(is.na(bp))) {
    print("warning: some measurements are missing")
}

# Count readings above 130, skipping the NAs with `next`.
# (A matrix is a vector underneath, so we can loop over its elements.)

n_high_readings <- 0
for (x in bp) {
    if (is.na(x)) {
        next
    }
    if (x > 130) {
        n_high_readings <- n_high_readings + 1
    }
}
n_high_readings


# 3. Summarize the matrix with apply() ---------------------------------
# Average per patient (MARGIN = 1, rows) and per visit (MARGIN = 2,
# columns). na.rm = TRUE makes mean() ignore the missing value.

bp_patient <- apply(bp, MARGIN = 1, FUN = function(x) mean(x, na.rm = TRUE))
bp_visit <- apply(bp, MARGIN = 2, FUN = function(x) mean(x, na.rm = TRUE))
bp_patient
bp_visit


# 4. Build the data frame ----------------------------------------------
# Different types per column (character, double) -> data frame,
# not a matrix.

study <- data.frame(id = id, age = age, bp = bp_patient)
str(study)


# 5. Categorize patients with control flow -----------------------------
# Three branches -> if / else if / else inside a loop.
# Pre-allocate the result first: never grow a vector inside a loop!

category <- rep("", nrow(study))
for (i in seq_along(category)) {
    if (study$bp[i] >= 140) {
        category[i] <- "high"
    } else if (study$bp[i] >= 120) {
        category[i] <- "elevated"
    } else {
        category[i] <- "normal"
    }
}
study$category <- category

# Two branches -> the vectorized shortcut ifelse() does it in one line.

study$letter <- ifelse(study$category == "high", "urgent", "routine")

# And a plain comparison is already a logical vector -- when the two
# outcomes are just TRUE/FALSE you need no control flow at all.

study$needs_followup <- study$bp >= 140
study


# 6. Refactor: abstract the rule into a function ------------------------
# The loop above works, but the rule is locked inside it. A function
# makes it reusable and configurable: the thresholds become optional
# arguments with defaults, and we validate the input with stop().

categorize_bp <- function(bp, high = 140, elevated = 120) {
    if (!is.numeric(bp)) {
        stop("bp must be numeric")
    }
    if (bp >= high) {
        "high"
    } else if (bp >= elevated) {
        "elevated"
    } else {
        "normal"
    }
}

# the function handles one value; sapply() carries it across the column
all(sapply(study$bp, categorize_bp) == study$category)

# sapply passes extra arguments through its own `...` to the function,
# so trying a stricter guideline is a one-liner
sapply(study$bp, categorize_bp, high = 135)


# 7. Map categories to actions with switch() ---------------------------
# switch() handles one value at a time, so sapply() carries it
# across the whole column.

study$action <- sapply(study$category, function(x) {
    switch(x,
        "high" = "schedule visit",
        "elevated" = "recheck in 3 months",
        "normal" = "no action"
    )
})
study


# 8. Inspect the data frame with lapply()/sapply() ---------------------
# A data frame is a list of columns, so lapply() visits each column.
# sapply() is the same but simplifies the result to a vector.

lapply(study, typeof)
sapply(study, typeof)


# 9. Find the first "high" patient with break --------------------------
# Stop scanning as soon as we find one.

first_high <- NULL
for (i in seq_along(study$category)) {
    if (study$category[i] == "high") {
        first_high <- study$id[i]
        break
    }
}
first_high


# 10. Build report lines with mapply() ---------------------------------
# Two parallel vectors in, one sentence per patient out. Writing the
# function with a name (and a default argument) instead of anonymously
# makes it reusable elsewhere.

report_line <- function(id, bp, digits = 1) {
    paste(id, "average BP:", round(bp, digits))
}
report <- mapply(report_line, study$id, study$bp)
report


# 11. Collect everything in a list -------------------------------------
# Different shapes (data frame, vectors, single numbers) live
# together happily in a list.

results <- list(
    data = study,
    per_visit = bp_visit,
    n_high_readings = n_high_readings,
    first_high = first_high
)
str(results, max.level = 1)
