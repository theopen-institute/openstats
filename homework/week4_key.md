# Week 4 Homework: Answer Key (instructor only)

This file is `.md`, not `.qmd`, so `quarto render` does not render or publish it.
Every number below was checked in R, using the exact code in the homework. Every
adjustment set was checked with the `dagitty` R package (`adjustmentSets()`).

## Part A

**A1.**

| Structure | Arrows | Through Z, by default | If you hold Z fixed | Control for Z? |
|-----------|--------|-----------------------|---------------------|----------------|
| Fork | X ← Z → Y | open | closed | Yes |
| Pipe | X → Z → Y | open | closed | Only if you want the *direct* effect |
| Collider | X → Z ← Y | closed | **open** | No |

Lecture examples: fork = age at marriage ← geography → happiness (or phones ← wealth →
births). Pipe = gender → study time → exam result (or treatment → fungus → growth, or
sex → department → admission). Collider = wealth → prestigious job ← hard work (or
newsworthy → funded ← trustworthy).

**A2.** (a) Family income, by adding it to a regression. (b) Being ill enough to be in
hospital, by selecting the sample. (c) Region (Terai vs hills), by splitting into
groups. (d) Passing the interview, by selecting the sample. Selection, (b) and (d), is
the easiest to miss. Nobody "adds" a variable. The data was already filtered before the
analyst saw it.

**A3.** Look for: a confounder (fork) creates an association that is *not* a causal
effect of X, so closing it removes bias. A mediator (pipe) carries part of the *real
effect* of X, so closing it removes part of what we are trying to measure. Same
mechanics, but in one case we block a false path and in the other a true one. Holding a
mediator fixed is only right if the question is about the direct effect.

**A4.** (a) Treatment → Fungus → Growth. (b) Post-treatment bias: controlling for
something the treatment itself changes. That blocks the path the treatment works
through, so the treatment looks useless even when it works. (c) Yes: if the question is
"does the treatment do anything *other than* prevent fungus?" (the direct effect). Here
the answer would be "no", which is true in this world.

**A5.** (a) Income group is a descendant of wealth: a rough, noisy copy. Holding it
fixed only partly holds wealth fixed. Countries in the same income group still differ in
wealth, so part of the fork stays open. (b) Salary is a descendant of the collider (job).
Selecting high earners mostly selects people with the job, so it partly opens
wealth → job ← hard work.

**A6.**
a. False. Controlling for a collider or a mediator can create or hide effects.
b. False. Effects can cancel out, and selection can hide a relationship. (Also,
   *correlation* only measures straight-line association.) Accept either reason.
c. False. A sample selected on a common effect (a collider) can show an association
   that isn't in the population, as in the grants example.
d. True. The lecture says the classic reversal is usually a fork (bedrooms, surgeon).
   Accept "usually true, but Berkeley was a pipe" for full credit.
e. False. Many DAGs fit the same data. Whether Z is a confounder or a mediator depends
   on which way the arrows point, and that comes from science, not data.

**A7.** A back door is a path from X to Y that starts with an arrow pointing *into* X.
It carries association that is not an effect of X. (a) Height is caused by sex, so it is
on a causal path (a pipe). Rule 3: don't hold fixed anything X causes, if you want the
total effect. (b) Living area causes both bedrooms and price, so it opens a back door
into bedrooms. Rule 2: close every back door.

## Part B

**B1.** Accept other answers if the DAG and reasoning are sound.

a. **Fork.** Landslides ← monsoon rain → rice harvest.
b. **Collider.** Marks → scholarship ← athletics. The scholarship sample is selected on
   the collider.
c. **Fork**, mainly: population size → health posts and population → TB cases. Also a
   **pipe**: health posts → more testing → more *reported* TB (like doctors detecting
   cancer in lecture). Full credit for either with a reason; extra credit for both.
d. **Pipe** (post-treatment bias). Fertilizer → soil nitrogen → harvest. Holding nitrogen
   fixed blocks the way fertilizer works.
e. **Collider.** Good website → survived ← good service (reviews). Only agencies that
   were good at *something* survived.
f. **Pipe.** Remittances → school spending → results. Holding spending fixed hides the
   effect. (A wealth fork is also plausible, see C1.)

**B2.**
a. **Fork.** Students who are already struggling use ChatGPT more, and also get lower
   marks: use ← earlier ability → marks. Control for earlier marks.
b. **Collider** (Berkson's paradox). Diabetes → hospital ← broken bone. Don't trust the
   pattern; the sample is selected on the collider.
c. **Pipe.** Schooling → income → food security. Controlling for income blocks much of
   schooling's effect. Don't control for income if you want the total effect.
d. ★ **Collider.** Study size → published ← big (significant) effect. A small study can
   only reach significance with a big estimated effect, so small *published* studies
   have big effects. This is publication bias, and links back to Week 1.

**B3.** ★ (a) Smoking → low birth weight ← other problems; smoking → death; other
problems → death; low birth weight → death. (b) Low birth weight is the collider. Holding
it fixed opens Smoking → Low weight ← Other problems → Death. (c) A baby can be
low-weight because the mother smoked *or* because of another problem. Among low-weight
babies of non-smokers, more of them have the other, more dangerous problems. So within
the low-weight group, smokers' babies look healthier. Smoking is still harmful overall.

## Part C

**C1.**
a/b.

| Path | Type | Open? |
|------|------|-------|
| Remittances → Results | causal (direct) | open |
| Remittances → Tuition → Results | causal (pipe through Tuition) | open |
| Remittances ← Wealth → Results | back door (fork at Wealth) | open |
| Remittances ← Wealth ← District → Results | back door (fork at District) | open |
| Remittances → Boarding ← Results | collider at Boarding | closed |

c. **Wealth:** yes, it closes both back doors. **District:** not needed once Wealth is
   in; harmless to add. ({Wealth} and {District, Wealth} are both valid. District alone
   is not, since it leaves Remittances ← Wealth → Results open.) **Tuition:** no, it is a
   mediator; controlling for it removes part of the effect. **Boarding:** no, it is a
   collider; controlling for it opens a false path.
d. {Wealth}.
e. Controlling for Boarding opens Remittances → Boarding ← Results. Among boarding
   students, those from households without remittances must have had very good
   results to get in, so remittances will look less helpful than they are (or even
   harmful). dagitty confirms {Wealth, Boarding} is not a valid set.
f. Direct effect: {Tuition, Wealth}. (Checked with `adjustmentSets(..., effect =
   "direct")`.)

**C2.** ★
a. Coaching → Passed (causal, open). Coaching ← Wealth → Kathmandu ← Motivation → Passed
   (back door, **closed**, because Kathmandu is a collider on it).
b. No. Coming "before" is not the test; the arrows are. Kathmandu is a collider.
   Controlling for it alone opens the back door, which makes the estimate biased.
c. Also control for Wealth (it closes the newly opened path). Motivation would also work
   but isn't measured. Valid sets with measured variables: {} (nothing), {Wealth}, and
   {Kathmandu, Wealth}. {Kathmandu} alone is not valid.
d. Rule 4: don't hold fixed a collider, unless you also close the path it opens. (This
   is sometimes called "M-bias".)

**C3.**
a. Nothing. The paths are Sex → Admitted, Sex → Department → Admitted (both causal), and
   Sex → Department ← Ability → Admitted (closed collider). The empty set is valid.
b. Sex → Department ← Ability → Admitted. Department is the collider.
c. The only ways to close that path are to hold Ability fixed, or not hold Department
   fixed. But we must hold Department fixed to get the direct effect. With Ability
   unmeasured, no set works. (dagitty returns no adjustment set for the direct effect.)
   We need better data or more science.
d. {Ability, Department}.

## Part D

All numbers come from the exact code in the homework.

**D1.** (a) r = **0.47**. (b) Urban r = **−0.02**, rural r = **−0.01**. (c) `lm(happiness
~ age)`: age coefficient **0.23**. `lm(happiness ~ age + urban)`: **−0.01**. The second
matches the truth (no effect). (d) Adding `urban` closed the back door
age ← geography → happiness. (For reference: average age at marriage is 21.8 rural vs
28.1 urban; happiness 3.6 vs 6.5.)

**D2.** (a) Untreated **3.75**, treated **4.77** (a gap of about 1 cm). Fungus rates:
47% untreated, 7% treated. (b) `lm(growth ~ treated)`: **1.03**. `lm(growth ~ treated +
fungus)`: **−0.10** (fungus: −2.86). (c) The first. The farmer wants the total effect,
and the treatment works *by* preventing fungus. The second model asks a different
question.

**D3.** (a) All proposals: r = **−0.07** (close to zero, just noise). Funded (top 10%, 20
proposals): r = **−0.77** (the same number as the lecture slide). (b) Top 50%: r =
**−0.45**. The more selective the funding, the stronger the false negative correlation.
(With a very large sample, top 50% / 10% / 1% gave −0.47 / −0.72 / −0.83, so the pattern
is not small-sample noise.) (c) r = **0.01**. Selecting on newsworthiness alone is
selecting on X, not on a common effect, so no collider is opened. (d) Coefficient on
`newsworthy` = **−0.31** (vs −0.07 with no control). Adding a collider to a regression
opens the path just like selecting the sample does.

## Part E

Open-ended. Check that students list the paths correctly and compare with their model.
For reference, here is what dagitty says about each project DAG as currently written
(with the `adjusted` marks removed, so dagitty is free to choose):

| Project | X → Y | Minimal adjustment set | What the project adjusts for | Notes |
|---------|-------|------------------------|------------------------------|-------|
| archana | Drinking water → Water stress | Rural pop, Wage workers | same | Two simple forks. |
| ranju | Corruption → Political stability | Gov. effectiveness, Rule of law, Voice & accountability | same | Three forks. |
| sambit | Internet users → Youth NEETs | Electricity access, GDP per capita | + Urbanization (still valid) | Electricity is a fork *and* a collider (GDP → Electricity ← Urbanization). Adjusting for it opens a path, which GDP closes. Good discussion case. |
| sameer | Compulsory education → Vulnerable employment | Rule of law, Voice & accountability | same | Youth NEETs is a **pipe**; correctly not adjusted. |
| suyash | Inflation → GDP growth | Political stability | + Gov. effectiveness, Imports (still valid) | One variable closes both back doors. Imports is only on a back door, so harmless. |
| swasti | Youth NEETs → Net migration | Adolescent fertility, GDP, Youth unemployment | same | |
| tsering | Women's employment → Vulnerable employment | Youth NEETs | same | Per capita GDP is a **pipe**; Rural population is a **collider** (and marked latent). Both correctly left out. |

All seven projects' adjusted variables form a valid adjustment set for their own DAG.
For (e), push students to ask whether any control could be caused by X (for example,
whether internet use could affect electricity access, or corruption could affect
government effectiveness). For (f), look for: if missing data depends on both X and Y
(for example, poorer and less stable countries report less), dropping them is selecting
on a common effect.

## Part F (sample solution)

**F1.** Coefficient on `phones`: no control **−0.82**; `+ wealth` **−0.02**; `+ proxy_good`
**−0.24**; `+ proxy_bad` **−0.68**. The proxies are descendants of wealth. A good proxy
closes most of the fork, a poor one closes little. Only the true confounder closes it
fully.

**F2.** (a) Everyone: r = **−0.01**. Hospital patients (1,205 of them): r = **−0.57**.
(b) Among patients, **17%** of those with disease 1 also have disease 2, but **74%** of
those without disease 1 have disease 2. (In the whole population both are 10%.)
(c) If a patient doesn't have disease 1, something else put them in hospital, and that
is often disease 2. Hospital admission is the collider.

**F3.** Coefficient on `coaching`: no controls **0.29**; `+ kathmandu` **0.18**;
`+ kathmandu + wealth` **0.29**. The truth is 0.3. Controlling for Kathmandu alone biases
the estimate; adding wealth fixes it. This matches C2.

**F4.**

```r
library(dagitty)
c1 <- dagitty("dag {
  Remittances [exposure]
  Results [outcome]
  District -> Wealth
  District -> Results
  Wealth -> Remittances
  Wealth -> Results
  Remittances -> Results
  Remittances -> Tuition
  Tuition -> Results
  Remittances -> Boarding
  Results -> Boarding
}")
adjustmentSets(c1)                       # { Wealth }
adjustmentSets(c1, effect = "direct")    # { Tuition, Wealth }
isAdjustmentSet(c1, c("Wealth", "Boarding"))  # FALSE
```

For C2, mark Motivation as `[latent]`; for C3, mark Ability as `[latent]`, and
`adjustmentSets(c3, effect = "direct")` returns nothing.

## Part G

Open-ended. Look for a correctly drawn DAG, a correct label (fork, pipe or collider), and
a sensible judgement about whether the control helped or hurt.
