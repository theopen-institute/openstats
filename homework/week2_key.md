# Week 2 Homework: Answer Key (instructor only)

This file is `.md`, not `.qmd`, so `quarto render` does not render or publish it.
Every number below was checked in R.

The !Kung numbers use the adults (age ≥ 18, n = 352) from `datasets/kungsan.csv`:
height mean 154.597, SD 7.742; weight mean 44.990, SD 6.457; *r* = 0.7547. Hand
calculations in Parts B and C use the rounded values given to students (154.6, 7.7,
45.0, 6.5, 0.75), so the exact-data answers can differ in the second decimal. Accept
either.

## Part A

**A1.** (a) One flip can't be predicted. With 1,000 flips we can say the number of heads
will very likely be close to 500. The randomness of each case averages out across
many cases. (b) Open-ended; for example, you can't say whether one bus will be late, but
you can say what share of buses on that route are usually late. (c) Population: !Kung
San adults in Howell's census (late 1960s). They vary in height, weight, age, and sex.

**A2.** Open-ended. Look for: (a) a flat line over a wide range, such as Rs 0–1,000;
(b) a wide hump centred on a guess, such as "about Rs 200, but could be quite a bit
more or less"; (c) a narrow spike, such as "almost certainly Rs 180–220"; (d) a flat
plateau with steep sides, such as "somewhere between Rs 150 and Rs 300, no idea where
in that range, but very unlikely outside it." The x-axis should be labelled in rupees.
The sentence and the sketch should match.

**A3.** (a) Data: real ages varying across voters. (b) Belief: one unknown parameter
(the vote share), with plausibility for each value. (c) Data. (d) Belief: β is a
parameter. (e) Data: 12 observed values.

**A4.** (a) Center: where a typical value is. Spread: how far a typical case is from the
center. Shape: the overall pattern, such as one hump or two, symmetric or with a long
tail. (b) **Spread** (village Y's household sizes are much more spread out). (c) It is
not one smooth hump. It has bumps and dips. Accept any reasonable cause tied to
history: years with more or fewer births (conflict, the 2015 earthquake, falling
fertility), people of working age migrating abroad, or people rounding their ages
when they report them. The deck leaves this as an open discussion question.

**A5.** (a) Mean = Rs 100,000; median = Rs 30,000. (b) The median. One very rich
household pulls the mean far above what four of the five households earn. (c) The mean
($180,796) is above the median ($160,000), so a few very expensive houses form a long
**right** tail that pulls the mean up.

**A6.**
a. False. It means 2 *standard deviations* below average, not 2 cm or 2 kg.
b. True. The mean, the SD, and each value all get multiplied by the same number, so the
   number cancels in (x − mean) / SD.
c. False. Only the axis labels change. The mean becomes 0 and the SD becomes 1.
d. False. *r* measures only straight-line agreement. A strong curve (plot S in A8) can
   have *r* = 0.
e. False. *r* is not a percentage of people. It is the average agreement of z-scores.
f. True. The size tells you the strength and the sign tells you the direction.
   |−0.8| > |0.5|.
g. True. (Lecture: "With standardized data and one predictor, the best β is exactly the
   correlation.")

**A7.** Look for: each person multiplies their height z-score by their weight z-score.
If they are on the same side of average on both (taller & heavier, or shorter &
lighter), the product is positive. If they are on opposite sides, it is negative. If
they are near average on either one, the product is near zero. *r* is (roughly) the
average of these votes, so a cloud in the two "agree" corners gives mostly positive
votes and a positive *r*.

**A8.** (a) P ≈ +0.9 (exact sample value 0.92), Q ≈ −0.5 (−0.56), R ≈ 0 (0.00),
S ≈ 0 (0.00). (b) R is a shapeless cloud: no relationship. S is a strong U-shaped curve:
a clear relationship, but not a straight line, so the votes on the left and right
cancel out. (c) *r* only measures straight-line agreement, so **always plot your data**.

**A9.** (a) In z-scores both variables have mean 0, so the best line passes through
(0, 0). The intercept is 0, which leaves only the slope. (b) The errors are the vertical
distances from each point to the line. A better line makes these errors smaller overall.
(c) Something like: "An adult who is a typical step (one SD) taller than average is, on
average, three-quarters of a typical step heavier than average." (d) With 20 people
there is less evidence, so many values of β fit the data almost equally well. The curve
is spread out. A wider curve means we are less sure what β is. With 352 people the data
rule out more values, so the curve is narrower.

## Part B

**B1.** (a) 154.6 ± 7.7 → **146.9 to 162.3 cm**. (b) 154.6 ± 15.4 → **139.2 to 170.0
cm**. (c) The real shares (65% and 96%; 65.3% and 96.0% exactly) are close to 68% and
95%, so the Normal is a reasonable description. Also check the histogram's shape (one
hump? symmetric?). Good answers note that the data mixes men and women. (d) About
**170 cm**. That is "unusual." Only about 1 in 20 people are more than 2 SD from the
mean on *either* side, so about 1 in 40 are taller than this. In the real data, 10 of
352 adults (2.8%) are 170 cm or taller.

**B2.** (a) (140 − 154.6) / 7.7 = **−1.90** (exact data: −1.89). (b) (38 − 45.0) / 6.5 =
**−1.08**. (c) She is more unusually **short**. Her height is almost 2 SD below average,
while her weight is only about 1 SD below.

**B3.** (a) 45.0 + 1.5 × 6.5 = **54.75 kg** (about 54.8). (b) 154.6 − 7.7 = **146.9 cm**.
(c) One SD is a different amount on each scale: 1 SD of height is 7.7 cm and 1 SD of
weight is 6.5 kg. z = 1 means "one typical step from average" on each scale, not the
same raw amount. (And cm and kg can't be compared anyway.)

**B4.** (a) Maths: 72 − 60 = 12 points above. English: 80 − 72 = 8 points. **Maths.**
(b) Maths z = 12 / 12 = **1.0**. English z = 8 / 4 = **2.0**. (c) **English.** The English
marks are bunched closely together (SD 4), so 8 points above average beats most of the
class. In Maths, 12 points above is quite ordinary because marks are more spread out.
Raw points ignore spread; z-scores don't.

**B5.** (a) Mean = **2 quintals**, SD = **0.4 quintals**. (b) Before: (260 − 200) / 40 =
**1.5**. After: (2.6 − 2) / 0.4 = **1.5**. The z-score is the same. (c) A z-score has no
units. It counts standard deviations, so the original units (kg, quintals, rupees, cm)
drop out.

## Part C

**C1.** (a)

| Student | z hours | z mark | Vote (product) |
|---------|---------|--------|----------------|
| A       | −1      | −1     | +1             |
| B       | −1      | −1     | +1             |
| C       | 0       | +1     | 0              |
| D       | +1      | 0      | 0              |
| E       | +1      | +1     | +1             |

(b) A, B, and E vote positive. C and D vote zero. (c) *r* = (1 + 1 + 0 + 0 + 1) / (5 − 1)
= 3/4 = **0.75**. R confirms: `cor(c(2,2,5,8,8), c(50,50,70,60,70))` = 0.75, and the
SDs are exactly 3 and 10. (d) C's vote is **zero**, because C is exactly average on
hours. C's high mark gives no evidence for or against "more hours, higher marks," so
it adds nothing to the sum, but it still counts in *n*. That pulls *r* below what a
perfect pattern would give.

**C2.** (a) β = *r* = 0.75: z~mark~ = 0.75 × z~hours~. (b) 0.75 × 10 / 3 = **2.5 marks per
hour** (R: `lm(mark ~ hours)` gives slope 2.5, intercept 47.5). (c) "Each extra hour of
study per week goes with about 2.5 more marks on the test." (d) No. Five students are
very little data, so a wide range of β values would fit almost as well (like the
20-adult curve in lecture). More students would make us more confident.

**C3.** (a) 0.75 × 6.5 / 7.7 = **0.63 kg per cm** (matches the lecture and
`lm(weight ~ height)`: 0.629). (b) 10 × 0.63 ≈ **6.3 kg**. (c) z~height~ =
(165 − 154.6) / 7.7 = **1.35** (the lecture shows 1.34 using exact values). Predicted
z~weight~ = 0.75 × 1.35 = **1.01**. In kg: 45.0 + 1.01 × 6.5 = **51.6 kg** (exact data:
51.5 kg). (d) He is **above** the line, by about 58 − 51.6 ≈ **6.4 kg** (in z-scores: 2.01
actual vs. 1.01 predicted, about 1 SD above the line).

**C4.** (a) By the same rule, the best slope for height on weight is also *r*:
z~height~ = **0.75** × z~weight~, not 1.33. (b) Predicted z~height~ = 0.75 × 2 = **1.5 SD**,
which is *less* than 2. Because the relationship isn't perfect, an extreme value on one
variable predicts a less extreme value on the other, whichever direction you go.
(Students may meet the name "regression to the mean" later. It is not needed here.)

## Part D

**D1.** (a) **2,930** houses. The histogram should show a long right tail. (b) Mean
**$180,796**, median **$160,000**, SD **$79,887**. (c) **38.3%** sold above the mean. The
long right tail pulls the mean above the middle, so fewer than half the houses are
above it. (d) Something like: "A typical house sells for about $160,000 (median). Prices
are widely spread (SD about $80,000). The shape has one hump with a long tail of a few
very expensive houses on the right."

**D2.** (a) The mean of each z column is 0 (R prints something like `-1.4e-16`) and the
SD is 1. (b) Cheapest: **$12,789**, z = **−2.10**. Most expensive: **$755,000**, z =
**+7.19**. (c) The right tail is long. Prices can't fall much below zero, but a few
houses sell for far more than average. (d) Within 1 SD: **78.3%**. Within 2 SD:
**95.4%**. More than 2 SD above: **4.6%**. More than 2 SD below: **0.07%** (2 houses). The
"within 2 SD" share happens to match 95%, but the Normal rule hides the lopsided shape.
Almost all the unusual houses are on the expensive side. Use the 68–95 rule only for
roughly symmetric, one-hump data.

**D3.** (a) Scatterplot: an upward cloud that fans out for larger houses. (b) *r* =
**0.71** (0.7068), matching the lecture. (c)

| Price     | Area (m²) | Neighborhood |
|-----------|-----------|--------------|
| $755,000  | 401       | Northridge   |
| $745,000  | 416       | Northridge   |
| $184,750  | 434       | Edwards      |
| $183,850  | 473       | Edwards      |
| $160,000  | 524       | Edwards      |

The three Edwards houses are off the pattern: huge, but cheap (house B from lecture is
the 524 m² one). Accept reasonable guesses about why, such as unusual sales or houses
that are not finished. (d) *r* rises from 0.707 to **0.727**, a small change. With 2,930
houses, three points are a tiny share of the votes. One extreme point matters much more
in a small dataset.

**D4.** (a) Open-ended. (b) Living area **0.71**, garage size **0.65**, year built **0.56**,
bathrooms **0.55**, lot area **0.27**, bedrooms **0.14**. Bedrooms (low) and lot area
(lower than people expect) usually surprise students. (c) *r* has no units. It is built
from z-scores, so it is the same kind of number for any pair of variables.

**D5.** (a) Slope = **0.707**, the same as *r*. The intercept is essentially 0. (b)
0.707 × $79,887 / 46.96 m² ≈ **$1,202 per m²**. `lm(price ~ area_m2)` gives slope 1,202.3
(intercept $13,286). (c) "Each extra square meter of living space goes with about
$1,200 more in sale price, on average." (d) 0.707 × $79,887 ≈ **$56,500** (1 SD of area is
about 47 m², and 47 × $1,202 gives the same answer).

**D6.** (a) *r* = **0.14**. (b) 798 houses are left. *r* = **−0.39**. Among houses of about
the same size, more bedrooms go with a *lower* price. (c) *r* = **0.52**. Houses with
more bedrooms tend to be bigger. (d) Look for: bedrooms come with size. Across all
houses, more bedrooms mostly means a bigger house, and bigger houses cost more. When you
compare houses of the *same* size, extra bedrooms mean the same space is cut into
smaller rooms (and maybe older or cheaper houses), and that doesn't add value. Do not
expect causal vocabulary. This sets up next week's DAGs.

## Part E (sample solution)

```r
library(tidyverse)
howell <- read_csv("datasets/kungsan.csv") |>
  select(-1) |>
  filter(age >= 18) |>
  mutate(
    z_height = (height - mean(height)) / sd(height),
    z_weight = (weight - mean(weight)) / sd(weight)
  )

# E1
sum(howell$z_height * howell$z_weight) / (nrow(howell) - 1)   # 0.7547
cor(howell$height, howell$weight)                              # 0.7547
coef(lm(z_weight ~ z_height, data = howell))                   # slope 0.7547

# E2 (after running the wb code from the homework)
wb |> arrange(life_exp) |> head(1)            # Central African Republic, 18.8
z <- function(x, v) (x - mean(v)) / sd(v)
nep <- filter(wb, code == "NPL")
z(nep$life_exp, wb$life_exp)                  # -0.38
wb2 <- filter(wb, code != "CAF")
z(nep$life_exp, wb2$life_exp)                 # -0.47
c(mean(wb$gdp_pc), median(wb$gdp_pc))         # 21,143 vs 7,656
cor(wb2$life_exp, wb2$fertility)              # -0.81
coef(lm(life_exp ~ fertility, data = wb2))    # -4.77 years per birth

# E3
set.seed(1)
r20  <- replicate(1000, with(slice_sample(howell, n = 20),  cor(height, weight)))
r100 <- replicate(1000, with(slice_sample(howell, n = 100), cor(height, weight)))
hist(r20); hist(r100)
```

**E1.** All three give **0.7547**.

**E2.** (a) **Central African Republic, 18.8 years**. That is impossible as a national
life expectancy. Every other country is above 53. (b) With all 209 countries: Nepal's
life expectancy (70.1) has z = **−0.38** and fertility (2.00) has z = **−0.33**. Without
CAR (208 countries): life z = **−0.47** and fertility z = **−0.32**. The life-expectancy
z-score changes more. The bad value sits in that variable, where it drags the mean down
(73.1 → 73.4 without it) and inflates the SD (7.94 → 7.01). Fertility is barely
affected. (c) Mean **$21,143** vs. median **$7,656**: a long right tail of a few very
rich countries. (d) *r* = **−0.81** (−0.80 with CAR included). Countries where women have
more children tend to have much lower life expectancy. (e) β in z-scores = −0.81;
in real units −0.81 × 7.01 / 1.20 ≈ **−4.8 years per extra birth per woman**
(`lm` gives −4.77; with CAR included, −5.21). This describes how the two move together
across countries. It does not show that one causes the other. Both are linked to other
things, such as income, health care, and education, and the comparison is between
countries, not about what would happen inside Nepal if fertility changed. Accept any
clear version of "correlation describes *how*, not *why*."

**E3.** Results vary with the random seed. With `set.seed(1)`: for n = 20, the SD of
*r* is about **0.11**, the middle 95% runs from about **0.49 to 0.90**, and single samples
range from 0.21 to 0.96. For n = 100, the SD is about **0.04** and the middle 95% is about
**0.67 to 0.82**. Small samples give a wide spread of possible answers, just as the
20-adult curve for β was wider than the 352-adult curve.

## Part F

**F1.** Open-ended. Look for: two clearly named variables, an honest guess at the
shape, at least one mention of what a single correlation can miss (curve, extreme case,
groups), and a comment on whether the story slides from "goes with" to "causes."

**F2.** Open-ended. Look for: a center, a sense of spread, and a shape (for example,
"income has a long right tail, so the median is more typical than the mean").
