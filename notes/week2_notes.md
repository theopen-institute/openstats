
## Data Lunch: Week 2 {#title}

- This week is about one idea: distributions. Say the word often. By the end, students should reach for it without being asked.
- A distribution is a different way to think about a number. Instead of one value, it's every value the number could take, and how common or plausible each one is.
- Three kinds, one per part: population distributions (how cases vary), certainty distributions (how sure we are about something we don't know), and correlative distributions (how one thing's distribution moves with another). Each has its own color, all week: blue, green, orange. The same three cards come back at every part break and in the summary. Point at them.
- The thread from Week 1: randomness and uncertainty aren't a nuisance to get rid of. They're what statistics is about. Last week: a probability measures how sure we are. This week: a single number hides a crowd, and how sure we are about it is a distribution too.
- The deck ends with a preview of Week 3: add one variable to a model, and the coefficients for the others change. It appears twice: sex, height and weight at the end of Part 3, and bedrooms in the house prices.

## Income in Nepal, 2008–2018 {#nepal-earnings}

- Week 1 opened with a claim that sounded wrong and turned out true. This week opens with a puzzle from Nepal's own data, solved on the next slide. The title is deliberately neutral: let them find the puzzle.
- Set it up. The Nepal Labour Force Survey, 2008 and 2017/18, as tabulated by the ILO (ILOSTAT): average monthly earnings in the main job. Prices roughly doubled between the two surveys (×2.1, about 8% a year), so every rupee figure is converted to 2025/26 rupees with the Nepal Rastra Bank's consumer price index. The bars are the change after inflation; the rupee amounts are written in them.
- Who's counted: paid employees only, people working for a wage or salary. That leaves out most of Nepal's workers: farmers on their own land, shopkeepers and other self-employed people, and family members working unpaid. In 2008 paid employees were about 2 million people; by 2017/18, about 3.8 million.
- Two groups, as the ILO's published tables draw them: secondary education or less, and post-secondary. Each group's average is built from the ILO's averages for each education level, weighted by how many employees have it. Both groups' real earnings rose a lot, 67% and 58%.
- Ask: what happened to both groups together, all paid employees? Most people will say somewhere between 58% and 67%.
- Click: 55%. Less than either group. Ask the room how that's possible. An average of two groups should land between them.
- Click: the question, on the slide.
- Someone may get there: the mix changed. The lower-paid group grew from 74% to 86% of employees, which pulls the overall average down. True, but why did it grow so fast? Leave it open: the next slide.
- A caution if anyone checks the ILO's website: the ILO also publishes an all-employee average for 2008 (Rs 6,287) that is higher than its own education rows add up to (Rs 5,412). In 2017/18 they match. 2008's earnings data probably missed some employees, likely rural and less educated ones. Grown from the published total, all employees' real gain is 34%, not 55%. We build every average here from the same rows, so the groups and the total agree with each other.

## The distributions behind the averages {#nepal-reclass}

- The answer, and our first look at this week's subject: a distribution. Each hump shows how one group's earnings spread out: how many employees earn each amount. Top, secondary or less; bottom, post-secondary, the same order as the last slide. The area under a hump is the number of employees, on one scale. The thick lines are each group's average, starting at the last slide's 2008 numbers: Rs 14,640 and Rs 24,180, with both groups together at Rs 17,070.
- Say up front that the shapes are made up. The survey tables give each education level's size and average, not its spread, so each level is drawn as a smooth curve with its real average and an invented spread, and the humps add them up. The sizes and averages are real; the exact shapes aren't, because the survey's microdata (which would give them) isn't publicly available. The footnote says so.
- Click: ten years pass, and we keep counting the groups the way 2008 did, with grades 11–12 (the old Intermediate and Proficiency Certificate) as post-secondary. Both humps grow (many more paid employees) and move right. Post-secondary's average reaches Rs 32,350, up 34%; secondary or less reaches Rs 24,330, up 66%; both groups together Rs 26,430, up 55%, in between, as an average should be. No puzzle yet.
- Click: the green part of the post-secondary hump is grades 11–12: 463,000 employees in 2017/18, almost half the group. Point out where they sit: at the low end of post-secondary, below its average, but just above the secondary group's average.
- Click, and let the animation run. The 2017/18 tables count grades 11–12 as secondary. Same people, same pay: watch them rise out of post-secondary and push up the secondary curve from underneath. Post-secondary lost its lowest earners, so its average jumps from Rs 32,350 to Rs 38,260. Secondary or less gained people who earn a bit more than its average, so its average rises too, from Rs 24,330 to Rs 24,500. Both groups together: unchanged. Those are the published 2017/18 numbers from the last slide.
- This is the Will Rogers paradox, after his joke that when the Okies left Oklahoma for California, they raised the average intelligence of both states. Medicine has a famous version: better scans move patients with small tumours from "early stage" to "late stage", and survival improves in both stages while no patient lives longer.
- That solves the puzzle. The published growth compares 2008's groups, with grades 11–12 counted as post-secondary, to 2017/18's, with them counted as secondary. Of post-secondary's published rise of Rs 14,080, Rs 5,910 (42%) is the move. Count both years the same way and there's no paradox: both groups together land between the two groups.
- If someone asks why 42% here and "most of it" elsewhere: it depends which year's grouping you hold fixed. Counting both years the 2017/18 way (degrees only), post-secondary grew just 10% and the move is three quarters of the published rise. Either way, a big share of the published gain is the label.
- Be honest about the source: the ILO doesn't document the change. It's inferred from the ILO's own detailed counts: grades 11–12 appear as short-cycle tertiary (ISCED 5) only in 2008, and the post-secondary non-tertiary level (ISCED 4) appears only in 2017/18, which fits Nepal's 2016 education reform making grades 9–12 secondary school.
- And the real story is the opposite of the published one: degree holders doubled, from 7% to 14% of paid employees, and their real pay barely grew. Economists call it graduate premium compression.
- Caveats, if asked: these are survey estimates, so differences of a percent or so are noise. Only two survey rounds have earnings by education (the ILO hasn't tabulated the 1998/99 one). Settling it properly takes the survey's microdata from the National Statistics Office.
- Click: the lesson for the week, in one line. Distributions reveal what averages hide. An average summarizes a crowd, a distribution. Change who's in the crowd and the average changes, even when nobody's situation does. Before comparing averages, ask who's in each group, and look at the whole distribution when you can.

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
- The second goal: two tools that every model from here on uses. z-scores come at the end of Part 1 (and why we always standardize, in Part 3); the named distributions at the end of Part 2. Both are mechanics, not ideas, so they get their own slides, but each sits where it's needed.
- The third goal is the preview of next week: adding a variable to a model changes what the other numbers mean. It comes at the end of Part 3 and again in the house prices.
- The house-price example is the appendix, for the TA session.
- Last click: the definition. Every value a number could take, and how common or plausible each one is. "Common" is for population distributions, "plausible" for certainty distributions.

## Part 1: Population distributions {#part1}

- Section break. The first card: how a quantity varies across real cases.
- The theme of the part: different distributions tell different stories. Read the shape first. The named numbers (mean, SD, z-scores) are labels on the shape, not the point.
- The order: a warm-up, reading the shapes of income in six imagined places; then Nepali adults' heights, a bell with its labels; one man's place in it (z-scores); then a look inside the bell (women and men), and shapes that tell stories about generations: Nepal, Japan. It ends on the part's closing line.

## What does income look like? {#incomes}

- A warm-up before any real data, the population version of "How old is he?" in Part 2. These are imagined places, not data: plausible shapes for monthly income.
- All six share one axis, 0 to 100 thousand rupees a month, and none is labelled yet. For each, ask the room first: what kind of place makes this shape? Who earns what? Then click: the place, and its shape in words. Read the shape before reaching for any number.
- The top row is three countries with the same most common income (the peak is in the same spot); only the spread changes. A typical country: skewed right, the usual shape of income: the log-normal, which Part 2 names. A more equal country: the same peak, a short tail. A very unequal country: the same peak, a very long tail. Ask: where would the average be in each? The longer the tail, the further the few at the top pull the average above what most people earn.
- The bottom row is three places whose shape tells a story.
- One pay scale: a government office, say. Narrow and symmetric, everyone near the middle.
- Farms and offices: two humps. Two kinds of household, each with its own typical income. A single average falls in the gap, where almost nobody is.
- A minimum wage: nobody paid below the floor, a crowd paid exactly it, and fewer the further above. The solid bar is a share of people at exactly one value. A rule, not a natural process, made this shape.
- The takeaway: the same question, "what do people earn here?", has very different answers in different places, and the shape tells you which story you're in. Next, the vocabulary for describing a shape, on real data.

## Our running example: Nepal's adults {#adults}

- Introduce the data: the WHO's STEPS survey of noncommunicable-disease risk factors, run in Nepal in 2019 by the Nepal Health Research Council. Surveyors visited households across all seven provinces, picked one adult aged 15–69 in each, interviewed them, and measured their height and weight. We use the 5,290 aged 18 and over.
- We use it because it's about people, it's from here, and height and weight are easy to reason about. The same data carries us from one variable (Part 1) to two (Part 3), and into next week.
- Only 36% of those measured are men. STEPS picks one person per household, and many young men were working abroad (Nepal's ages, at the end of this part, show who's missing). The survey's weights count each man for more, which brings men to 47%. We use the people as measured: weighting doesn't change any of the shapes or conclusions here.
- Twelve impossible measurements are left out (a 261 cm man; heights typed into the weight column). Real survey data needs that kind of checking.

## Describing distributions: center, spread, shape {#describing}

- Read the shape first: one hump, roughly symmetric. A bell, which the next slide names.
- The bars are 2 cm wide. STEPS measured heights to the whole centimeter, so each bar holds two whole centimeters: no bar gets more steps of the ruler than another.
- Then the two labels on the plot. Center: the mean, about 155 cm (the red line). Spread: the standard deviation, about 8.2 cm (the shaded band). A typical adult is within about 8 cm of average.
- These two numbers are annotations: they label a shape, they don't replace it. Hold on to "one hump": two slides on, we look inside it.

## The Normal distribution {#normal}

- The blue curve is a Normal distribution with the same mean and SD as the data. With 5,290 adults the bars are smooth, and they follow the curve closely: two numbers describe the whole shape. That's the Normal's main attraction.
- The Normal is a shape that turns up everywhere, in math and in nature. Don't explain why yet: what makes it special comes later (Part 2's Galton board shows where it comes from). For now it's enough that the heights in a population often take this shape.
- Click: the bands. Every Normal has the same landmarks, whatever its center and spread: about 68% of cases within 1 SD, 95% within 2 SD. The right column checks them against Nepal's adults: 67% and 96%, close. That's a good habit: check a rule of thumb against your actual data.
- "Within 2 SD" comes back in Part 2: it's how we'll say how sure we are.
- Real data are never perfectly Normal. The Normal is a description, not a law. The next slide looks closer at this one, and the rest of this part is shapes that aren't bells.

## One hump, or two? {#two-humps}

- The same heights, in the same bars. Men are about 10 cm taller than women on average. Ask: shouldn't that make two humps, one for women and one for men? Let the room guess before clicking.
- Click: women and men. The same bars, colored by sex, women at the bottom, so the outline doesn't change. Most of the shorter adults are women, most of the taller ones men, and the middle is where they overlap. Women are about two thirds of the bars, because fewer men were home to be measured.
- Click: the bars separate, women's half of each bar on the left and men's on the right, and each sex gets its own Normal (its own mean and SD). Women around 151 cm, men around 161. Each fits well on its own.
- Click: they stack back up, and the dashed line is the two Normals added together: one lopsided bell, following the bars. Two bells only make two humps if they're more than about 2 SDs apart. These are about 1.4: a 9.5 cm gap, with each crowd's SD about 7 cm (6.5 for women, 7.5 for men).
- The lesson: two groups in a population don't show up as two humps unless they're far apart. Don't read groups off a histogram, in either direction: a single hump can hide two crowds, and a lump or dip in a small sample can be chance. Before explaining a bump or a dip, ask whether it's bigger than chance, and whether it came from how the data were measured. Nepal's ages, at the end of this part, come back to that.

## Taller or heavier? {#z-scores}

- Pose the puzzle and let them try. The plots show where he sits in each crowd: far out on both. But which is further? Centimeters and kilograms can't be compared directly.
- Click: the trick is to measure both in "standard deviations from average." Now they're on the same ruler.
- Click: the arithmetic, and the plots label each line with its z-score. Click: he is more unusually heavy than tall.
- A z-score is a population-distribution idea: it places one case in the crowd.

## Same data, new ruler {#new-ruler}

- One histogram, two rulers: centimeters along the bottom, z-scores in blue along the top. Standardizing doesn't move a single person. It only relabels the axis.
- The mean becomes 0 and the SD becomes 1. The units disappear: a z-score is measured in standard deviations.
- The table is a quick reference. 0 is average, ±1 is ordinary, ±2 is unusual (about 1 in 20), ±3 is rare (about 1 in 370). It's the 68–95–99.7 rule read the other way.
- z-scores will come back in every model from here on. Part 3 says why.

## Nepal, age by age {#nepal-population}

- The same idea at the scale of a country. The share of Nepal's residents at each age, from the Nepal Living Standards Survey (2022/23), weighted to the whole population.
- Ask: what do you notice? Let them look before clicking.
- Click: the shape. More teenagers than toddlers: the youngest ages are smaller than the ages around 10 to 20. Births have been falling, so each new generation is a little smaller than the one before.
- If someone asks about the working ages: these are residents. About 2.5 million Nepali men (and 0.5 million women) are living abroad, so among residents aged 20 to 39 there are about 5.2 million women and 3.6 million men. The dataset has the people abroad too (status "abroad"), if you want to show it.
- Click: the spikes, in red. Ages ending in 0 or 5 hold far more people than the ages beside them: 40 holds twice as many as 41. Nobody was born in a boom every five years. Many people don't know their exact age, and when asked they round it: "about 40." Demographers call it age heaping.
- It's a survey artifact: a pattern made by how the data was collected, not by the world. Smaller spikes at 12 and 18 are probably the same thing. The lesson: a shape can tell a story about the measurement, too. Always ask which.

## Two countries, two stories {#two-countries}

- The same plot for Japan, on the same scale. Two countries, two shapes, two histories.
- Nepal is young: half its residents are 26 or younger. Its shape slopes down from the youngest ages: lots of children, fewer old people.
- Click: Japan is old: half its people are 49 or older, and nearly 3 in 10 are over 65. Its bulges are generations. The baby boom after the war (born 1947–49, now in their mid-70s), and their children, the second baby boom (born 1971–74, now about 50). The bulge echoes a generation later.
- The labels are worth a story each. 1966 was a "fire horse" year in the old calendar, said to be unlucky for girls born in it; births fell by about a quarter, and came back the next year. The dip just past the baby boom (about age 77) is the war's last years, when few children were born.
- Click: no spikes in Japan. Its ages come from registered birth dates, so nobody needs to round. The two shapes differ in their history, and also in how they were measured.
- Click: the takeaway of Part 1. An average is one point, the center of a distribution. It depends on who's in the crowd, as the opening puzzle showed. The distribution describes everyone.

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
- Set it up: pretend these 5,290 adults are everyone, and we can only afford to measure a few. What's the average height?
- Start with 5. The top shows the five people we measured (blue dots), against everyone (gray). That's a population distribution: how the people we measured vary. The bottom shows how sure we are about the average height: a certainty distribution.
- Click "Measure new people" a few times. Each sample gives a slightly different guess, and the green curve jumps around. The old curves stay behind, faint. The curve is honest: it's about as wide as the jumps.
- Now 20, then 100. Ask them to watch both rows. The dots on top spread just as wide: people are as different as ever. The green curve gets narrow, fast.
- Tick "Show everyone's average." With 100 people, the curve sits right on it.
- If someone asks how the green curve is made: it's the posterior for the average with a flat prior, a Normal centered on the sample's average with spread SD / √n. They don't need the formula; the next slide has the numbers.

## Two spreads {#two-spreads}

- The widget's lesson in numbers. Same population, different sample sizes.
- The blue column never changes: most adults are within about 16 cm of average, however many we measure. That's the population distribution.
- The green column shrinks: with 5 people we're 95% sure the average is within about 7 cm; with 5,290, within about a quarter of a centimeter. That's the certainty distribution.
- The width shrinks with the square root of the number of people: four times the data halves the uncertainty. Mention it, don't derive it.
- Click: more data doesn't make people less different. It makes us more sure.
- Click: the line to remember, and a callback to Week 1's "the uncertainty is in us." Variation is a fact about the world: people really differ. Uncertainty is a fact about us: what we know. Statistics needs both, and confusing them is one of the most common mistakes in reading research.

## Population or certainty? {#two-kinds}

- An important distinction that trips people up later. Population distributions describe how a quantity varies across real cases. Certainty distributions describe how plausible each value of an unknown is. There's one true value; we just don't know it.
- Click: the quick test. Many cases that really differ, or one answer we're unsure about? Try it on the examples on the cards, then on a few of the students' own.
- Same shapes, same vocabulary, same math. That's convenient, and also why they get confused.
- Part 3 needs both: a pattern in the data, and how sure we are about it.
- Before Part 3: the shapes themselves. Same shapes for both kinds, so this is the place to name them, starting with where a shape comes from: the Galton board.

## Random individuals, predictable crowds {#galton}

- This is a Galton board, after Francis Galton, who built one in the 1870s. At every peg, a ball bounces left or right with equal chance: a coin flip.
- Start with 4 rows. Drop one ball. Ask: where will the next one land? Nobody knows. Drop a few more, one at a time.
- Tick "Count the paths." The numbers under the bins, 1, 4, 6, 4, 1, are the garden of forking paths from Week 1: four coin flips, and the number of ways to get each number of heads. A ball that bounces right twice can do it 6 ways; all the way right, only 1. The middle bins have more paths, so more balls end up there.
- Drop 100, then 1,000. The bars fill in the dashed outline: the shape the counting predicts.
- Now set 12 or 14 rows, empty the bins, and drop 1,000. A bell. Drop another 1,000: the same bell.
- The line on the slide: one ball is anyone's guess, a thousand make the same shape every time. Random individuals, predictable crowds. That's why statistics works at all. We can't predict one admission, one patient, one voter. We can describe the crowd, sometimes very precisely.
- Say it once: randomness isn't the opposite of pattern. Randomness has patterns.
- The bridge to the next slide: this is where named shapes come from. A process, repeated many times, makes a predictable shape. The Galton board's process (coin flips, added up) makes a bell, the Normal, like the heights in Part 1. Other processes make other shapes, and the next slide names them.

## Every named distribution is a story {#named-shapes}

- The goal is to demystify the names. Normal, Poisson, Beta sound like jargon. Each one is just the shape a particular process produces, and the process is something students already understand.
- Walk the six, briefly, with the process first:
  - Normal: many small pushes added up. The Galton board on the last slide, the heights in Part 1.
  - Log-normal: many small pushes multiplied. A raise is a percentage of what you already earn, so earnings spread out at the top. The made-up curves in the opening puzzle were log-normal.
  - Exponential: waiting until something happens. Most waits are short; a few are long.
  - Binomial: counting yeses out of n tries. Week 1's poll: of 20 people asked, how many say "mayor"? The Galton board is one too: a count of rightward bounces out of n pegs.
  - Poisson: counting events with no maximum. Births in a day at a health post: usually 2 or 3, sometimes 8.
  - Beta: a share between 0 and 1. Literacy rates across districts.
- These are population distributions, so they're blue. The heights use Nepal's real mean and SD; the other knobs are made up for the example.
- Click: know the process, and you know the shape. The knobs (parameters) slide and stretch it. That's all a "parameter" is.

## Distributions Demo {#dist-demo}

- Interactive. Pick a family and move its knobs. Use "Run" to draw random values, and watch the histogram fill in the curve: the Galton board again, for any shape.
- Normal: change the mean (the curve slides), change the SD (it stretches).
- Binomial: 20 trials at 30% is the poll on the last slide. Then 1,000 trials: a bell. Lots of small coin flips added up is the Normal's story.
- Poisson: rate 3, then rate 30. It also turns into a bell.
- Beta: try 1 and 1 (flat), then 3 and 7, then 30 and 70. Same center, narrower: a and b work like yeses and noes, so more of them means more certainty. That's Part 2's lesson, in a shape.
- Log-normal: an SD of the log of 0.5, then 1. The tail stretches out to the right.
- Don't drill the formulas. The point: a few knobs control a shape, and the situation decides which shape.

## Pick the shape by the kind of number {#pick-shape}

- Mechanics slide, a reference to come back to. The question to ask first is: what kind of number is this? Any value? Only positive? A count? A share?
- That rules out most shapes. A count can't be Normal (no 2.7 births), a share can't go past 100%, a spread can't be negative. The process picks among what's left.
- Beta's knobs: roughly the yeses and noes you've seen (plus one each). Beta(1, 1) is flat: no information.
- In R, every family has the same pair of functions: r for random draws, d for the curve. The deck uses them: the belief curves for the man's age were drawn with dnorm() and dunif().
- The ~ notation is the same as the mayor's model last week: "is drawn from." Every line of a model is one of these shapes.

## The same shapes, for certainty {#certainty-shapes}

- The same families, now in green: they describe how sure we are, not how cases vary.
- θ ~ Beta(3, 7): the mayor's vote share. A share, so a Beta. Like having seen about 2 people say "mayor" and 6 say someone else. The hand-drawn prior from Week 1 could have been written as one of these.
- β ~ Normal(0, 1): a coefficient. It could be negative or positive, so a Normal. Centered on 0: we don't assume a direction.
- σ ~ Exponential(1): a spread. It can't be negative, so an Exponential: small spreads plausible, big ones less so.
- The last two are exactly the priors behind the posterior for β in Part 3. That slide, and "Why we always standardize", explain why Normal(0, 1) is a sensible choice.

## Part 3: Correlative distributions {#part3}

- Section break. The third card. So far, one variable at a time. Now: how does one variable's distribution move with another?
- This kind uses the first two. The scatterplot is a population distribution with two variables. A coefficient summarizes how one moves with the other. That coefficient is unknown, so it gets a certainty distribution.
- The part ends with the preview of next week: add a variable to a model, and a coefficient changes.

## Two variables at once {#correlation}

- Each variable has its own population distribution, which Part 1 described. A scatterplot shows both at once: one dot per adult, 5,290 of them (a handful are beyond the axes). The dots line up in columns because heights were measured to the whole centimeter.
- Click: taller people tend to be heavier. But what does "tend to" mean, exactly? That's the next slide.

## A relationship is a distribution that moves {#conditional}

- Interactive. The orange band picks out adults of about the same height. On the right, sideways, is the distribution of their weights, against everyone's in gray.
- Start at a short height. Ask: how much do people this tall weigh? Look at the orange distribution: not one weight, a spread.
- Drag the band slowly to the right (or use the slider). The whole orange distribution slides up. That's what a relationship is: not a line, a distribution that moves.
- Each band leaves a dark mark at its average weight. Sweep across: the marks line up. Tick "Show the line": the regression line runs through the middles of the moving distributions. That's all a regression line is.
- Point out what the line doesn't show: the spread around it. At any height, weights still vary a lot: the typical miss from the line is almost 10 kg.
- Click: in Week 1's notation, this is P( weight | height ). The bar means the same thing as P( rain | July ): narrow down which cases we count. Last week the answer was one probability; now it's a whole distribution.

## Standardize both variables {#standardize-both}

- Same scatterplot, now in z-scores, split into four quadrants at the averages. Point out the axes: z-scores on the bottom and left, and the same scales in centimeters and kilograms, in gray, on the top and right. Standardizing doesn't move anyone; it relabels the rulers, as in Part 1.
- Points in the top-right and bottom-left are on the same side of average for both variables. Points in the other two quadrants are on opposite sides.
- More points are in the "same side" quadrants, but plenty aren't. That's what a positive, far-from-perfect relationship looks like.

## Correlation is average agreement {#average-agreement}

- Mechanics slide. The formula says: multiply each person's two z-scores, then average.
- The plain-language version is what matters: each person votes. Same side of average on both is a positive vote. Opposite sides is a negative vote. r is the average vote.
- Properties worth remembering: always between −1 and +1, no units, and it doesn't care whether you measure in cm or inches.

## What does *r* look like? {#r-gallery}

- Build intuition. Six scatterplots from r = −0.8 to 0.9.
- Ask: where would our height and weight (r = 0.46) sit? A clear relationship, but far from perfect: between the 0.3 and 0.6 panels.
- Click: r = 0.3 looks like almost nothing to the eye, yet it's a relationship many papers would report.

## What correlation misses {#cor-misses}

- Three datasets where r badly misdescribes the relationship.
- A curve: a strong, clear relationship with r near 0, because r only measures straight-line agreement.
- One extreme point: 30 unrelated points plus a single outlier, and the outlier alone creates a large r.
- Two groups: inside each group the relationship runs downhill, but the overall r is positive. Flag this one; it's the shape of the bedrooms puzzle in the house exercise.
- Click: always plot your data before trusting one number.

## Regression: our first coefficient {#regression}

- Back to the moving distribution: we want a line through its middles.
- Say it plainly: from here on, both variables are in z-scores. The axes say so, with cm and kg in gray. In z-scores both averages are 0, so every line worth considering goes through (0, 0), and it needs one number: its slope, β, in SDs of weight per SD of height.
- Show the candidate lines. Click: which describes the data best? Students will pick the right one by eye. Then ask: what does "best" mean?

## The best line {#best-line}

- The red segments are the misses: how far each person is from the line, measured up and down. They're drawn for 200 adults picked at random; all 5,290 would be a wall of red.
- The best line makes the misses as small as possible overall (technically, the sum of squared misses).
- Click: the neat fact. With z-scores and one predictor, the best slope is exactly the correlation: β = r = 0.46. One SD taller, 0.46 SD heavier.

## Reading the coefficient {#reading-coef}

- Mechanics slide. Two ways to read the same β.
- In z-scores: one SD taller (8.2 cm) goes with 0.46 SDs heavier.
- In real units: convert back by multiplying by the SD of weight (10.8 kg) and dividing by the SD of height (8.2 cm). About 0.61 kg per cm.
- The R code fits the line in z-scores: the intercept is 0, as promised, and the slope is r. The plot below it is the same line drawn back in cm and kg.
- Watch the wording: "goes with," not "causes." It matters in a few slides.

## How sure are we about β? {#beta-posterior}

- β is an unknown, like the mayor's vote share. So it gets a certainty distribution: a prior and a posterior. This is the second card again, applied to a relationship. The bottom axis is in SDs per SD; the gray top axis is the same β in kg per cm.
- Click: two posteriors, one from 20 adults (wide, light) and one from all 5,290 (narrow, dark). With 20, β could be anywhere from about −0.1 to 0.9 SD per SD. With everyone, 0.44 to 0.49: 0.58 to 0.64 kg per cm. The same lesson as the sampling widget: more people, more sure.
- Each curve is drawn to the same height, so both are visible. At their true heights the narrow one would be a spike about twenty times taller, and the wide one a flat line along the bottom.
- Small samples aren't invalid. They're honest about being unsure. Keep that in mind for the noise slides.

## Why we always standardize {#why-standardize}

- Mechanics slide, and a rule for the rest of the course: every regression is fit in z-scores. Three reasons.
- No intercept: both variables have mean 0, so the line goes through the middle. One fewer number to estimate, and to set a prior for.
- Coefficients compare: every β is in SDs per SD, so living area and bedrooms, or height and age, sit on one scale. The houses' model builder relies on this.
- One prior fits every β: Normal(0, 1) says we're 95% sure a 1 SD change in the predictor moves the outcome by less than 2 SD. That's generous: with one predictor, β is the correlation, which can't pass 1.
- The table: the same relationship in four units. In kg per cm, kg per inch and lb per inch the number changes, so a sensible prior in one unit is wrong in the next. In SDs it's the same number, whatever the units.
- At the end, convert back to real units, as on "Reading the coefficient." The R code is one line per variable; the homework uses it.

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

- The preview of next week begins. The subtitle: men are about 9.5 cm taller than the women, on average. Are they heavier, too?
- The two weight distributions: men are heavier, with plenty of overlap. Women average 53.2 kg, men 59.8.
- Click: fit weight on sex alone, the same kind of regression as before, with weight in z-scores and sex as the predictor. Sex isn't standardized: it stays 0 for women and 1 for men, so its coefficient is simply the gap between them, in SDs of weight: 0.60 SD. Back in kg: 0.60 × 10.8 ≈ 6.5 kg. Men weigh 6.5 kg more, on average.
- Click: the question. Is that because they're men, or because they're taller? Let students argue. Some will say both.

## Compare adults of the same height {#same-height}

- Interactive, same widget as before, now with women in red and men in blue, in cm and kg. The band picks out adults of about the same height (±3 cm), and compares the women's and men's weights inside it. Around 155 cm the band holds about 1,270 women and 550 men.
- Slide around. The gap is small but mostly positive: around 0 at 148–152 cm, 1 to 2 kg at 154–162. Not the 6.5 kg overall, and not quite zero either.
- At the ends of the slider the groups get small: only a handful of men around 140 cm, and of women around 176 cm.
- Tick "Show the lines": one line for women, one for men, from the model with both sex and height. The men's line sits about 1 kg above the women's.

## Add height, and sex shrinks {#sex-height}

- The same thing in two models, both in z-scores; the brackets convert back to kg and cm. Weight on sex alone: +0.60 SD (6.5 kg).
- Click: weight on sex and height. Sex: +0.10 SD (1.1 kg). Height: +0.44 SD per SD (0.57 kg per cm). Adding one variable changed the coefficient for the other, from 0.60 to 0.10.
- Click: where did the rest go? Men are 1.16 SD (9.5 cm) taller, and each SD of height goes with 0.44 SD of weight. 1.16 × 0.44 ≈ 0.50 SD, or 5.4 kg: most of the gap. Add the 0.10 that's left and you're back at 0.60. The DAG draws it: sex affects height, height affects weight, and a direct arrow from sex to weight carries a little.
- Click: most of the effect of sex passes through height. The direct effect, comparing women and men of the same height, is about 1.1 kg, and its interval (a certainty distribution again) runs from about +0.5 to +1.6 kg: small, but not zero. It's largest in the under-45s; among the 45–69s it's about zero.
- Click: the big statement. This is next week's central idea. The coefficient for sex didn't change because the data changed. It changed because the question changed.
- Don't say "height explains why men weigh more." Most of it, in these data. Week 3 makes this precise: total effect versus direct effect.

## Which number is right? {#which-right}

- Both numbers are calculated correctly from the same data. They answer different questions.
- "Do men weigh more than women?" Yes, 0.60 SD: 6.5 kg. "Do men weigh more than women of the same height?" A little: 0.10 SD, about 1.1 kg.
- Click: a coefficient's meaning depends on what else is in the model. In the second model, "sex" means "sex, comparing people of the same height."
- Click: it can change, vanish, or even flip sign. The house prices show a flip.
- Click: which question should we ask? The data can't say. It depends on what we want to know and what we think causes what. That's next week.

## Summary: three ways to think with distributions {#summary}

- The definition, then one card per part. Read them slowly.
- Ask students to name the three kinds without looking, and give an example of each from their own work.
- Each card ends with this week's line for that kind: the opening puzzle (change the crowd, and the average changes), the sampling widget (variation is in the world, uncertainty is in us), and sex and height (a coefficient depends on what else is in the model).
- Click: the line to remember. Think in distributions, not single numbers.

## Next week {#next-week}

- Correlation and regression describe how things vary together. They don't say why.
- Adding height shrank sex's coefficient. In the appendix, adding living area flips bedrooms'. Which model answers our question?
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

- Not Normal: a long right tail of a few very expensive houses. Ask which named shape it looks like: the log-normal from Part 2. Prices, like earnings, grow by percentages (a nicer kitchen adds a share of the price, not a fixed sum), and pushes that multiply give a long right tail.
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
- Click: the same move as height and sex. There, adding a variable shrank a coefficient; here, it flips one. Week 3 explains the difference: height sat between sex and weight, while living area drives both bedrooms and price.

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

- McElreath's chapter 4 builds the Normal and the regression line from height and weight data, with priors and posteriors for every parameter. Chapter 5 is about adding variables, and why coefficients change when you do.
- The US wages example is the opening puzzle at national scale, with real data. Worth a mention for students who want proof it isn't just a classroom trick.
