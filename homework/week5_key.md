# Week 5 Homework: Answer Key (instructor only)

This file is `.md`, not `.qmd`, so `quarto render` does not render or publish it.
Every number below was checked in R.

Many questions this week are about judgement. The answers below are model answers, not
the only acceptable ones. Give credit for any answer that states its assumptions and
reasons clearly.

## Part A

**A1.** (1) What exactly is the claim? Week 3 (seeing vs. doing, estimands).
(2) What did they actually measure? Week 2 (variables and units) and Week 4 (proxies
are descendants). (3) How was the data made? Week 3 (`do(X)`, randomization deletes
arrows into X). (4) What's in their DAG, and what's in their model? Weeks 3–4.
(5) Who is it about? Mostly new: sample vs. population, "would it work here?", and the
ecological fallacy. (6) How big, and how sure? Week 2 (distributions, units), plus the
new piece on reading ranges from a std. error. (7) How plausible was it before? Week 1
(base rates, P(true | significant)). Accept "5 and 6" or "5" as the new ones.

**A2.** (a) Descriptive. (b) Causal: *drive*. (c) Predictive. (d) Descriptive (an
association; no causal verb). (e) Causal: *boosts*. Note (d) and (e) can come from the
same data; only the wording changed. Example estimand for (e): "Among students at this
school, how much higher would the average grade be at the end of the year if students
were made to use the library one extra hour a week, compared to their usual use?" That
is a **doing** question; the data in (d) are **seeing**.

**A3.** (a) Any three of: years of schooling, enrollment rate, completion rate, SEE
pass rate, literacy, test scores. Yes, they can disagree: enrollment can rise while
learning stays flat. (b) Gross enrollment divides *everyone* enrolled, of any age, by
the number of people of the official college age. Older students, repeaters, and
students from abroad can push it above 100%. Lesson: read the definition, not just the
label. (c) A proxy is caused by the concept it stands for, so it carries only part of
the information. Controlling for a proxy closes a fork only partly, like controlling
for a descendant.

**A4.** (a) Natural experiment (a lottery): chance decided. (b) Cross-sectional
comparison: the NGO, and whatever drove it to place clinics (need, roads, wealth,
local politics). (c) Before/after with a comparison group: the start date, which
someone chose; works if both groups would have moved together without the curriculum.
(d) Randomized experiment: a coin flip. (b) has the most back doors: one snapshot, and
clinic placement was chosen for reasons that also affect child health.

**A5.** (a) Fork: wealth causes both clinic visits and child health. Good to control.
(b) Pipe: the subsidy works *through* more fertilizer use. Controlling for it hides the
effect; bad if you want the total effect. (c) Collider (selection): passing the SEE is
caused by both family wealth and study hours. Looking only at passers creates a false
negative link. Bad.

**A6.** (a) No. The data are about countries, not people. Richer countries may have
both more internet use and more jobs and schools. (b) The ecological fallacy. (c)
Example: national wealth causes both higher internet use and more school and job places
(a fork at the country level). Even if internet did nothing for any individual, the
country averages would still move together.

**A7.**
a. False. "Not significant" only means the plausible range includes zero. The range may
   also include large effects. Uncertain is not the same as zero.
b. False. Stars only say whether the range crosses zero. A tiny effect measured very
   precisely can get three stars.
c. False. A good experiment answers "does it work here, for these people?" Madhesh may
   differ in distance to school, roads, prices, and baseline enrollment.
d. True. An average can hide people who are hurt.
e. True. Small sample, large effect, and surprise are all warning signs from question 7.
f. False. From 4 in 1,000 to 2 in 1,000 "halves" the risk, but it is 2 fewer cases per
   1,000 people, or 20 per 10,000.

## Part B

**B1.** Causal: "boosts." Estimand the NGO seems to have in mind: "Among grade 9
students in Nepal, how much higher would the pass rate be after one year if their school
got tablets, compared to no tablets?" Note the leap from "30 private schools that
applied" to "every public school."

**B2.** Measured: the pass rate on a practice exam written by the NGO. The NGO may have
written the exam to match the tablet lessons, so it could measure "practised on the
tablet" rather than general learning. The real SEE, or an independent test, would be
better.

**B3.** The schools **chose** to apply. Example DAG: Tablet ← Motivated head teacher →
Score, plus Tablet → Score. Also accept school wealth or parental involvement. This is a
**fork**, and the common cause is unmeasured, so it is a back door left open.

**B4.**
a. Tablet → Attendance → Score is plausible (students come to school to use tablets).
   Then attendance is a **pipe** (mediator). Controlling for it removes the part of the
   effect that works through attendance, so the 4.0 is not the total effect. (If a
   student argues attendance is only a fork, e.g. motivated families, accept it with a
   DAG; the key point is that it must be checked against the DAG.)
b. Tablet working ← Good management → Score, and the program itself → Tablet working.
   Selecting on "tablets still worked" is selecting on a **collider** (or a descendant
   of good management). It keeps the well-run tablet schools and drops the badly run
   ones, so it probably makes the program look **better** than it is.

**B5.** Studied: grade 9 students in 30 private schools in Kathmandu Valley that applied.
Conclusion: every public school in Nepal. Differences: private vs. public; urban vs.
rural; electricity and internet; teacher training; schools that wanted the program vs.
schools that didn't; baseline pass rates.

**B6.**
a. 66 − 60 = **6 percentage points**. The "10%" is relative: 66 / 60 = 1.10.
b. 0.06 × 1,000 = **60** extra students.
c. Rs 12,000 / 0.06 = **Rs 200,000** per extra passing student. (Equivalently: 1,000
   students cost Rs 1.2 crore and produce 60 extra passes.)

**B7.**
a. Tablet program: 4.0 ± 3.0 → **1.0 to 7.0** points. Distance: −0.40 ± 0.60 →
   **−1.0 to 0.2** points per km.
b. No. The range runs from a loss of 1 point per km to a small gain. That is
   *uncertain*, not zero. A 10 km walk could plausibly cost up to 10 points.

**B8.**
a. 0.5 × 0.1 / (0.5 × 0.1 + 0.05 × 0.9) = 0.05 / 0.095 = **0.53**, about a coin flip.
b. 1 − 0.95¹⁰ = **0.40**. Even if tablets did nothing, there is a 40% chance that at
   least one of the 10 outcomes looks significant. Reporting only the one that "worked"
   makes the finding much less trustworthy.

**B9.** Open-ended. Strong answers point to question 3 (schools chose to apply) or
question 4 (dropped schools, controlling for attendance). The one thing: a comparison
where schools did **not** choose, e.g. a lottery among applicant schools, ideally
public ones, with all 10 outcomes reported.

## Part C

**C1.** Causal. Estimand: "Among girls finishing grade 8 in Bihar, what is the
difference in the share enrolled in secondary school one year later, if they are given
money for a bicycle compared to no program?"

**C2.**
a. Many other things changed in Bihar after 2006 (roads, the economy, other schemes).
   Before/after alone mixes them all in with the program.
b. Boys didn't get bicycles but lived through the same Bihar-wide changes. Subtracting
   boys' change removes those shared changes.
c. In case the girl–boy gap was closing everywhere anyway (for example, across the
   region), Jharkhand shows how much the gap changed without the program.
d. "…the same way as the gap between girls and boys in Jharkhand." This assumption can't
   be checked directly. It can be made more believable by showing the two states'
   gaps moved together before 2006.

**C3.** (Invented numbers.)
a. 45 − 30 = **15** points. No: it includes everything else that changed.
b. Bihar boys changed 58 − 50 = 8. 15 − 8 = **7** points.
c. Jharkhand: girls 40 − 32 = 8, boys 58 − 52 = 6, so 8 − 6 = **2** points.
d. 7 − 2 = **5** points. The answers shrink (15 → 7 → 5) because each comparison
   removes another source of change that was not the program: first Bihar-wide changes,
   then a narrowing gender gap that was happening anyway.

**C4.** Program → Owns bicycle → Travel time / safety → Enrolled. Possibly also
Distance to school → Enrolled and Distance → how much the bicycle helps. Owning a bicycle
is a **pipe** (mediator). Controlling for it removes the main path, so the program's
estimated effect would shrink toward zero, even though the program works.

**C5.** Any three, with a reason: distance to secondary school; road quality and flat
vs. hilly land (Madhesh is flat, which may help); safety on the road; how many girls
already own bicycles; baseline enrollment; school fees and other costs; social norms;
the price of bicycles today vs. 2006. Gain the least: girls who live very close to
school, girls who already have a bicycle, and girls who would enroll anyway (or never
could, e.g. because of work or marriage).

**C6.** Extra girls enrolled per 1,000 eligible girls (percentage points), and rupees
per extra girl enrolled, with a range. Alternatives: a cash transfer of the same value,
a school bus, building schools closer, scholarships.

**C7.** Plausible, with a clear mechanism (distance and safety keep girls out of
secondary school), a large program, and a careful design. It is not a cheap, surprising
finding. That raises the prior, so the result deserves more trust than a surprising
small study, though one study in one state is still one study.

**C8.** Open-ended. Good answers: "Not yet" and one specific thing, e.g. how far
Madhesh girls live from secondary schools, whether cost or distance is the main barrier,
or a pilot result in Madhesh.

## Part D

**D1.**
a. The bridge is already built, so no answer changes this decision. Not worth doing for
   this decision. (It could be worth doing if other wards will decide whether to build
   bridges.)
b. High: offer the lower rates. Low: keep current rates (or try something else).
   Worth doing.
c. High: start the tiffin. Low: spend the money elsewhere. Worth doing if the cost is
   real and the school is unsure.

**D2.** (b) and (d) are real questions. (a) and (c) are not. Example rewrites:
(a) "Should our municipality fund a job centre for returning migrants?" (c) "Should
the district fund scholarships for girls in grades 11–12, compared to spending the
same money on school toilets?"

**D3.** Example: Population: children in grades 1–5 in the municipality's public
schools. Outcome: share of school days attended. Intervention: a free school meal every
school day. Compared to what: no meal program (or: the same money given to families).
Time: one school year. Summary: difference in average attendance. Sentence: "Among
grade 1–5 children in our public schools, what is the difference in average attendance
after one school year, if they get free school meals compared to no meal program?"

**D4.**
a. Missing nearly everything: population, comparison, time, summary. Fix: "Among women
   in rural Nawalparasi, what is the difference in average monthly income after two
   years, if they get access to microfinance loans compared to no access?"
b. Missing the comparison and the time. Fix: "…after one harvest, if they get
   drought-resistant seed compared to their usual seed?"
c. Missing the population, outcome, and time. Fix: "Among girls finishing grade 8 in
   rural Madhesh, what is the difference in the share enrolled in grade 9 one year
   later, if they get a bicycle compared to a cash transfer of the same value?"

**D5.** Yes. The bicycle can beat "no program" but lose to cash, if families would use
cash for something that helps schooling more (fees, uniforms) or less. If the money will
be spent on girls' schooling anyway, (ii) is the question that matters: the decision is
*which* program, not *whether* to spend.

**D6.**
a. Each 1 point of effect produces 1 extra girl per 100 bicycles. Cost per extra girl =
   Rs 10,000 / (e / 100). Setting this to Rs 200,000 gives e = **5 percentage points**.
b. Rs 10,000 / 0.04 = **Rs 250,000** per extra girl. Too expensive by the council's rule.
c. (i) Fund: the whole range is above 5. (ii) Don't fund: the whole range is below 5.
   (iii) Unclear: the range includes values on both sides of 5.
d. The decision depends on where in 2–12 the truth is. A small pilot with random
   assignment can narrow the range at low cost before a big, hard-to-reverse spend.

## Part E

**E1.** Example: take all public primary schools in the municipality; flip a coin for
each school to get free meals or not this year; measure attendance at the end of the
school year. Randomizing at the school level makes sense because meals are served per
school. The coin flip deletes every arrow into the program, so wealth, motivation, and
location can't create back doors.

**E2.** Example rows:

| Ideal experiment | Data we have | Gap |
|---|---|---|
| Bicycles given by coin flip | Households **chose** to own bicycles | Back doors: wealth, distance, parents' attitudes |
| Enrollment before and after | One survey, one year | Can't see change over time |
| Girls finishing grade 8 | Households with a daughter aged 15–16 | Some girls already dropped out; who owns the bicycle (father, brother)? |
| The program: a bicycle for the girl | Any bicycle in the household | Ownership ≠ the girl using it to get to school |

To close back doors: household income (measured), distance to school (measured, but
distance may also change how much a bicycle helps), parents' education and attitudes
toward girls' schooling (not measured). So the back doors can't all be closed.

**E3.** If you list limitations after seeing results, it is tempting to mention only the
ones that explain away results you don't like. Naming them first keeps you honest, and
tells readers what the data can and can't answer whatever the result.

**E4.** Target trial: among girls finishing grade 8 in Bihar, randomly give half money
for a bicycle and half nothing; measure secondary enrollment a year later. Actual: the
whole state got the program at once, so there is no random comparison group within
Bihar. The biggest gap is that nobody in Bihar was randomly left out. The triple
difference builds a comparison from groups that didn't get the program (boys, and
Jharkhand), and relies on the assumption that the gaps would have moved together.

## Part F

**F1.** Open-ended. Check:

- The estimand has all six pieces, including a **comparison**. Most World Bank projects
  have country-level exposures (e.g. internet use, drinking-water access, corruption
  control). The population will usually be "countries" or "people in countries like
  Nepal," and students should notice which one they mean.
- The target trial is concrete (what is randomized, among whom, measured when), even if
  impossible. Randomizing countries' internet use is impossible; saying so is fine.
- The gap table names at least: no randomization (back doors, so their DAG matters),
  one year (no before/after), country-level (ecological fallacy for any claim about
  individuals), and at least one measurement issue with a specific variable.
- The skeptic's first question: usually question 3 (what decided which countries have
  high X?) or question 5 (countries vs. people).

**F2.** Grade on structure and reasoning, not on the report chosen:

- All seven questions are addressed, each briefly and specifically for this report.
- Claims about the DAG are backed by a named fork, pipe, or collider.
- Size is put in decision units, with a range if one is available (or the absence of a
  range is pointed out).
- The final section names concrete, checkable things, not "more research is needed."
- One page.

## Part G (sample solution)

```r
plausible_range <- function(estimate, se) {
  data.frame(
    estimate,
    low = estimate - 2 * se,
    high = estimate + 2 * se,
    crosses_zero = estimate - 2 * se < 0 & estimate + 2 * se > 0
  )
}
plausible_range(c(4.0, 0.30, 2.5, -0.40), c(1.5, 0.05, 0.8, 0.30))
# Program 1.0 to 7.0; attendance 0.2 to 0.4; income 0.9 to 4.1;
# distance -1.0 to 0.2 (the only one that crosses zero)

simulate_schools <- function(n = 1000, effect = 0, randomize = FALSE) {
  motivation <- rnorm(n)
  if (randomize) {
    tablet <- rbinom(n, 1, 0.5)
  } else {
    tablet <- rbinom(n, 1, plogis(2 * motivation))
  }
  score <- 50 + 5 * motivation + effect * tablet + rnorm(n, 0, 5)
  mean(score[tablet == 1]) - mean(score[tablet == 0])
}

set.seed(5)
mean(replicate(200, simulate_schools(effect = 0)))                    # about 6
mean(replicate(200, simulate_schools(effect = 0, randomize = TRUE)))  # about 0
mean(replicate(200, simulate_schools(effect = 3)))                    # about 9
mean(replicate(200, simulate_schools(effect = 3, randomize = TRUE)))  # about 3
```

With this seed: about 6.1, 0.0, 9.1, and 3.1. Students' numbers will differ a little.
(a) The tablets do nothing, but the difference is about 6 points, because motivated
schools both join and score higher (a fork). (b) About 0: the coin flip deletes the
arrow from motivation to tablets. (c) Only the coin-flip design recovers 3; the
self-selected comparison adds the same ~6 points of bias. (d) When the school decided,
motivation decided, and motivation is a back door.

## Part H

**H1.** Open-ended. Look for a specific change of view tied to at least one of the seven
questions, and a concrete example from their own work or news.
