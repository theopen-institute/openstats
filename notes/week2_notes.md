
## Data Lunch: Week 2 {#title}

- Last week was about what a single study can and can't tell us. This week is about the most common thing studies report: patterns. Distributions, correlations, coefficients.
- The tools are useful. The punchline is about their limits: a pattern is a description, not an explanation.

## Two headlines {#headlines}

- Read both headlines out loud, like a news anchor. Ask: do you believe them? Would you act on them?
- Both numbers are real in the sense that they come straight from the data on the screen later today. Nobody made an arithmetic mistake.
- Don't explain yet. The point is to leave the question open: both patterns are there, and neither means what it says. We come back to them at the start of Part 2.
- If someone already spots the ice cream answer (hot weather), great. Ask them to hold onto it, and ask about the second one instead. Nobody will have an answer for that one.

## Last week → this week {#last-week}

- Connect the two weeks in one sentence: last week, a study is one observation, not an answer. This week, a pattern in our observations is a description, not an explanation.
- Then the practical connection. The mayor's answer wasn't a number, it was a distribution. So we need to get comfortable reading distributions before we can do anything else.

## Goals this week {#goals}

- Part 1 is the toolkit. Part 2 is where the toolkit misleads us, and what protects us.
- The house-price exercise is the appendix. They'll do it with the TA in the second session, using everything from Part 1.

## Part 1: Describing patterns {#part1}

- Section break. Part 1 builds four tools in order, each one using the last: distributions, z-scores, correlation, regression.

## Randomness has patterns {#randomness}

- The admissions example is a framing device, not a dataset we'll analyze. It names three ideas every statistical question has.
- Population: we're never asking about one application. We're asking about a group, and we have to say which group.
- Variation: the cases differ in ways we care about. Without variation there's nothing to explain.
- Randomness: we will never predict one admission decision perfectly. But a coin flipped 1,000 times is very predictable in aggregate. Random individuals, predictable populations. That's why distributions work.

## Probability distributions {#belief-distributions}

- Start with the photo. Ask the room: how old is he? Collect a few guesses. Nobody says one number with certainty. They say "about 40, maybe older." That sentence is a distribution.
- Walk through the four shapes. Uninformed: flat, every age equally plausible. Weakly informed: a wide hump around 40. Strongly informed: a narrow hump. Domain-specific: a plateau between 30 and 50, dropping off outside.
- The point: a distribution is just a picture of "how plausible is each value?" People reason this way all the time. We're drawing it.
- This is exactly what students did with the mayor's prior last week.

## Two kinds of distributions {#two-kinds}

- An important distinction that trips people up later. Distributions of data describe how a quantity varies across real cases: the heights of actual people. Distributions of belief describe how plausible each value of an unknown is: the mayor's vote share.
- Same shapes, same vocabulary, same math. That's convenient, and also why they get confused.
- Today starts with data distributions and ends, with β, on a belief distribution.

## A distribution of data: Nepal's population {#nepal-population}

- A familiar data distribution: the age pyramid. Ask: what do you notice? Why the bumps?
- Likely discussion points: the base is narrowing because birth rates have fallen a lot. And there are fewer men than women in the working ages, because so many men work abroad. Let students propose these.
- The point is that a distribution's shape carries history. Reading shapes is a skill.

## Our running example: the !Kung San {#kung}

- Introduce the data: Nancy Howell's census of the !Kung San, late 1960s. 352 adults. It's the same dataset McElreath uses, so students who read *Statistical Rethinking* will recognize it.
- We use it because it's small, clean and about people, and height and weight are easy to reason about.
- Worth a sentence of context: this is ethnographic fieldwork producing numbers. The line between "qualitative" and "quantitative" research was never sharp.

## Describing a distribution {#describing}

- Three words that describe any distribution: center, spread, shape.
- Center: the mean, about 155 cm. Spread: the standard deviation, about 7.7 cm, the shaded band. A typical adult is within about 8 cm of average.
- Shape: one hump, roughly symmetric. Ask: what would two humps mean here? (Probably mixing men and women.) What would a long tail mean?

## The Normal distribution {#normal}

- The blue curve is a Normal distribution with the same mean and SD as the data. It fits well.
- Two numbers describe the whole shape. That's the Normal's main attraction.
- Real data is never perfectly Normal. It's a description, a useful approximation, not a law. We'll see a clearly non-Normal distribution in the house prices.
- The formula on the slide is just notation for "height follows a Normal with this mean and SD." Same notation as the mayor's model.

## The 68–95–99.7 rule {#rule-68-95}

- For a Normal distribution: about 68% of cases within 1 SD, 95% within 2 SD, 99.7% within 3 SD.
- Check it against the !Kung data. It's close. That's a good habit: check a rule of thumb against your actual data.
- This rule is why "2 standard deviations" comes up so often, including in the "estimate ± 2 × standard error" rule students will meet in Week 5.

## Distributions Demo {#dist-demo}

- Interactive. Pick a distribution family and move the sliders. Start with the Normal: change the mean (the curve slides), change the SD (it stretches).
- Then show one or two other shapes so students see that not everything is a bell curve: a skewed one, a bounded one.
- Don't teach the families. The point is that a few numbers control a shape, and different situations call for different shapes.

## Standardized values (z-scores) {#z-scores}

- Pose the puzzle: is this man more unusually tall or more unusually heavy? Let them try. Centimeters and kilograms can't be compared directly.
- The trick: measure both in "standard deviations from average." Now they're on the same ruler.
- He is more unusually heavy than tall.

## Same data, new ruler {#new-ruler}

- The two histograms have the same shape. Only the axis labels change. Standardizing doesn't change the data, only the units.
- The mean becomes 0 and the SD becomes 1. The units disappear.

## Reading z-scores {#reading-z}

- A quick reference table. 0 is average, ±1 is ordinary, ±2 is unusual (about 1 in 20), ±3 is rare (about 1 in 370).
- The R code is one line. Students don't need to memorize it.
- Real uses: comparing exam marks on different scales, or prices in different currencies.

## Correlation {#correlation}

- Raw scatterplot of height and weight. Taller people tend to be heavier. The question is how strongly.
- Ask the room to guess a number from 0 to 1 before we compute it.

## Standardize both variables {#standardize-both}

- Same scatterplot, now in z-scores, split into four quadrants at the averages.
- Points in the top-right and bottom-left are on the same side of average for both variables. Points in the other two quadrants are on opposite sides.
- Most points are in the "same side" quadrants. That's what a positive relationship looks like.

## Correlation is average agreement {#average-agreement}

- Mechanics slide. The formula says: multiply each person's two z-scores, then average.
- The plain-language version is what matters: each person votes. Same side of average on both is a positive vote. Opposite sides is a negative vote. r is the average vote.
- Properties worth remembering: always between −1 and +1, no units, and it doesn't care whether you measure in cm or inches.

## What does *r* look like? {#r-gallery}

- Build intuition. Six scatterplots from r = −0.8 to 0.9.
- Ask: where would our height and weight (r = 0.75) sit? Strong, but far from perfect.
- Note that r = 0.3 looks like almost nothing to the eye, yet it's a relationship many papers would report.

## What correlation misses {#cor-misses}

- Three datasets where r badly misdescribes the relationship.
- A curve: a strong, clear relationship with r near 0, because r only measures straight-line agreement.
- One extreme point: 30 unrelated points plus a single outlier, and the outlier alone creates a large r.
- Two groups: inside each group the relationship runs downhill, but the overall r is positive. Flag this one; it's the same shape as the bedrooms puzzle in the house exercise, and as confounding in Part 2.
- The lesson: always plot your data before trusting one number.

## Regression: our first coefficient {#regression}

- In z-space, a line through the middle of the cloud needs one parameter: its slope, β.
- Show the candidate lines. Ask: which describes the data best? Students will pick the right one by eye. Then ask: what does "best" mean?

## The best line {#best-line}

- The red segments are the errors: how far each person is from the line.
- The best line makes the errors as small as possible overall (technically, the sum of squared errors).
- The neat fact: with standardized data and one predictor, the best slope is exactly the correlation. β = r.

## Reading the coefficient {#reading-coef}

- Mechanics slide. Two ways to read the same β.
- In z-scores: one SD taller goes with r SDs heavier.
- In real units: convert back by multiplying by SD of weight and dividing by SD of height. About 0.6 kg per cm.
- Watch the wording: "goes with," not "causes." That word choice comes back in Part 2.

## β is a parameter, so it has a distribution {#beta-posterior}

- This connects Part 1 back to Week 1. β is an unknown, like the mayor's vote share. So we can have a prior and a posterior for it.
- Two posteriors: one from 20 adults (wide) and one from all 352 (narrow). Same rule as last week: prior × likelihood → posterior.
- Small samples aren't invalid, they're just honest about being unsure. Keep this in mind for the noise example in Part 2.
- We just moved from a distribution of data to a distribution of belief.

## Part 1: Summary {#part1-summary}

- Quick recap of the four tools. Check for questions before Part 2.
- Pivot: we now have tools to describe patterns. Next, how patterns fool us.

## Part 2: When patterns mislead {#part2}

- Back to the two headlines from the start. Put them up again mentally: ice cream and drownings, and the two country indicators.
- Both patterns are real. By the end of Part 2, students should be able to say exactly why each one misleads.

## Spurious correlations {#spurious}

- Definition: a real pattern in the data that does not mean one variable affects the other.
- Two ways to get one. Confounding: a third variable drives both. Chance: noise happens to line up.
- They behave very differently, and they have different fixes. That difference is the core of today.

## Kind 1: Does ice cream cause drowning? {#ice-cream}

- First headline. One year of simulated daily data. More ice cream sales go with more drownings.
- Ask: should the town ban ice cream? Let them laugh, then ask what's really going on.

## The confounder: temperature {#temperature}

- Hot days bring both ice cream and swimmers. Temperature is the confounder.
- Split the days by temperature and the relationship mostly disappears. Comparing like with like is the basic move against confounding.
- The key line: more data would not help. A million days would show the same strong r. The pattern is stable; it's just not about ice cream.
- Mention that a confounder can also hide or flip a relationship. They'll see a flip in the house exercise.

## Kind 2: Correlations from pure noise {#noise}

- Second headline. Reveal: it was pure noise. 50 made-up variables for 20 made-up countries, every value random. Nothing is related to anything.
- With 1,225 possible pairs, the strongest one has r = 0.70. Put names on those two variables and it's a headline.
- Ask: how many real studies look at many variables and report the strongest?

## Small samples and many comparisons {#small-samples}

- The histogram shows r for every pair of unrelated variables. With 20 cases, chance alone gives r values of ±0.5 and beyond. With 500 cases, they stay near 0.
- This is Week 1's problem again. Try enough comparisons and some will look significant. The base rate of real relationships in this dataset is zero, so every "discovery" is false.

## Telling the two apart {#telling-apart}

- Walk the table row by row. The most important row: does more data help? For chance, yes. For confounding, no.
- What helps against chance: bigger samples, deciding what to test before looking, replication. All things from Week 1.
- What helps against confounding: thinking about causes. Nothing in the data alone can do it. That's why next week is about causal models.
- Week 5 comes back to this hard: more data won't save you from a confounder.

## Summary {#summary}

- Four points, one per idea. Read them slowly.
- The line to remember: a pattern is a description, not an explanation.
- Tie it to last week: statistics is observation. Patterns are observations too.

## Next week {#next-week}

- Correlation and regression describe how things move together. They don't say why.
- To answer a causal question, like whether banning ice cream would prevent drownings, we need to write down what we think causes what. That's a DAG, next week.

## Practical work: What makes a house expensive? {#houses}

- Appendix for the TA session. Everything here applies Part 1 to real data, and ends with a confounder from Part 2.
- Let students drive. Each step has a question to answer before the reveal.

## The data: house sales in Ames, Iowa {#houses-data}

- 2,930 house sales in Ames, Iowa, 2006–2010, compiled by Dean De Cock (2011) for teaching. Prices in US dollars, areas converted to m².
- It's a US college town, so it's not Nepal. Ask what might be different about a housing market here.

## Step 1: Look at the distribution {#houses-step1}

- Not Normal: a long right tail of a few very expensive houses.
- The tail pulls the mean (about $181,000) above the median ($160,000). Ask: which is the typical price? For skewed data, usually the median.
- This is why "always plot first" matters. A mean and SD alone would hide the tail.

## Step 2: How unusual is this house? {#houses-step2}

- Students compute z-scores for two houses: A, the most expensive, and B, the largest.
- Let them work it out with the means and SDs in the table before revealing the answer.
- The question "in what way is it unusual?" matters: a house can be ordinary in price but extreme in size.

## Step 3: Price and living area {#houses-step3}

- r is about 0.71. Bigger houses sell for more, with plenty of scatter.
- House B, the largest, sits far below the pattern. Ask what might explain it. Good guesses: an unusual sale, a family sale, a house sold unfinished. De Cock's documentation flags the very largest houses as unusual sales that don't reflect market value.
- Lesson: an outlier is a question about how the data were made, not just a nuisance.

## Step 4: Guess first {#houses-guess}

- Have everyone rank the six features before looking. Write a few rankings on the board.
- Guessing first makes the result stick, and shows people how good or bad their intuitions are.

## Step 4: The correlations {#houses-correlations}

- Living area is strongest (about 0.71), then garage size (0.65), year built (0.56), bathrooms (0.55), lot area (0.27), and bedrooms last (0.14).
- Bedrooms near the bottom usually surprises people. Hold that thought for the puzzle.
- Because r has no units, we can compare m², cars, years and rooms on one scale.

## Step 5: One coefficient {#houses-coef}

- Mechanics slide. Same as the height and weight coefficient, now for price and living area.
- In z-scores: one SD more space goes with about 0.71 SD higher price. In dollars per m², convert with the SDs.
- Again: "goes with," not "adds." That distinction is the next slide.

## A puzzle: bedrooms {#bedrooms-puzzle}

- Overall, more bedrooms go with a higher price. But among medium and large houses of similar size, more bedrooms go with a lower price.
- Let students argue about how both can be true before moving on.

## Solving the bedrooms puzzle {#bedrooms-solved}

- It's a confounder, exactly like temperature. Living area drives both bedrooms and price.
- Holding size fixed, an extra bedroom means smaller rooms, which buyers pay less for.
- A confounder flipped the sign of a relationship. That's the strongest version of "a pattern is a description, not an explanation."
- The causal question, whether adding a bedroom makes a house more valuable, needs a causal model. That's Week 3.
