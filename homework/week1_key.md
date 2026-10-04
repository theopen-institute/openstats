# Week 1 Homework: Answer Key (instructor only)

This file is `.md`, not `.qmd`, so `quarto render` does not render or publish it.
Every number below was checked in R.

## Part A

**A1.** Probability is a way of describing uncertainty: how strongly we believe
something, on a 0–1 scale. A Bayesian reads "probably open" as "I'm not sure, but from
what I know, open is more plausible than closed." A frequentist reads it as a long-run
frequency: if you checked in many repeated, similar situations, the shop would be open
most of the time.

**A2.** (a) P(cancer | smoker) = 0.15. (b) P(smoker | cancer) = 0.85. (c) P(win | leading
at halftime) = 0.70. (d) P(from Kathmandu) = 0.40, with no condition (or "| student
here"). (a) and (b) can both be true because the conditioning sets are different groups.
Most smokers never get lung cancer, but lung cancer is rare and is concentrated among
smokers. This is the same reversal as the HIV and Sociology/Economics examples.

**A3.** (a) A p-value is P(data at least this extreme | null hypothesis true). (b) The
classmate thinks it is P(hypothesis wrong | data), or equivalently P(null | data).
(c) The p-value assumes the null is true and asks how surprising the data would be. It
says nothing directly about how likely the hypothesis is, because that depends on the
base rate (prior). This is P(A|B) versus P(B|A).

**A4.** Sensitivity = P(test+ | HIV+). Specificity = P(test– | HIV–). Type I error =
P(test+ | HIV–). Type II error = P(test– | HIV+). The patient cares about P(HIV+ | test+),
which is not one of the four.

**A5.** Look for: most tested hypotheses are false (low base rate). Even with a 5%
false positive rate, 5% of a very large pool of false hypotheses outnumbers 80% (or
less, with low power) of a small pool of true ones. So most significant results are
false positives. This follows from arithmetic on the base rate, power, and α, and needs
no data from actual studies. Extra credit for mentioning that low power and p-hacking
make it worse.

**A6.**
a. False. For someone who tests positive, accuracy depends on prevalence. At 0.1%
   prevalence, P(HIV+ | test+) ≈ 9%.
b. True. By Bayes, P(A|B) = P(B|A)·P(A)/P(B), so the ratio P(A)/P(B) = 1 cancels.
c. True. The posterior is proportional to prior × likelihood, and 0 × anything = 0.
   (This is why we avoid zero priors on things that are merely unlikely.)
d. True. False positives fall tenfold (in C4d, 14% → 62%).
e. False. Science works by accumulating and debating evidence over time (updating). A
   single finding is one observation, not the final word.

**A7.** (a) Prior: probably a cold. Observation: the X-ray shadow. Posterior: pneumonia
more likely. (b) Prior: about 30 minutes. Observation: three 50-minute trips.
Posterior: the trip takes longer than you thought. (c) The posterior is a compromise
between the prior and the data, weighted by how strong each is. It would move closer to
30% with a larger or better survey, or with a weaker or less confident prior.

## Part B

**B1.** (a) 186/365 = 0.51. (b) 13/179 = 0.073. (c) P(rain | April) = 0.43, while
P(April | rain) = 0.073. The first divides by April days (30); the second divides by all
rainy days (179), and most rainy days are not in April. (d) 31/179 = 0.17. Every July day
is rainy, but July holds only 31 of the 179 rainy days.

**B2.** (a) 540/640 = 0.844. (b) 300/540 = 0.556. (c) 300/320 = 0.9375. (d) 100/640 =
0.156. (e) 0.25 × 0.5 / 0.15625 = 0.80.

**B3.** Open-ended. Check that the table's margins add up and that the two conditional
probabilities use the correct denominators.

## Part C

**C1.**
a. Of 100,000 people: 100 HIV+ → 99 test+. 99,900 HIV– → 2,997 test+.
   99 / 3,096 = **3.2%**.
b. 5% prevalence: TP = 4,950, FP = 2,850 → **63.5%**.
c. Specificity 99.9%: TP = 99, FP = 99.9 → **49.8%**.
d. Both help a lot. Raising prevalence (from 3% to 63%) helped more than improving the
   test (from 3% to 50%). Base rates dominate. Either way, the key move is cutting the
   number of false positives relative to true positives.
e. 96,903 / 96,904 = **0.99999**. A negative result is very reassuring.

**C2.** Use 3.2% as the new prior. Of the 3,096 people who tested positive the first
time: 99 × 0.99 = 98.0 true positives and 2,997 × 0.03 = 89.9 false positives →
98.0 / 187.9 = **52%**. (The independence assumption is doing work here. Real repeat
tests often have correlated errors.)

**C3.** (a) Of 1,000 essays: 100 AI → 95 flagged; 900 human → 18 flagged. 95/113 = **84%**.
(b) 20 AI → 19 flagged; 980 human → 19.6 flagged. **49%**, a coin flip.
(c) "95% accurate" is P(flag | AI), but the question is P(AI | flag). That depends on
how common AI essays are. When few students cheat, many flags land on honest students.

**C4.** (Lecture baseline: 80 / 575 = 13.9%.)

| Case | TP  | FP     | P(true \| sig) |
|------|-----|--------|----------------|
| a    | 50  | 495    | **9.2%**       |
| b    | 800 | 450    | **64%**        |
| c    | 80  | 1,980  | **3.9%**       |
| d    | 80  | 49.5   | **62%**        |

The base rate (b) and α (c, d) matter much more than power (a). In practice: test more
plausible hypotheses (build on theory and prior evidence), use stricter thresholds,
preregister to prevent p-hacking, and replicate.

**C5.** 0.8b = 0.05(1 − b) → 0.85b = 0.05 → b = 0.0588, about **5.9%**.

## Part D

**D1.** (a) 0.1 each. (b) 0 blue, since a bag with no blue stones cannot produce blue.
(c) 9 blue (all blue) is also ruled out.

**D2.** (a) (k/9)²·(1 − k/9), or (k/9)·((9−k)/9)·(k/9). (b) Ways = k²(9 − k); total = 540.

| k | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|---|
| Ways | 0 | 8 | 28 | 54 | 80 | 100 | 108 | 98 | 64 | 0 |
| Posterior | 0 | .015 | .052 | .100 | .148 | .185 | **.200** | .181 | .119 | 0 |

(c) k = 6, with probability 0.20. Three draws are not much data, and several nearby bags
(5, 7) explain the data almost as well.

**D3.** No. Multiplication does not depend on order: k·(9−k)·k = (9−k)·k·k. Only the
counts of each color matter (with replacement).

**D4.** (a) Multiply the D2 posterior by k/9 and normalize. Ways = k³(9 − k), total = 2,892.

| k | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| Posterior | .003 | .019 | .056 | .111 | .173 | .224 | **.237** | .177 |

The most plausible bag shifts to k = 7. (b) The answer is identical. Updating one draw
at a time gives the same result as updating on all the data at once, so there's no need
to "start over" when new data arrives. Yesterday's posterior is today's prior.

**D5.** Ways: 3 blue → 3·3·6 = 54; 6 blue → 6·6·3 = 108. P(6 blue) = 108/162 = **2/3**.

**D6.** Open-ended. Look for: the distribution narrows and the top probability rises
with more draws. Early on, the leading bag often isn't the true one. Small samples can
point strongly in the wrong direction.

## Part E (sample solution)

```r
p_true_given_sig <- function(base_rate, power, alpha) {
  power * base_rate / (power * base_rate + alpha * (1 - base_rate))
}

library(ggplot2)
grid <- expand.grid(base_rate = seq(0.001, 0.5, length.out = 200), power = c(0.5, 0.8))
grid$ppv <- with(grid, p_true_given_sig(base_rate, power, 0.05))
ggplot(grid, aes(base_rate, ppv, color = factor(power))) + geom_line()

k <- 0:9
posterior <- rep(1 / 10, 10)
for (d in c("blue", "black", "blue", "blue")) {
  lik <- if (d == "blue") k / 9 else 1 - k / 9
  posterior <- posterior * lik / sum(posterior * lik)
}
round(posterior, 3)
```
