
## Data Lunch: Week 2 {#title}

- This week is about one idea: distributions. Say the word often. By the end, students should reach for it without being asked.
- A distribution is a different way to think about a number. Instead of one value, it's every value the number could take, and how common or plausible each one is.
- The week has three parts, one per kind of distribution: data (how values vary across cases), belief (how sure we are about an unknown), and relationships (how two variables vary together). The third uses the first two: a relationship is a pattern in the data, and we can be more or less sure about it.
- Each kind has its own color on the cards (blue, green, orange), and the same three cards come back at every part break and in the summary. Point at them.

## Think in distributions {#think-in-distributions}

- Read the sentence. It's true, and it's the kind of number a report would print.
- Then ask what it leaves out. Let students find answers before the cards appear.
- First, a population: real adults differ, from about 137 to 179 cm. "Average" describes the middle of a spread, not a person. How the heights vary is a distribution of data.
- Second, uncertainty: we measured 352 people. A different 352 would give a slightly different average. How sure we are about the true average is a distribution of belief.
- Third, a relationship: height doesn't vary on its own. Taller people tend to be heavier, but with plenty of exceptions. How the two vary together is the third kind.
- These are the three parts of today, in order. The big statement is the week in one line.

## Last week → this week {#last-week}

- Start from Week 1's thesis: a study is one observation, and a number means nothing without the assumptions we read it through. This week adds that a single number also hides variation and uncertainty, which is what the opening slide showed.
- The bridge from Week 1: the mayor's answer wasn't a number, it was a curve. Students already drew one when they made their prior.
- Name the key word and give the plain definition: every value a number could take, and how common or plausible each one is.
- Then name the three kinds, one per part. Distributions of data come first. Belief, the kind they met with the mayor, is second. Relationships are third.

## Goals this week: three kinds of distribution {#goals}

- Three parts, one per card. Parts 1 and 2 are the two basic kinds: data and belief. Part 3 puts two variables together and uses both: the pattern is in the data, and β gets a distribution of belief. Part 3 ends with how relationships mislead.
- These cards come back at every part break, with the current part highlighted.
- The house-price exercise is the appendix. They'll do it with the TA in the second session, using all three kinds.

## Part 1: Distributions of data {#part1}

- Section break. The first card: how a quantity varies across real cases.
- The tools in this part (center, spread, shape, the Normal, z-scores) are all ways of describing one distribution, or one case's place in it.

## Randomness has patterns {#randomness}

- The admissions example is a framing device, not a dataset we'll analyze. It names three ideas every statistical question has.
- Population: we're never asking about one application. We're asking about a group, and we have to say which group.
- Variation: the cases differ in ways we care about. Without variation there's nothing to explain.
- Randomness: we will never predict one admission decision perfectly. But a coin flipped 1,000 times is very predictable in aggregate. Random individuals, predictable populations. That's why distributions work.

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
- Real data are never perfectly Normal. The Normal is a description, a useful approximation, not a law. We'll see a clearly non-Normal distribution in the house prices.
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

## Part 2: Distributions of belief {#part2}

- Section break. The second card: not how real cases vary, but how plausible each value of something unknown is.
- Students met this kind last week with the mayor. This part shows it's an everyday way of talking, and that it uses the same shapes as Part 1.

## How old is he? A distribution of belief {#belief-distributions}

- Start with the photo. Ask the room: how old is he? Collect a few guesses. Nobody says one number with certainty. They say "about 40, maybe older." That sentence is a distribution.
- Walk through the four shapes. Uninformed: flat, every age equally plausible. Weakly informed: a wide hump around 40. Strongly informed: a narrow hump. Domain-specific: a plateau between 30 and 50, dropping off outside.
- The point: a distribution is just a picture of "how plausible is each value?" People reason this way all the time. We're drawing it.
- This is exactly what students did with the mayor's prior last week.
- Contrast with Part 1: there's only one man and one true age. Nothing varies here except how sure we are.

## Data or belief? {#two-kinds}

- An important distinction that trips people up later. Distributions of data describe how a quantity varies across real cases: the heights of actual people. Distributions of belief describe how plausible each value of an unknown is: the mayor's vote share. There's one true value; we just don't know it.
- A quick test: is there one true answer we're unsure about (belief), or many cases that really differ (data)? Try it on the examples.
- Same shapes, same vocabulary, same math. That's convenient, and also why they get confused.
- Part 3 needs both: a pattern in the data, and then how sure we are about it.

## Part 3: Distributions of relationships {#part3}

- Section break. The third card. So far, one variable at a time. Now two: how do height and weight vary together?
- This kind is built from the first two. The scatterplot is a distribution of data with two variables. Correlation and regression summarize it with one number. That number is unknown, so it gets a distribution of belief.
- The part ends with the ways relationships mislead: confounding and chance.

## Two variables at once {#correlation}

- Each variable has its own distribution of data, which Part 1 described. A scatterplot shows both at once: one dot per adult.
- Taller people tend to be heavier. The question is how strongly.
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
- Two groups: inside each group the relationship runs downhill, but the overall r is positive. Flag this one; it's the same shape as the bedrooms puzzle in the house exercise, and as confounding at the end of Part 3.
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
- Watch the wording: "goes with," not "causes." That word choice comes back at the end of Part 3.

## How sure are we about β? {#beta-posterior}

- β is an unknown, like the mayor's vote share. So we can have a prior and a posterior for it. This is the second card again, applied to a relationship.
- Two posteriors: one from 20 adults (wide) and one from all 352 (narrow). Same rule as last week: prior × likelihood → posterior.
- Small samples aren't invalid, they're just honest about being unsure. Keep this in mind for the noise example coming up.
- Part 3 now uses both kinds: the scatterplot is a distribution of data, and β has a distribution of belief.
- Pivot: these descriptions are real patterns. Next, how real patterns can still mislead.

## When patterns mislead: two headlines {#headlines}

- Everything so far describes relationships accurately. That's exactly the danger: an accurate description can still be read the wrong way.
- Read both headlines out loud, like a news anchor. Ask: do you believe them? Would you act on them?
- Both numbers are real: they come straight from the data in the next few slides. Nobody made an arithmetic mistake.
- If someone already spots the ice cream answer (hot weather), great. Ask about the second one instead. Nobody will have an answer for that one yet.
- By the end of Part 3, students should be able to say exactly why each one misleads.

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

- Point out that this histogram is itself a distribution: a distribution of r, showing how much a correlation varies by chance alone. It's the same uncertainty the wide β posterior showed with 20 adults.
- The histogram shows r for every pair of unrelated variables. With 20 cases, chance alone gives r values of ±0.5 and beyond. With 500 cases, they stay near 0.
- This is Week 1's problem again. Try enough comparisons and some will look significant. The base rate of real relationships in this dataset is zero, so every "discovery" is false.

## Telling the two apart {#telling-apart}

- Walk the table row by row. The most important row: would more data help? For chance, yes. For confounding, no.
- What helps against chance: bigger samples, deciding what to test before looking, replication. All things from Week 1.
- What helps against confounding: thinking about causes. Nothing in the data alone can do it. That's why next week is about causal models.
- The last bullet picks up how Week 1 ended: there are more fundamental ways to question our assumptions than the base rate paradox. Chance is Week 1's problem, and more data helps. Confounding is the first of the deeper ones, and more data doesn't.
- Week 5 comes back to this hard: more data won't save you from a confounder.

## Summary: three kinds of distribution {#summary}

- The definition, then one card per part. Read them slowly.
- Ask students to name the three kinds without looking, and give an example of each.
- The line to remember is the big statement: think in distributions, not single numbers.
- The relationships card's last line, a pattern is a description, not an explanation, ties back to last week (statistics is observation) and forward to next week's causal models.

## Next week {#next-week}

- Correlation and regression describe how things move together. They don't say why.
- To answer a causal question, like whether banning ice cream would prevent drownings, we need to write down what we think causes what. That's a DAG, next week.

## Practical work: What makes a house expensive? {#houses}

- Appendix for the TA session. It uses all three kinds on real data. Steps 1 and 2 are Part 1 (a distribution of data, and z-scores). Steps 3 to 5 are Part 3 (relationships), and it ends with a confounder like the ice cream example.
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
