# Walkthrough: `dm_sequelae_split.R`

A section-by-section guide for the refactor exercise. For each chunk we ask
three questions:

1. **What does it do?** (general functionality)
2. **What hurts?** (pain points)
3. **Where would we take it?** (refactoring direction)

Read the whole script top to bottom once before starting — you cannot safely
restructure code you have not read. The big picture: the script takes GBD
prevalence draws for *overall* diabetes and *type 1* diabetes, derives *type 2*
by subtraction, and then splits every diabetes sequela (vision loss,
neuropathy, foot ulcer, amputation, uncomplicated) into type-1 and type-2
parts, rescales them so they fit inside their parents, and writes one csv per
modelable entity. One location per run, parallelized over locations from the
command line.

---

## Section 1: setup and globals (lines 1–34)

**Functionality.** Sources the shared functions, pulls the GBD demographics to
get the age groups, reads `location_id` from the command line, and defines the
output directory plus nine modelable entity (ME) ids and two GBD-round
constants.

**Pain points.**

- Naming tells you nothing or misleads you: `argue` for the command-line
  arguments; `locations` (plural) holds exactly one id; line 16 copies it into
  `location` (singular), and *both* names are used below, so the reader must
  verify they never diverge.
- The ME ids carry contradicting commented ids (`me_id_t1<-24633 #18655`) with
  no explanation — is the comment an old value, an alternative, a typo?
  A comment that cannot be trusted is worse than none.
- `age_group_id <- ages` renames a global for no reason; `step` and
  `gbd_round` are generic names for GBD-specific constants.
- Inconsistent style from the first lines: `<-` with and without spaces, `T`
  for `TRUE`.

**Refactoring direction.** This is the future **run script**: argument
parsing, demographics, and the output path belong here and (almost) nothing
else. The ME ids are *inputs of the method*, not script-level globals — they
become named default arguments of the library functions (see
`lib_dm_sequelae_split.R`). Pick one naming convention (`location_id`,
`arguments`) and one style, and delete the duplicate alias.

---

## Section 2: pulling the draws (lines 35–58)

**Functionality.** Seven `get_draws()` calls download prevalence draws for:
type 1, parent diabetes, three severities of vision loss, and the type-1
proportions of amputation, foot ulcer, and neuropathy.

**Pain points.**

- Seven near-identical calls, each repeating `measure_id`, `gbd_round_id`,
  `age_group_id`, `decomp_step`, `location_id`. Changing one shared argument
  means seven edits.
- The calls are *almost* identical, which is worse than identical: sometimes
  `"epi"` is positional, sometimes `source="epi"`; `measure_id` is 5 for some
  pulls and 18 for others with no comment saying why (prevalence vs
  proportion).
- Each result is wrapped in `data.table(...)` by hand — a conversion that
  belongs in one place.
- Trailing comments (`#moderate`, `#severe`) do a job the variable names
  should do.

**Refactoring direction.** One private helper, `.get_draws()`, holds the
shared defaults in a single list (`modifyList` to override), always returns a
`data.table`, and every pull becomes one short, readable line. The
`measure_id = 18` pulls get a comment stating the *why* (these MEs are
modeled as proportions).

---

## Section 3: type 2 by subtraction (lines 60–94)

**Functionality.** Reshapes the t1 and parent draws long (one row per draw),
merges them, enforces `parent >= t1` by raising the parent, and computes
`prev_t2 = prev_parent - prev_t1`. Lines 81–94 are a commented-out
alternative that pulls a modeled type-2 estimate instead of subtracting.

**Pain points.**

- The long `melt()` id-vector is written out twice (and five more times later
  in the script, with small variations you must diff by eye).
- After the merge, the values live in `value.x` and `value.y` — the code
  immediately renames them, but every merge in this script re-creates this
  puzzle. Which was x? Which was y?
- The `parent >= t1` assumption *is enforced silently*. A rule that changes
  the data deserves a loud comment (it has one, good!) — and ideally a count
  of how many rows it touched.
- The commented-out alternative method (lines 81–94) is version control's
  job. As written, the reader must decide whether it is dead, dormant, or
  documentation.

**Refactoring direction.** This is the heart of the method: it becomes the
library function `get_dm_prev()`. Compute the id and draw columns *once*
(`endsWith(col_names, "_id")`, `startsWith(col_names, "draw_")`), melt with
explicit `variable.name`/`value.name` so the merge never produces `value.x`,
and write each rule as a numbered comment. The alternative method, if worth
keeping, becomes a documented option (an argument), not a fossil.

---

## Section 4: the squeeze and the first magic age list (lines 96–118)

**Functionality.** Computes each type's share of total diabetes, forces the
type-2 share to zero for young ages (the vector
`c(2, 3, 388, 389, 238, 34, 6, 7)` = under 15), rescales both types so they
sum to the parent, and relabels the squeezed versions as the official
`prev_t1`/`prev_t2`.

**Pain points.**

- `c(2, 3, 388, 389, 238, 34, 6, 7)` — eight opaque ids encoding the rule
  "under 15 is type 1 only". A vector starting `c(2, 3, 388, ...)` appears
  **nine times** in this script, in **three variants** (under-15, under-5,
  under-20) that you must diff by eye. Quick exercise: find all nine, and
  decide for each whether the differences are intentional.
- The same `ifelse` is written twice, once per ratio column, and the rule
  comment is duplicated with it.
- `prev_t1_squeeze` is computed, then copied back over `prev_t1` — two names
  for one quantity, and the intermediate survives to confuse the column
  selection at line 118.

**Refactoring direction.** The age rule gets a *name*:
`.get_under_15_age_group_ids()`, defined once, used everywhere, with the
epidemiological meaning stated where it is defined. (The later sections use
*different* cutoffs — under 5 for t1 sequelae, under 20 for t2 — so those
become their own named helpers; the names make the differences visible and
intentional.) The squeeze becomes three data.table lines inside
`get_dm_prev()` with no throwaway columns.

---

## Section 5: the save block — meet the script's favorite song (lines 120–126)

**Functionality.** Selects the id columns plus one value column, reshapes
wide (one column per draw), renames the columns to `draw_*`, and writes
`me_24634/5_<location>.csv`.

**Pain points.**

- This four-line block — select, `reshape(...)`, `gsub` rename,
  `write.csv(paste0(outdir, ...))` — reappears, lightly edited,
  **seventeen times** (lines 120–126, 304–338, 360–369, 431–464, 496–506;
  count the `write.csv` calls). Spot-the-difference is the only way to
  review it.
- Base `reshape()` is used even though `data.table` is loaded — `dcast()` is
  the tool the course (and the rest of the codebase) knows.
- The output path is assembled inline each time; the ME id and measure prefix
  are buried in a `paste0`.

**Refactoring direction.** One function:

```r
save_draws(dt, value_col, me_id, measure_id, location_id, outdir)
```

built on `dcast()`, called seventeen times. Every later "cast and save" section of
the script collapses into a handful of self-documenting one-liners. This is
the single highest-value extraction in the exercise — do it early and the
rest of the refactor shrinks dramatically.

---

## Section 6: splitting vision loss (lines 129–216)

**Functionality.** Reshapes the three vision-loss severities long, merges each
with the t1/t2 ratios, multiplies to get type-specific estimates, stacks the
three severities, aggregates to a total vision-loss envelope, and computes
each severity's share of that envelope — applying age rules again and setting
`NA` shares to 0.

**Pain points.**

- Everything happens in triplicate: three melts, three merges, six multiply
  lines (143–148) that differ only in a column name. The triple is then
  repeated *again* for amputation/ulcer/neuropathy in section 7.
- A second and third magic age vector appear (lines 211–212): under-5 for
  type 1, under-20 for type 2 — similar-looking but *different* from the
  under-15 list, and the differences are load-bearing.
- `aggregate(t1 ~ ...)` and a merge reconstruct what is a one-line
  data.table group-by; `vl.1`, `vl.2`, `vision_prop` are more numbered names
  standing in for step names.
- Lines 150–174 and 218–228 are large commented-out "CHECK" blocks with
  hard-coded personal paths (`/home/j/temp/ongl/...`) — useful diagnostics,
  wrong form.

**Refactoring direction.** A function that takes *one* sequela's draws plus
the ratio table and returns the split — then `lapply` over a named list
`list(vl_mod = ..., vl_sev = ..., vl_blind = ...)`, exactly the pattern from
Module 05's group regression. The envelope and shares become a short
data.table group-by. The CHECK blocks become a small plotting function in the
library (or a separate diagnostics script) that takes paths as arguments.

---

## Section 7: the other sequelae, same song again (lines 231–283)

**Functionality.** Melts the amputation, ulcer, and neuropathy proportions,
merges each with the t1/t2 prevalences, and multiplies — type-specific
estimates for the non-vision sequelae.

**Pain points.**

- Structurally identical to section 6, re-typed rather than reused: three
  melts, three column selections, four `as.character(...)` coercions
  (patching a factor/character merge mismatch that explicit `melt`
  arguments would have prevented), three merges, six multiplies.
- The `variable.factor` surprise: `melt` made `variable` a factor in one
  table and the code converts four tables by hand to make the merge work —
  symptom-patching instead of cause-fixing.

**Refactoring direction.** Nothing new to invent — the function extracted in
section 6 handles these three sequelae too. The whole section becomes one
`lapply` over a named list of six sequelae. That is the DRY payoff: the
second occurrence of a pattern is where the function earns its keep.

---

## Section 8: the rescale walls (lines 285–302 and 394–404)

**Functionality.** Two business rules: (neuropathy + vision loss) must stay
below 90% of the parent prevalence, and (amputation + ulcer) below 90% of
neuropathy. When the cap binds, each component is scaled down proportionally.

**Pain points.**

- Lines 291–294 and 400–404 are the least readable lines of the script:
  four `ifelse` calls per rule, each ~250 characters, each repeating the
  same cap test, with `t1.x`/`t1.y`/`t2.x`/`t2.y` merge-suffix names hiding
  which sequela is which.
- The two walls implement the *same* rule (cap a pair at 90% of an
  envelope, share proportionally) for different pairs — written out twice.
- The constant `0.9` appears sixteen times in the code. Is it one
  assumption or sixteen?

**Refactoring direction.** Write the rule once as a function —
`rescale_to_cap(x, y, cap)` returning the scaled pair — with the 0.9 as a
named default argument and the formula readable on its own. Both walls
become a few clear calls. This is the chunk where "extract a function" most
changes what a reader can verify: the proportional-sharing algebra is
checkable in isolation.

---

## Section 9: uncomplicated diabetes (lines 342–369)

**Functionality.** Uncomplicated DM = parent prevalence minus (rescaled)
neuropathy and vision loss, with the age rules applied once more; cast and
save, twice.

**Pain points.**

- The under-5 and under-20 age vectors appear yet again (lines 346–351),
  copy-pasted with their comments.
- Two more verses of the save-block song (lines 360–369).
- The subtraction silently trusts that the rescaling above guarantees a
  non-negative result — true (that is what the 90% cap is for), but nothing
  says so.

**Refactoring direction.** With `save_draws()` and the named age-rule
helpers from earlier sections, this chunk reduces to a few lines inside the
run flow, plus one comment connecting the non-negativity to the cap rule.

---

## Section 10: incidence — the whole movie, as a rerun (lines 470–506)

**Functionality.** Repeats the entire pull → melt → merge → subtract
pipeline for *incidence* (measure 6) instead of prevalence, and saves t1/t2
incidence for the uncomplicated MEs.

**Pain points — two of them are discussion gold.**

- The pulls here say `gbd_round=gbd_round` where every earlier call said
  `gbd_round_id=gbd_round`. Same intent, different argument name — does
  `get_draws` accept both, partially match, or quietly use a default?
  **Copy-paste drift creates bugs you cannot see locally.**
- Line 489: `df$inc_t2 <- abs(df$inc_parent - df$inc_t1)` with the comment
  "impose a bound so no incidence can be <0". But `abs()` does not bound at
  zero — it *flips* negative values positive: a location where t1 exceeds
  the parent by 0.03 gets t2 incidence of +0.03 instead of 0. Compare with
  the prevalence section, which handled the same situation by raising the
  parent (line 76). Same problem, two different silent answers. Which is
  right? (Probably neither without a comment.)
- `df` is *reused* — the prevalence `df` from section 3 is overwritten at
  line 485. Run the script top to bottom, fine; run a chunk interactively
  after this point, and `df` is not what you think. Generic names make
  state invisible.
- The pulls use `data.frame(...)` where the earlier ones used
  `data.table(...)` — one more inconsistency the reader must notice.

**Refactoring direction.** The method functions should never have cared
about the measure: `get_dm_prev()` generalizes to
`get_dm_draws(measure_id, ...)` (or takes `measure_id` through `...` into
the shared defaults), and incidence becomes *one more call* in the run
script — which is the whole argument for the library/run split in one
sentence. The `abs()` question goes to the original authors; a refactor
preserves behavior, so we would keep it, flag it loudly, and ask.

---

## Section 11: the commented-out graveyard (lines 81–94, 150–174, 218–228,
372–392, 408–428, 509–527)

**Functionality.** None — roughly 120 of the 527 lines are commented-out
diagnostics, alternative methods, and test plots.

**Pain points.** Every reader must re-decide what each block is: dead,
dormant, or documentation. The diagnostic plots contain hard-coded personal
paths and reference variables that no longer exist (`vl.check`, `age`),
so they would not run anyway.

**Refactoring direction.** Delete, and let git remember. The genuinely
useful diagnostics (the ratio and envelope plots) become a small, working
`plot_*` function in the library that takes its paths as arguments — a
diagnostic you cannot run is not a diagnostic.

---

## Summary: issues → principles

| Issue found in the script | Principle (slides) |
|---|---|
| One 527-line script: pulls, method, rules, IO, diagnostics | 1 — one responsibility per unit |
| `argue`, `locations`/`location`, `vl.1`, `df` reuse, `value.x` | 2 — consistent, descriptive naming |
| ME ids, age vectors ×6, `0.90` ×12, paths inline | 3 — no magic numbers |
| 7 near-identical pulls, save block ×17, rescale wall ×2, sequela triple ×2 | 4 — don't repeat yourself |
| `abs()` bound, `gbd_round=` drift, silent rules | 5 — small steps, constant verification |

## Suggested order of attack in class

1. Rename the setup (zero-risk warm-up; section 1).
2. Extract `.get_draws()` (section 2) — the first `modifyList` win.
3. Extract `save_draws()` (section 5) — the biggest line-count win.
4. Name the age rules (section 4) — the clearest "comment states the why".
5. Build `get_dm_prev()` from section 3 — the method gets a front door.
6. If time allows: the rescale function (section 8), then marvel at how
   little of the original script is left.
