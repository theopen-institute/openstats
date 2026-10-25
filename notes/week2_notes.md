
## Data Lunch: Week 2 {#title}

- This week is about one idea: distributions. Say the word often. By the end, students should reach for it without being asked.
- A distribution is a different way to think about a number. Instead of one value, it's every value the number could take, and how common or plausible each one is.
- Three kinds, one per part: population distributions (how cases vary), certainty distributions (how sure we are about something we don't know), and correlative distributions (how one thing's distribution moves with another). Each has its own color, all week: blue, green, orange. The same three cards come back at every part break and in the summary. Point at them.
- The thread from Week 1: randomness and uncertainty aren't a nuisance to get rid of. They're what statistics is about. Last week: a probability measures how sure we are. This week: a single number hides a crowd, and how sure we are about it is a distribution too.
- The deck ends with a preview of Week 3: add one variable to a model, and the coefficients for the others change. It appears twice: sex, height and weight at the end of Part 3, and bedrooms in the house prices.

## The average pilot {#average-pilot}

- Tell it as a story. Around 1950, US Air Force pilots kept losing control of their planes. It wasn't pilot error, and it wasn't the machines.
- Click: the cockpits had been designed in 1926, to fit the average pilot of the time. The first theory was that pilots had grown since then.
- Click: so a young lieutenant, Gilbert Daniels, measured 4,063 pilots on 140 body dimensions, and picked the ten that mattered most for a cockpit. The plan was to find the new average and rebuild for it.
- Click: ask the room before the reveal. How many pilots were within the middle 30% on all ten? Take guesses. Most people say a few hundred, or ten percent.
- Click, click: zero. Not one of 4,063. Even on just three dimensions, fewer than 3.5% were average on all three.
- The cockpit for the average pilot fit nobody. The average describes the crowd, but nobody in the crowd has to match it.
- Click: the fix. The Air Force made the manufacturers build cockpits that fit the range of pilots, not the middle: adjustable seats, pedals and helmet straps. That's thinking in distributions instead of averages. Every car has an adjustable seat now.
- If someone asks how "average" was defined: Daniels counted a pilot as average on a dimension if they fell in the middle 30% of the range. The story is from his 1952 technical note, and Todd Rose tells it at the start of *The End of Average* (2016).

## You already think in distributions {#commute}

- Same move as Week 1's "You already understand probability": they already do this, nobody has told them what it's called.
- Ask someone in the room how long their trip here takes. Someone will say "usually about 30 minutes," or "it depends."
- Click: "Usually 30 minutes." That's not one number. It's a summary of a lot of trips.
- Click, first card: "usually" means not every trip. Some take 20 minutes, some 45. How trips vary is a population distribution: many cases, each different.
- Click, second card: how do you know? You've done it a hundred times. Someone who's done it twice would say "about half an hour, I think," and could be quite wrong. How sure you are is a certainty distribution.
- Click, third card: what if it rains? Then the whole spread shifts: everything gets slower, and less predictable. A distribution that moves with something else is a correlative distribution.
- Click: they already think in all three. This week we draw them, and use them.

## This week's goals {#goals}

- Three kinds of distribution, one per part. Population first, then certainty (they met one last week: the mayor's posterior), then correlative.
- The second goal is the preview of next week: adding a variable to a model changes what the other numbers mean. It comes at the end of Part 3 and again in the house prices.
- The house-price example is the appendix, for the TA session.
- Last click: the definition. Every value a number could take, and how common or plausible each one is. "Common" is for population distributions, "plausible" for certainty distributions.

## Part 1: Population distributions {#part1}

- Section break. The first card: how a quantity varies across real cases.
- Everything in this part (the Galton board, center, spread and shape, the Normal, z-scores) is a way of describing one population distribution, or one case's place in it.

## Random individuals, predictable crowds {#galton}

- This is a Galton board, after Francis Galton, who built one in the 1870s. At every peg, a ball bounces left or right with equal chance: a coin flip.
- Start with 4 rows. Drop one ball. Ask: where will the next one land? Nobody knows. Drop a few more, one at a time.
- Tick "Count the paths." The numbers under the bins, 1, 4, 6, 4, 1, are the garden of forking paths from Week 1: four coin flips, and the number of ways to get each number of heads. A ball that bounces right twice can do it 6 ways; all the way right, only 1. The middle bins have more paths, so more balls end up there.
- Drop 100, then 1,000. The bars fill in the dashed outline: the shape the counting predicts.
- Now set 12 or 14 rows, empty the bins, and drop 1,000. A bell. Drop another 1,000: the same bell.
- The line on the slide is the week's foundation: one ball is anyone's guess, a thousand make the same shape every time. Random individuals, predictable crowds. That's why statistics works at all. We can't predict one admission, one patient, one voter. We can describe the crowd, sometimes very precisely.
- Say it once: randomness isn't the opposite of pattern. Randomness has patterns.

## A shape tells a story {#nepal-population}

- A familiar population distribution: Nepal's age pyramid. Ask: what do you notice? Why the bumps?
- Likely discussion points: the base is narrowing because birth rates have fallen a lot. And there are fewer men than women in the working ages, because so many men work abroad. Let students propose these.
- The point is that a distribution's shape carries history. A single number, the average age, would hide all of it.

## Our running example: the !Kung San {#kung}

- Introduce the data: Nancy Howell's census of the !Kung San, late 1960s. 352 adults. It's the same dataset McElreath uses, so students who read *Statistical Rethinking* will recognize it.
- We use it because it's small, clean and about people, and height and weight are easy to reason about.
- Worth a sentence of context: this is ethnographic fieldwork producing numbers. The line between "qualitative" and "quantitative" research was never sharp.

## Center, spread, shape {#describing}

- Three words that describe any population distribution: center, spread, shape.
- Center: the mean, about 155 cm. Spread: the standard deviation, about 7.7 cm, the shaded band. A typical adult is within about 8 cm of average.
- Shape: one hump, roughly symmetric. Ask: what would two humps mean here? Hold the answer for the next slide.

## One hump or two? {#two-humps}

- The answer to the last question: this one distribution is really two, women and men. The dashed line is everyone; the colors are the two groups inside it.
- Click: the men are about 11 cm taller on average. But look at the overlap. Many women are taller than many men. "Men are taller" is a statement about two distributions, not about every man and every woman.
- Flag it: this comes back at the end of Part 3. Men are also heavier. The question there is whether that's because they're men or because they're taller.

## The Normal distribution {#normal}

- The blue curve is a Normal distribution with the same mean and SD as the data. It fits well.
- Click: two numbers describe the whole shape. That's the Normal's main attraction.
- Connect it to the Galton board: when many small, random pushes add up (genes, nutrition, childhood illness, all nudging height up or down), you tend to get a bell. That's why the Normal turns up so often.
- Real data are never perfectly Normal. The Normal is a description, not a law. The house prices in the appendix are clearly not Normal.

## The 68–95–99.7 rule {#rule-68-95}

- For a Normal distribution: about 68% of cases within 1 SD, 95% within 2 SD, 99.7% within 3 SD.
- Click: check it against the !Kung data. It's close. That's a good habit: check a rule of thumb against your actual data.
- "Within 2 SD" comes back in Part 2: it's how we'll say how sure we are.

## Distributions Demo {#dist-demo}

- Interactive. Pick a distribution family and move the sliders. Start with the Normal: change the mean (the curve slides), change the SD (it stretches).
- Then show one or two other shapes so students see that not everything is a bell curve: a skewed one, a bounded one.
- Don't teach the families. The point is that a few numbers control a shape, and different situations call for different shapes.

## Taller or heavier? {#z-scores}

- Pose the puzzle and let them try. Centimeters and kilograms can't be compared directly.
- Click: the trick is to measure both in "standard deviations from average." Now they're on the same ruler.
- Click: the arithmetic. Click: he is more unusually heavy than tall.
- A z-score is a population-distribution idea: it places one case in the crowd.

## Same data, new ruler {#new-ruler}

- The two histograms have the same shape. Only the axis labels change. Standardizing doesn't change the data, only the units.
- The mean becomes 0 and the SD becomes 1. The units disappear.

## Reading z-scores {#reading-z}

- A quick reference table. 0 is average, ±1 is ordinary, ±2 is unusual (about 1 in 20), ±3 is rare (about 1 in 370).
- The R code is one line per variable. Students don't need to memorize it; the homework uses it.
- Click: the takeaway of Part 1, back to the pilots. An average is one point, the center of a distribution. The distribution describes everyone.

## Part 2: Certainty distributions {#part2}

- Section break. The second card: not how real cases vary, but how sure we are about something we don't know.
- Students met this kind last week: the mayor's prior and posterior were certainty distributions. This part shows it's an everyday way of talking, and how it differs from Part 1.

## How old is he? {#belief-distributions}

- Start with the photo. Ask the room: how old is he? Collect a few guesses. Nobody says one number with certainty. They say "about 40, maybe older." That sentence is a distribution.
- Walk through the four shapes, one click each. Uninformed: flat, every age equally plausible. Weakly informed: a wide hump around 40. Strongly informed: a narrow hump. Domain-specific: a plateau between 30 and 50, dropping off outside.
- The point: a certainty distribution is a picture of "how plausible is each value?" People reason this way all the time. We're drawing it, exactly as students drew the mayor's prior last week.
- Contrast with Part 1, and say it slowly: there's only one man and one true age. Nothing varies here except how sure we are. The curves are in green for that reason.

## How sure can a few people make us? {#sample-mean}

- The key slide of Part 2: the two kinds side by side, on one axis.
- Set it up: pretend these 352 adults are everyone, and we can only afford to measure a few. What's the average height?
- Start with 5. The top shows the five people we measured (blue dots), against everyone (gray). That's a population distribution: how the people we measured vary. The bottom shows how sure we are about the average height: a certainty distribution.
- Click "Measure new people" a few times. Each sample gives a slightly different guess, and the green curve jumps around. The old curves stay behind, faint. The curve is honest: it's about as wide as the jumps.
- Now 20, then 100. Ask them to watch both rows. The dots on top spread just as wide: people are as different as ever. The green curve gets narrow, fast.
- Tick "Show everyone's average." With 100 people, the curve sits right on it.
- If someone asks how the green curve is made: it's the posterior for the average with a flat prior, a Normal centered on the sample's average with spread SD / √n. They don't need the formula; the next slide has the numbers.

## Two spreads {#two-spreads}

- The widget's lesson in numbers. Same population, different sample sizes.
- The blue column never changes: most adults are within about 15 cm of average, however many we measure. That's the population distribution.
- The green column shrinks: with 5 people we're 95% sure the average is within about 7 cm; with 352, within less than 1 cm. That's the certainty distribution.
- The width shrinks with the square root of the number of people: four times the data halves the uncertainty. Mention it, don't derive it.
- Click: more data doesn't make people less different. It makes us more sure.
- Click: the line to remember, and a callback to Week 1's "the uncertainty is in us." Variation is a fact about the world: people really differ. Uncertainty is a fact about us: what we know. Statistics needs both, and confusing them is one of the most common mistakes in reading research.

## Population or certainty? {#two-kinds}

- An important distinction that trips people up later. Population distributions describe how a quantity varies across real cases. Certainty distributions describe how plausible each value of an unknown is. There's one true value; we just don't know it.
- Click: the quick test. Many cases that really differ, or one answer we're unsure about? Try it on the examples on the cards, then on a few of the students' own.
- Same shapes, same vocabulary, same math. That's convenient, and also why they get confused.
- Part 3 needs both: a pattern in the data, and how sure we are about it.

## Part 3: Correlative distributions {#part3}

- Section break. The third card. So far, one variable at a time. Now: how does one variable's distribution move with another?
- This kind uses the first two. The scatterplot is a population distribution with two variables. A coefficient summarizes how one moves with the other. That coefficient is unknown, so it gets a certainty distribution.
- The part ends with the preview of next week: add a variable to a model, and a coefficient changes.

## Two variables at once {#correlation}

- Each variable has its own population distribution, which Part 1 described. A scatterplot shows both at once: one dot per adult.
- Click: taller people tend to be heavier. But what does "tend to" mean, exactly? That's the next slide.

## A relationship is a distribution that moves {#conditional}

- Interactive. The orange band picks out adults of about the same height. On the right, sideways, is the distribution of their weights, against everyone's in gray.
- Start at a short height. Ask: how much do people this tall weigh? Look at the orange distribution: not one weight, a spread.
- Drag the band slowly to the right (or use the slider). The whole orange distribution slides up. That's what a relationship is: not a line, a distribution that moves.
- Each band leaves a dark mark at its average weight. Sweep across: the marks line up. Tick "Show the line": the regression line runs through the middles of the moving distributions. That's all a regression line is.
- Point out what the line doesn't show: the spread around it. At any height, weights still vary by several kilograms.
- Click: in Week 1's notation, this is P( weight | height ). The bar means the same thing as P( rain | July ): narrow down which cases we count. Last week the answer was one probability; now it's a whole distribution.

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
- Click: r = 0.3 looks like almost nothing to the eye, yet it's a relationship many papers would report.

## What correlation misses {#cor-misses}

- Three datasets where r badly misdescribes the relationship.
- A curve: a strong, clear relationship with r near 0, because r only measures straight-line agreement.
- One extreme point: 30 unrelated points plus a single outlier, and the outlier alone creates a large r.
- Two groups: inside each group the relationship runs downhill, but the overall r is positive. Flag this one; it's the shape of the bedrooms puzzle in the house exercise.
- Click: always plot your data before trusting one number.

## Regression: our first coefficient {#regression}

- Back to the moving distribution: we want a line through its middles. In z-space it needs one number: its slope, β.
- Show the candidate lines. Click: which describes the data best? Students will pick the right one by eye. Then ask: what does "best" mean?

## The best line {#best-line}

- The red segments are the misses: how far each person is from the line.
- The best line makes the misses as small as possible overall (technically, the sum of squared misses).
- Click: the neat fact. With standardized data and one predictor, the best slope is exactly the correlation. β = r.

## Reading the coefficient {#reading-coef}

- Mechanics slide. Two ways to read the same β.
- In z-scores: one SD taller goes with r SDs heavier.
- In real units: convert back by multiplying by SD of weight and dividing by SD of height. About 0.6 kg per cm.
- Watch the wording: "goes with," not "causes." It matters in a few slides.

## How sure are we about β? {#beta-posterior}

- β is an unknown, like the mayor's vote share. So it gets a certainty distribution: a prior and a posterior. This is the second card again, applied to a relationship.
- Click: two posteriors, one from 20 adults (wide, light) and one from all 352 (narrow, dark). The same lesson as the sampling widget: more people, more sure.
- Small samples aren't invalid. They're honest about being unsure. Keep that in mind for the next slide.

## A headline from pure noise {#noise}

- Read the headline out loud, like a news anchor. Ask: do you believe it? Would you act on it?
- Click: it was pure noise. 50 made-up variables for 20 made-up countries, every value random. Nothing is related to anything.
- With 1,225 possible pairs, the strongest one has a large r. Put names on those two variables and it's a headline.
- Ask: how many real studies look at many variables and report the strongest?

## How much *r* varies by chance {#small-samples}

- This histogram is itself a distribution: how much r varies by chance alone, when nothing is going on. With 20 cases, chance alone gives r values of ±0.5 and beyond. With 500 cases, they stay near 0.
- It's the same lesson as the sampling widget and the β posterior, from another angle: with little data, numbers jump around.
- Click: this is Week 1's problem again. Try enough comparisons and some will look significant. The base rate of real relationships here is zero, so every "discovery" is false. A wide certainty distribution is the honest response.
- Chance is one way a correlation misleads, and more data helps. The next few slides show a way that more data doesn't fix.

## Do men weigh more? {#sex-weight}

- The preview of next week begins. Back to the two crowds from Part 1: men are taller. Now weight.
- The two weight distributions: men are heavier, with plenty of overlap.
- Click: fit weight on sex alone, the same kind of line as before with sex as the predictor, and the coefficient for sex is about 6.8 kg. Men weigh 6.8 kg more, on average.
- Click: the question. Is that because they're men, or because they're taller? Let students argue. Some will say both.

## Compare adults of the same height {#same-height}

- Interactive, same widget as before, now with women in red and men in blue. The band picks out adults of about the same height (±3 cm), and compares the women's and men's weights inside it.
- Start in the middle, around 155 cm, where there are plenty of both. The gap: essentially zero.
- Slide around. At 150, 155, 160 cm the gap stays small, sometimes slightly positive, sometimes slightly negative. Overall, men were 6.8 kg heavier. At the same height, hardly at all.
- At the extremes there are too few of one sex to compare: few men below about 148 cm, few women above about 165 cm. The widget says so. That's honest too.
- Tick "Show the lines": one line for women, one for men, from the model with both sex and height. They lie almost on top of each other.

## Add height, and sex stops predicting weight {#sex-height}

- The same thing in two models. Weight on sex alone: +6.8 kg.
- Click: weight on sex and height. Sex: about −0.1 kg. Height: about 0.63 kg per cm. Adding one variable changed the coefficient for the other, from 6.8 to roughly nothing.
- Click: where did the 6.8 kg go? Men are about 10.8 cm taller, and each cm goes with about 0.63 kg. 10.8 × 0.63 ≈ 6.9 kg. Almost exactly the gap. The DAG draws it: sex affects height, height affects weight. The direct arrow from sex to weight is gray: in these data it carries almost nothing.
- Click: the effect of sex passes through height. The direct effect is about zero, and the interval (a certainty distribution again) runs from about −1 to +1 kg.
- Click: the big statement. This is next week's central idea. The coefficient for sex didn't change because the data changed. It changed because the question changed.
- Don't say "sex doesn't affect weight." It does, through height. Week 3 makes this precise: total effect versus direct effect.

## Which number is right? {#which-right}

- Both numbers are calculated correctly from the same data. They answer different questions.
- "Do men weigh more than women?" Yes, 6.8 kg. "Do men weigh more than women of the same height?" No.
- Click: a coefficient's meaning depends on what else is in the model. In the second model, "sex" means "sex, comparing people of the same height."
- Click: it can change, vanish, or even flip sign. The house prices show a flip.
- Click: which question should we ask? The data can't say. It depends on what we want to know and what we think causes what. That's next week.

## Summary: three ways to think with distributions {#summary}

- The definition, then one card per part. Read them slowly.
- Ask students to name the three kinds without looking, and give an example of each from their own work.
- Each card ends with this week's line for that kind: the pilots (an average describes the crowd), the sampling widget (variation is in the world, uncertainty is in us), and sex and height (a coefficient depends on what else is in the model).
- Click: the line to remember. Think in distributions, not single numbers.

## Next week {#next-week}

- Correlation and regression describe how things vary together. They don't say why.
- Adding height made sex's coefficient vanish. In the appendix, adding living area flips bedrooms'. Which model answers our question?
- Click: the data can't decide. We need to write down what we think causes what. That's a DAG, next week.
- The table is Week 1's course map, with this week in bold.

## Practical work: What makes a house expensive? {#houses}

- Appendix for the TA session. It uses all three kinds on real data: a population distribution of prices (Steps 1 and 2), correlative distributions of price with each feature (Steps 3 to 5), and certainty distributions for the coefficients (the intervals in Step 7). Steps 6 and 7 repeat the week's preview: add a variable, and the others change.
- Let students drive. Each step has a question to answer before the reveal.
- The callout is the same idea as Week 1's "deliberately simple model": we leave a lot out, on purpose, and say so.

## The data: house sales in Ames, Iowa {#houses-data}

- 2,930 house sales in Ames, Iowa, 2006–2010, compiled by Dean De Cock (2011) for teaching. Prices in US dollars, areas converted to m².
- It's a US college town, so it's not Nepal. Ask what might be different about a housing market here.

## Step 1: The distribution of prices {#houses-step1}

- Not Normal: a long right tail of a few very expensive houses.
- The tail pulls the mean (about $181,000) above the median ($160,000). Ask: which is the typical price? For skewed data, usually the median.
- This is why "always plot first" matters. A mean and SD alone would hide the tail.

## Step 2: How unusual is this house? {#houses-step2}

- Students compute z-scores for two houses: A, the most expensive, and B, the largest.
- Let them work it out with the means and SDs in the table before revealing the answer.
- The question "in what way is it unusual?" matters: a house can be ordinary in price but extreme in size.

## Step 3: Guess first {#houses-guess}

- Have everyone rank the six features before looking. Write a few rankings on the board.
- Guessing first makes the result stick, and shows people how good or bad their intuitions are.

## Step 3: The correlations {#houses-correlations}

- Living area is strongest (about 0.71), then garage size (0.65), year built (0.56), bathrooms (0.55), lot area (0.27), and bedrooms last (0.14).
- Bedrooms near the bottom usually surprises people. Hold that thought for Step 6.
- Because r has no units, we can compare m², cars, years and rooms on one scale.

## Step 4: Price and living area {#houses-step4}

- r is about 0.71. Bigger houses sell for more, with plenty of scatter.
- House B, the largest, sits far below the pattern. Ask what might explain it. Good guesses: an unusual sale, a family sale, a house sold unfinished. De Cock's documentation flags the very largest houses as unusual sales that don't reflect market value.
- Lesson: an outlier is a question about how the data were made, not just a nuisance.

## Step 5: One coefficient {#houses-coef}

- Mechanics slide. Same as the height and weight coefficient, now for price and living area.
- In z-scores: one SD more space goes with about 0.71 SD higher price. In dollars per m², convert with the SDs.
- Again: "goes with," not "adds."

## Step 6: A puzzle: bedrooms {#bedrooms-puzzle}

- Overall, more bedrooms go with a higher price. Click: but among medium and large houses of similar size, more bedrooms go with a lower price.
- Let students argue about how both can be true before moving on. It's the "two groups" shape from "What correlation misses."

## Step 6: Two models, two answers {#bedrooms-solved}

- The puzzle as two models. Bedrooms alone: +0.14. Click: add living area, and bedrooms flips to about −0.30.
- Click: big houses have more bedrooms and sell for more, so bedrooms alone picks up some of the value of size.
- Click: holding size fixed, an extra bedroom means smaller rooms, which buyers pay less for.
- Click: the same move as height and sex. There, adding a variable made a coefficient vanish; here, it flips one. Week 3 explains the difference: height sat between sex and weight, while living area drives both bedrooms and price.

## Step 7: Every coefficient moves {#model-builder}

- Interactive. Tick features to put them in the model. Each bar is a coefficient, in SDs of price per SD of the feature. The black lines are 90% intervals: the certainty distribution for each coefficient. With 2,930 houses they're narrow.
- After each change, a dashed gray mark shows where a coefficient was before. Most of them move every time.
- Start with bedrooms alone, then add living area: the bedrooms bar crosses zero.
- The bottom shows the typical miss: how far a typical price is from the model's prediction. With no features, prices spread by about $80,000 around the average. Each feature narrows the price distribution for houses like this one. That's a correlative distribution: the price distribution, given the features.
- All 64 possible models are fit in advance in R, with lm(). With this much data, a Bayesian fit with weak priors gives essentially the same numbers (Week 3 fits the bedrooms models in Stan).

## What to try {#houses-try}

- Bedrooms, then living area: bedrooms flips. One sentence: at the same size, more bedrooms means smaller rooms.
- Bathrooms, then year built: bathrooms is clearly positive (about +0.18 with bedrooms and area), then drops to about zero once year built is in. Newer houses have more bathrooms, and newer houses sell for more. Bathrooms was partly standing in for "new."
- Everything: compare each bar with that feature's correlation from Step 3. Living area barely moves. Bathrooms moves from 0.55 to about zero.
- The typical miss: living area narrows it the most, then year built. Lot area hardly at all.
- The closing question: which coefficient is the value of a bathroom? Each model gives a different answer, and the data alone can't choose. That's next week: DAGs.

## The model, written formally {#houses-model}

- Mechanics slide. The same notation as the mayor's model last week: "∼" reads "is drawn from."
- Line 1: prices spread around a center. Line 2: the center moves with the features.
- Walk the table against the model builder: μ is the prediction, the βs are the bars, σ is the typical miss.
- The last bullets tie the week together: every line of a model is a distribution, and the three kinds all appear. "The others held fixed" is the part to underline. It's why every coefficient depends on what else is in the model.

## More resources {#more-resources}

- McElreath's chapter 4 builds the Normal and the regression line from the same !Kung data, with priors and posteriors for every parameter. Chapter 5 is about adding variables, and why coefficients change when you do.
- The pilots story opens Todd Rose's *The End of Average*. It's short and very readable.
