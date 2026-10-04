# Week 3 Homework: Answer Key (instructor only)

This file is `.md`, not `.qmd`, so `quarto render` does not render or publish it.
Every number below was checked in R. The lecture numbers in C5 and D2 were re-run with
the deck's own Stan models and data. Simulation answers were checked with `lm()` on
100,000 simulated people, and on 1,000 people for the "you should see about…" values in
Part E.

## Part A

**A1.** (a) **Directed**: each arrow points one way, from cause to effect. **Acyclic**:
no loops; you can't follow the arrows and get back where you started, so nothing causes
itself. **Graph**: variables (nodes) joined by arrows. (b) X directly causes Y: if we
changed X, Y would change (on average), and not only through the other variables in the
graph. (c) X has no *direct* effect on Y. This is a claim too, often a stronger one than
drawing the arrow. (d) Look for: *how much* (the size of effects), the shape of the
relationship, the amount of noise/variation, or whether an effect is positive or
negative. (e) From what we know about the world: theory, earlier research, fieldwork,
experience, common sense. Not from the data: many different DAGs fit the same data
equally well.

**A2.** (a) Monsoon rain, irrigation, fertilizer. (b) Yes, but only indirectly, through
two paths: Family income → Fertilizer → Harvest and Family income → Irrigation →
Harvest. (c) The missing arrow claims that how much it rains has no direct effect on how
much a farmer irrigates. Many students will (sensibly) reject it: in a dry year farmers
irrigate more, so `Monsoon rain -> Irrigation`. Accept either answer with a reason. The
arrow should not go Irrigation → Rain. (d) Open-ended: seed variety, pests, soil
quality, labour (family members abroad), temperature, flooding. Check the arrow points
*into* the harvest.

**A3.** (a) Yes. (b) No: it's a loop (Income → Savings → Income). (c) Yes. Rain affects
road closures both through landslides and directly (flooding). Two paths are fine;
loops are not. (d) Split each variable by time: `Income_2024 -> Savings_2024 ->
Income_2025 -> Savings_2025 …`. Each variable now appears once per year and the arrows
only go forward in time, so there is no loop.

**A4.**
a. False. Causes are probabilistic: smoking raises the chance of lung cancer, but most
   smokers never get it.
b. False. Almost every outcome has many causes acting at once.
c. False. Many different DAGs fit the same data equally well. The arrows come from
   outside knowledge.
d. False. A missing arrow is a claim ("no direct effect"), and usually a stronger one.
e. True. The surgeon tables (and Model A vs. Model B) were both correct and gave
   opposite-looking answers, because they answer different questions.
f. True. In the !Kung example, age is in the DAG but doesn't need to be in the model,
   and height is in the DAG but shouldn't be in the model for the total effect.

**A5.** (a) P( high score | tuition ). (b) P( high score | do(tuition) ). (c) The
"doing" one: the parent wants to know what will happen *if they choose* to send their
child, not how students who happen to go already do. (d) Look for anything that affects
both tuition and scores. Family income is the obvious one: `Income -> Tuition`,
`Income -> Score`, `Tuition -> Score`. Also: parents' education, motivation, school
quality, living in Kathmandu vs. outside it. Students who go to tuition would do better
anyway, so "seeing" overstates "doing".

**A6.** Open-ended; no single right answer. Look for: the question imagines comparing
the same kind of person as male vs. female, which we can't actually do. It is still
useful as a way to make "how different are men and women, and why?" precise. It tells us
how big the difference is and (with the DAG) which paths it flows through, e.g.
mostly through height. Some students may point out that the more useful causal
questions usually involve things we *can* change, like nutrition. Give credit for
thoughtful answers either way.

## Part B

**B1.** (a) The famous surgeon gets the hardest cases, and hard cases fail more often
no matter who operates. So his overall rate is dragged down by his case mix, not by his
skill. Within each type of case, the comparison is fair, and he does better. (b)
`Case difficulty -> Surgeon`, `Case difficulty -> Outcome`, `Surgeon -> Outcome`.
Exposure: Surgeon. Outcome: Outcome (success). (c) The rates for your type of case.
Your case difficulty is already fixed; what you're choosing is the surgeon. This is the
"doing" question, and the within-category comparison answers it.

**B2.**
a. District: 924 / 1,000 = **92.4%**. Referral: 756 / 1,000 = **75.6%**.
b. Mild: District 864/900 = **96%**, Referral 196/200 = **98%**. Severe: District
   60/100 = **60%**, Referral 560/800 = **70%**.
c. The district hospital looks better overall. The referral hospital is better for
   *both* mild and severe patients.
d. `Severity -> Hospital` (severe cases get sent to the referral hospital).
   `Severity -> Recovery` (severe cases recover less often, wherever they go).
   `Hospital -> Recovery` (the hospital's care affects recovery). Same shape as the
   surgeon DAG.
e. The referral hospital (70% vs. 60% for severe cases). It's a "doing" question:
   "if I *go* to this hospital, what is my chance?"

**B3.** (a) The district hospital. Not fair: it wins because its patients are less
sick, not because its care is better. (b) Refuse or transfer severe patients, or admit
more mild ones. The ranking rewards picking easy patients. (c) 0.9 × 98% + 0.1 × 70% =
**95.2%**, higher than the district hospital's **92.4%**. With the same case mix, the
referral hospital comes out ahead.

## Part C

**C1.** (a) Estimand → Generative model → Statistical model → Data → Estimate.
(b) Estimand: what exactly do we want to know? Generative model: how do we think the
data was made? Statistical model: what should we fit? Data: what did we observe?
Estimate: which values are most plausible? (c) Estimand and generative model. They
come first because the data alone can't tell us which comparison to make. The question
and the causal story decide which statistical model is right, and we want to decide
that before the data can tempt us.

**C2.** Open-ended. Look for a precise comparison, a population, and units. Examples:
(a) "How many more points, on average, would a Grade 10 student in Nepal score on the
SEE if they attended tuition classes than if they didn't?" Units: exam points (or GPA).
(b) "How much higher, on average, would the chance be that a child aged 10–16 is
enrolled in school if their family received remittances than if it didn't?" Units:
percentage points. (c) "How much would the average Jumla farmer's yearly income (or
price received for apples) change if the road were built, compared with no road?"
Units: rupees (or rupees/kg). Penalize answers with no units or no comparison.

**C3.** (a) Two paths: Sex → Weight, and Sex → Height → Weight. (Age is not on any
path *from* sex, because no arrow points from age into sex.) (b) `Sex -> Weight`.
(c) Nothing in this picture causes a person's sex: it's set at birth, before height,
weight, or (measured) age can affect it. (d) Total effect: both paths. Direct effect:
only `Sex -> Weight`.

**C4.** Checked by simulating 100,000 people for each world.
a. Direct **3 kg**. Total 3 + 0.5 × 12 = **9 kg**. (Simulation: 8.96 and 2.95.)
b. Direct **0 kg**. Total 0 + 0.6 × 10 = **6 kg**. (Simulation: 5.97 and −0.05.)
c. Direct **2 kg**. Total 2 + 0.6 × 0 = **2 kg**. (Simulation: 1.97 and 1.95.)
d. About the same (about 2 kg each). The path through height carries nothing if sex
   doesn't change height, so blocking it makes no difference. The two models only
   disagree when the path through height carries some of the effect.

**C5.**
a. Model A: men weigh about 6.8 kg more than women on average (plausibly between 5.8
   and 7.7 kg). Model B: among men and women of the *same height*, there is essentially
   no difference (between −1.0 and +1.0 kg).
b. Model A. The estimand asks how much heavier someone would be if male, by any route,
   which is the total effect. Model A lets the effect flow along both paths.
c. Model B holds height fixed, which blocks the path Sex → Height → Weight. It only
   measures the direct effect. Sex has a big effect on weight; almost all of it goes
   *through* height. Adding height hides the very effect we asked about.
d. 10.8 × 0.63 ≈ **6.8 kg**, the same as Model A. Almost all of the total effect flows
   through height; the direct part (Model B) is about zero. (With `lm()` the two pieces
   add up exactly: −0.10 + 10.84 × 0.634 = 6.78 = Model A's estimate.)
e. Something like: "Among adults of the same height, how much heavier are men than
   women?" or "Does sex affect weight through anything *other* than height (e.g. muscle
   mass)?"

**C6.** (a) Age affects height and weight, but nothing points from age into sex, so age
opens no extra path from sex to weight. Leaving it out doesn't mix anything into our
estimate. (b) No, it doesn't prove the DAG is right. It is consistent with the DAG: if
age did interfere, adding it would probably have moved the estimate more. But a small
change can't rule out other problems (e.g. something unmeasured). Checks build
confidence; they don't prove the assumptions.

**C7.** (a) `Living area -> Bedrooms`, `Living area -> Price`, `Bedrooms -> Price`.
`Sex -> Height`, `Sex -> Weight`, `Height -> Weight`. (b) Area points *into* bedrooms
(Area → Bedrooms). Sex points *into* height (Sex → Height). (c) The path Bedrooms ←
Area → Price is not an effect of bedrooms. It's there only because bigger houses have
more bedrooms and also cost more. We want to block it, so we hold area fixed. The path
Sex → Height → Weight *is* part of the effect of sex. Blocking it by holding height
fixed throws away part of what we're trying to measure. The move is the same; the
direction of the arrow decides whether it helps or hurts. The DAG decides.

## Part D

**D1.** Open-ended. A good answer looks something like:

```
dag {
  Remittances [exposure]
  School [outcome]
  "Family wealth" -> Remittances
  "Family wealth" -> School
  "Parents' education" -> School
  "Parents' education" -> Remittances
  Remittances -> "Household income" -> School
  Remittances -> "Parent at home" -> School
  "Child labour" -> School
  "Household income" -> "Child labour"
  "Family connections" [latent]
  "Family connections" -> Remittances
  "Family connections" -> School
  "Distance to school" -> School
}
```

(a) e.g. "How much more likely would a child be to stay in school if their family
received remittances than if it didn't? (percentage points)". (b) Family wealth,
parents' education, distance to school, school quality, child labour, gender. (c)
Family wealth (paying a manpower agency), connections abroad, lack of local jobs. (d)
Check there's at least one latent variable and no loops. (e) Paths starting with an
arrow *out* of Remittances (through income, through a parent being away) carry the
effect. Paths that go *backwards* into Remittances (through wealth, parents' education,
connections) don't. Students won't have formal rules for this yet (that's Week 4), so
accept a clear "this one is the effect / this one isn't" with a reason. Bonus for
noticing that a parent being abroad might *hurt* schooling while the money helps, so
the total effect could be small even if both paths are strong. (f) Open-ended.

**D2.**
a. DAG 1: richer, more developed countries send more women to college and have fewer
   infant deaths. Fewer infant deaths means families need fewer births, so part of the
   college–births correlation is just development. DAG 2: when women are educated, their
   babies are healthier, so families need fewer births. Education lowers births both
   directly and through infant mortality.
b. DAG 1: no. The path College ← Development → Infant mortality → Births is not an effect
   of college. DAG 2: yes. College → Infant mortality → Births is part of college's
   effect.
c. DAG 1: yes, hold infant mortality fixed (it blocks the path that isn't an effect).
   DAG 2: no, leave it out (holding it fixed would block part of the effect).
d. DAG 1: about **0.09** fewer births per woman. DAG 2: about **0.55** fewer. (Nepal:
   15.4% enrollment, 2.0 births per woman in 2022; one SD = 34.8 points.) Students
   should notice this is the same move to about 50% enrollment, with a sixfold
   difference in the answer depending only on the DAG.
e. Open-ended. Look for a real argument (e.g. Nepal's infant mortality fell a lot with
   health programs that had little to do with women's education, which supports
   development/health as a separate cause), and some evidence that would change their
   mind (e.g. within-country studies of school reforms, or comparing districts).
f. `Development -> College`, `Development -> Mortality`, `College -> Mortality`,
   `College -> Births`, `Mortality -> Births`. Holding mortality fixed blocks the path
   through development (good) but also College → Mortality → Births (bad, part of the
   effect). Leaving mortality out keeps the effect path but also leaves the development
   path open. Neither choice gives the total effect. You would need to measure
   development itself (and hold *it* fixed). Don't expect formal language; Week 4 covers
   this.

**D3.** (a) `Literacy -> Internet use` and `Internet use -> Literacy` form a loop. Keep
one direction (or split by time, as in A3d). Since the estimand is the effect of
internet use on literacy, keep `"Internet use" -> "Literacy"`, but note that a
literate population also uses the internet more, so a time-split version is better. (b)
Schooling (years of schooling, primary enrollment), government spending on education,
urbanization. (c) Probably not believable: richer countries spend more on schools, so
`"GDP per capita" -> "Literacy"` is likely. Also `Literacy -> GDP` and `GDP -> Literacy`
together would be another loop, so students need to pick a direction or split by time.
(d) For example:

```
dag {
  "Internet use" [exposure]
  "Literacy" [outcome]
  "GDP per capita" -> "Internet use"
  "GDP per capita" -> "Literacy"
  "GDP per capita" -> "Schooling"
  "Schooling" -> "Literacy"
  "Urbanization" -> "Internet use"
  "Urbanization" -> "Literacy"
  "Internet use" -> "Literacy"
}
```

**D4.** Open-ended. Check that: the estimand names X, Y, and units; the revised dagitty
string parses (paste it into dagitty.net); at least one variable was added and marked
`[latent]` where appropriate; and part (e) gives a reason for each variable in the model.
Common issues to look for in the existing project DAGs:

- A variable in the model that sits *between* X and Y (X → M → Y), which blocks part of
  the effect if the estimand is the total effect.
- Variables marked `adjusted` in the DAG that aren't actually in the model, or the other
  way round.
- No unmeasured variables at all. Almost every country-level question has some
  (culture, institutions, history).

## Part E (sample solution)

```r
library(tidyverse)

simulate_people <- function(n, tall = 10, slope = 0.6, direct = 2) {
  tibble(
    sex = sample(c("female", "male"), n, TRUE),
    male = sex == "male",
    height = rnorm(n, 150 + tall * male, 6),
    weight = rnorm(n, -45 + slope * height + direct * male, 4)
  )
}

both_models <- function(sim) {
  c(
    A = coef(lm(weight ~ sex, data = sim))[["sexmale"]],
    B = coef(lm(weight ~ sex + height, data = sim))[["sexmale"]]
  )
}

set.seed(1)
both_models(simulate_people(1000)) # about 8 and 2
both_models(simulate_people(1000, tall = 12, slope = 0.5, direct = 3)) # about 9 and 3
both_models(simulate_people(1000, direct = 0)) # about 6 and 0
both_models(simulate_people(1000, tall = 0)) # about 2 and 2

simulate_with_age <- function(n, age_affects_sex = FALSE) {
  tibble(age = runif(n, 18, 80)) |>
    mutate(
      male = if (age_affects_sex) runif(n) < plogis(-(age - 50) / 8) else runif(n) < 0.5,
      height = rnorm(n, 150 + 10 * male - 0.1 * (age - 50), 6),
      weight = rnorm(n, -45 + 0.6 * height + 2 * male - 0.1 * (age - 50), 4)
    )
}

# E2: about 8 either way
sim <- simulate_with_age(1000)
coef(lm(weight ~ male, data = sim))[["maleTRUE"]]
coef(lm(weight ~ male + age, data = sim))[["maleTRUE"]]

# E3: about 12 without age, about 8 with age
sim <- simulate_with_age(1000, age_affects_sex = TRUE)
coef(lm(weight ~ male, data = sim))[["maleTRUE"]]
coef(lm(weight ~ male + age, data = sim))[["maleTRUE"]]
```

**E1.** With 1,000 people the answers bounce around a little (one run gave 7.8 and 1.8;
then 9.0 and 3.0, 6.4 and 0.2, 2.2 and 2.2), but they land near the C4 answers. Larger
`n` gets closer.

**E2.** Adding age barely changes the total effect (the sample code above gives 7.8
without age and 7.8 with age; other seeds give similar small differences). Age affects height and weight but not sex, so it opens no extra path from sex to
weight.

**E3.** Now older people are mostly women, and older people are shorter and lighter.
So men in the sample are younger *and* heavier partly because of their age. Without age,
`weight ~ male` gives about **12 kg** (sample code: 11.7; other runs 11.8–12.3;
100,000 people: 11.9), well above the true 8. Adding age brings it back to about **8 kg** (sample code: 7.6;
other runs 7.0–8.5; 100,000 people: 7.95). The new arrow `Age -> Sex` creates a path
Sex ← Age → Weight that is not an effect of sex, so age now belongs in the model.

Note for instructors: students who also add age to **Model B** (`weight ~ sex + height`)
will see the *direct* effect move noticeably even without `Age -> Sex` (about 1.2
without age vs. 2.0 with age, at n = 100,000). That's because holding height fixed links
sex and age (both cause height). This is a Week 4 topic, so the homework only asks about
Model A here. If a student spots it, point them to next week.
