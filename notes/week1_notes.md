
## Data Lunch: Week 1 {#title}

- Statistical backgrounds?
- Goal: ask questions and observe the world
- There is technical material, but it's easy to forget that the technical material is not the point.

## Most published research is false {#published-research}

- Article by a Greek-American medical scientist at Stanford named John Ioannidis
- purely theoretical argument, based on some very mathy arguments
- Argues that the majority of claims made in published scientific articles are wrong.

- He doesn't give a single number. He models a range of scenarios, and in most realistic ones, fewer than half of claimed findings are true.
- Others have since tested this empirically with large replication projects. Landmark preclinical drug and cancer studies replicated as little as 11-25% of the time (Amgen, Bayer), psychology about 36% (Open Science Collaboration 2015), experimental economics about 61% (Camerer et al. 2016). A failed replication isn't proof a finding is false, but the pattern fits his argument.

- This was a shocking and controversial claim when it was published in 2005. Today his core argument is widely accepted, though how bad the problem is varies a lot by field and is still debated.

- But how can he make this argument, purely theoretically? And what do we do with that? In medicine, psychology, economics, sociology, a large share of our hard, statistical findings, in some fields most of them, are just wrong.

- I'm here to tell you, it's both true and okay. Most science is wrong, and that's okay. 

- In some fields, published research findings may be wrong most of the time, but science still works. It works really, really well.

- That's a paradox.

- It's okay for a very simple reason. Statistics is observation, and observation is always messy. It's only a problem if we expect it to be tidy.

- To make sense of it, we need to understand what statistics is. We need to stop treating statistics as mathematical rituals and start treating it like a way to reflect on and update our own thinking. That's the goal of this course.

# Statistical significance {#statistical-significance}

- This approach is null hypothesis significance testing, the most familiar part of frequentist (or "classical") statistics. Most people just call it "statistics".
- There's nothing wrong with frequentist approaches. They are valid, capable, convenient and useful.
- The math is 100% valid.
- But it's a terrible way to learn statistics
- The way it thinks about probability is deeply, deeply unintuitive.

# You already understand probability {#probability}

- The message for this whole section: they already understand probability. They use it every day; nobody has told them that's what it is. The next few slides only give it notation, and then show the one place intuition slips.
- Before the first click, ask the room: will it rain tomorrow? Someone will say "probably" or "probably not."
- Click: "Probably not." That word is a probability: a statement about how sure they are. Intuitively, probability is a way of talking about uncertainty.
- Click: the "probably" card. Not knowing for sure isn't the same as knowing nothing.
- Click: what I already know. They already use it without thinking: rain works differently in January than in July. Read the three cards as one sentence: I'm uncertain, but I know things, so I can put a number on it. That's a prior on its way to becoming a probability; don't name it yet.
- Click: the "31%" card. Ask: what does "a 31% chance of rain" actually mean? Is the weather random? Most people will say no, or not really. Tomorrow's weather is decided by physics: wind, pressure, moisture, the monsoon. If we knew everything, there'd be nothing random about it. So the randomness isn't in the sky. It's in us. "31%" describes how uncertain we are about a day when all we know is that it's a day in Kathmandu, as if we picked a date from the calendar without looking.
- Click: the takeaway. This is the Bayesian way of thinking about probability, and it's the one we'll use all course: probability describes our knowledge, not a property of the world. A coin flip is the same: a perfect physicist could predict it. We call it 50% because we can't.
- If someone asks: the textbook ("frequentist") view defines probability as the long-run frequency of an outcome over many repetitions. It's a valid view and the math is sound, but it isn't how anyone uses "probably" in daily life, and it makes a statement like "a 31% chance of rain tomorrow" awkward to explain.
- We're going to build statistics on the intuitions they already have.

# Probability is just counting {#counting}

- Students already know all of these. The point is that they already understand probability; they just haven't been told that's what it is.
- Before any notation: probability is counting. Count everything that could happen, count the ones you care about, compare the two.
- The class example is made up. Swap in real numbers from the room if you know them.
- Flag the promise: every probability in this lecture is a count. The HIV table counts 100,000 people. The published-research picture counts 1,000 ideas. If they ever get lost, they can go back to counting.

# Counting the ways a thing could happen {#counting-ways}

- This diagram is a "garden of forking paths" (McElreath's phrase, borrowed from Borges). Start at the dot. Each flip, every path splits in two: heads or tails. After four flips there are 2 × 2 × 2 × 2 = 16 paths, and each one is a different way the four flips could go.
- Trace one path with your finger, e.g. H, T, T, H. Read the number at its tip: the heads on that path.
- The blue paths are the ones that end with exactly two heads. Count them together: 6. So exactly two heads is 6 ways out of 16, a bit over a third.
- Ask the room first: what would you guess? A common answer is 1 in 5, because there are five possible head counts (0 to 4). But those five aren't equally likely: there's only one way to get 0 heads and six ways to get 2. Count paths, not outcomes. Even d'Alembert slipped on this, in 1754: he argued that the chance of at least one head in two flips was 2 in 3, treating H, TH and TT as equally likely. Counting paths gives 3 in 4.
- The row of counts (1, 4, 6, 4, 1) is worth pausing on. It's the shape of a distribution, and it comes back in Week 2.
- Foreshadow the bag-of-stones demo. Bayesian updating is the same move: for each possible bag, count the ways it could have produced the stones we drew. More ways means more plausible. (This is how McElreath introduces it in *Statistical Rethinking*, ch. 2.)

# Writing it down: 0 to 1 {#convention-1}

- New notation, not new ideas: this slide and the next two are things they already know, written down. The format part is quick: 0 is impossible, 1 is certain, and percentages are the same numbers times 100.
- Keep it short. The examples are the ones from "Probability is just counting", plus the 31% rain from the first slide of the section.
- The footnote: 113 rainy days a year is a count from five years of Kathmandu weather records. The count is a fact. The probability (0.31) is what we say about a day we don't know, which is the "a probability measures how sure we are" from the start of the section.

# Writing it down: P(event) {#convention-2}

- Pure notation. P( something ) is read "the probability of something."
- The examples are deliberately ones they've already worked out: rain, coins, the die and the raffle from "Probability is just counting."
- Emphasize that whatever goes inside the brackets is the thing we're unsure about. That habit matters later, when the thing inside is a hypothesis.

# Writing it down: P(event | condition) {#rain}

- The bar is read "given." P( rain | July ) is "the probability of rain, given that it's July."
- The umbrella line: they already condition without thinking about it. Nobody plans a January day like a July day. The notation only writes that down.
- A condition narrows down which cases we count. P( rain ) counts all days. P( rain | July ) counts only July days.
- Adding information changes the probability, sometimes a lot: from 31% overall to 81% in July and 2% in January. Same city, same sky.
- This is also the point of "You already understand probability" again: the more we know about a day, the less uncertain we are.

- These numbers come from the past: the last five years (2021–2025) of daily records from the Kathmandu Airport weather station. We're using history as a guide to what's likely in a given month. Say the assumption out loud: next year will be like the average of the last five.
- The record has gaps; each month has 58–97% of its days. We fill the missing days at that month's average rate, so every month is "out of" five full years: 150 days for 30-day months, 155 for 31-day months, 140 for February. That's why the denominators differ.
- April is a good example of how much the choice of years matters: using 2019–2021 instead, April came out at 43%; 2021–2025 gives 23%. A small reminder that every number rests on choices about which data to use.
- That doesn't make them exactly right for this year. They're a reasonable basis for a probability, not a precise forecast.
- In fact, the climate is definitely changing, and we could model those changes (trends over time, monsoon timing, and so on). For now, we'll just treat historical data as our basis for prediction.

# Direction of conditions {#direction}

- The second thing to know about the bar. The last slide: a condition narrows down what we count. This one: which side of the bar a thing is on matters. Their intuitions have been right so far, rain by month included. This is the one place they slip.
- Read the two results under the table. With the starting numbers, 80% of rural students study sociology, but only 25% of sociology students are rural. Same people, same table, different question.
- Let students change the numbers and watch the two drift apart. They're only equal when the two groups are the same size.
- Nothing is wrong with their intuition, only with which question it answers. Plant it and move on: this slip comes back twice today. It turns "99% sensitive" into "99% sure" (the HIV test), and a p-value into "the chance the hypothesis is true."

# Conditional risk {#conditional-risk}

- Give people a moment to read it. Let the laugh happen.
- The joke is about conditioning. "One in 7,000,000" is P(killed by lightning) for an average American over a year. Almost none of those people were standing outside in a thunderstorm at the time.
- The two people in the comic aren't average. They're outside, in a storm, right now. The number that matters for them is P(killed by lightning | outside in a storm), which is far higher.
- The "one in six" in the caption is a joke, not a statistic. Don't defend the number; the point is the conditioning.
- Takeaway: an unconditional probability can be correct and still be the wrong number for your situation. Always ask: conditional on what? This sets up the HIV example, where the condition is a positive test.

# Probability lets us ask questions {#lets-count}

- Actually do it. Count the room, type it into "People here," ask for hands, type the count into "Hands up." The dots fill in live.
- Swap the question for anything quick: came by bus, has a sibling abroad, slept less than six hours.
- Make the distinction explicit. "9 out of 25 had tea" is a count, a fact about the room. Nothing about it is uncertain.
- It becomes a probability when we use it to say something we don't know. Ask: if I picked one of you at random, without looking, what's the chance they had tea? They'll answer without thinking. That answer is a probability, and they built it from the count.
- This distinction matters later. Data are counts and measurements. Probabilities are statements about what we don't know: the next person, the whole population, next year's rain, whether a hypothesis is true.
- The street question needs assumptions the room question doesn't: that this room is like the street, that tea habits don't depend on who comes to a statistics lunch. Say them out loud.
- Last clicks: every prediction makes assumptions, and interesting predictions make big ones. Say the idea behind it aloud, because it isn't written on the slide: together, those assumptions are a story about how the data came to be. That story is what we'll call a model, and the conclusions are only as good as it is. It comes back in the mayor appendix (each answer is a coin flip) and in week 3, where we draw the story as a DAG and simulate data from it.

# Probability for Decision Making {#applied-probability}

One common use of statistics is to evaluate the accuracy of predictive tests.

I want to illustrate a very famous example involving HIV testing. This is relevant because, until 2010, anyone from Nepal applying for an immigrant visa to the US had to take an HIV test as part of the required medical exam.

- Three tiles, one click each. Prevalence: how common HIV is, 1 person in 1,000. Then the test's two kinds of accuracy. Sensitivity: of the people who have HIV, the share it catches. Specificity: of the people who don't, the share it correctly clears. The notation under each tile is the "Writing it down" from earlier; point out which side of the bar HIV is on.
- The colors are deliberate and stay unexplained for now: the base rate is red and the test's accuracy is blue. They come back as prior and likelihood on "You already understand Bayesian updating".
- Last click: you test positive. How worried should you be? This is the decision in "decision making". Take a few guesses before moving on. Most will be near 97% or 99%: it sounds like an imperfect but reasonably good test.

# The question that matters {#real-question}

- Sensitivity and specificity are back at the top as plain lines, in view from the start. The real question appears later on a line laid out the same way, so P( HIV+ | test+ ) sits directly under P( test+ | HIV+ ): the same two words, sides swapped.
- Click: by most standards, that's a good test. Make the point honestly: 99% and 97% are good numbers, and plenty of tests in medicine and research do worse. The puzzle only works if they believe the test is good.
- Then a question: is there a problem with judging the test by those two numbers? Can anybody spot it?

- Click: the red callout, "But there's something strange here..." Click again for its answer: if we already knew whether someone has HIV, there'd be no point testing them. Sensitivity and specificity describe a situation where we already know somebody's HIV status. Far more often, when we think about the accuracy of a test, we're interested in the reverse question.

- Click: the real question, P( HIV+ | test+ ), with a red question mark where its number goes. Say it in full: the real question is almost always this one. This is the slip from "Direction of conditions", now with real stakes: sensitivity is P( test+ | HIV+ ), and the question is P( HIV+ | test+ ).
- Before the next click, go back to the guesses from the last slide. Most were near 97% or 99%.
- Click: 3.2%, on its own. Let it sit.
- Click: the words around it, "in a random screening, only 3.2% of positive tests will be accurate". Don't explain it yet; let them puzzle over how a 99%-accurate test can be right only 3% of the time. The next two slides count it out.

# What a positive test means {#base-rate}

- Where the 3.2% comes from. The table starts with what they already know: sensitivity, specificity and the two error rates, with the names papers use for them. The counts are what's new.
- Clicks: (1) the table of probabilities. (2) The population: 100,000 people, so every cell is a whole number. 100 have HIV, 99,900 don't. (3) The counts at the bottom of each cell. (4) The 3.2%. If anyone asks where it comes from: 99 real positives out of 99 + 2,997 positives. The fine print appears with it.

- Think about that. If you pick a person at random, give them an HIV test and it comes back positive, there is only about a 3% chance that they actually have HIV. 97% of them are getting a positive test (and, likely, quite a scare) erroneously.

- This goes against most people's expectations. Why this happens actually isn't that hard to understand. Of people with HIV, 99% will get a positive test result.
- Of people who don't have HIV, only 3% will get a positive test result.

- But, the important fact is that HIV is actually quite rare. 3% of a big population is bigger than 99% of a very small population.

- So, this test is 99% accurate at detecting HIV among people who have it, but for a random person getting a test, a positive test result is only accurate 3.2% of the time.

- These are historical numbers, from older screening tests. Modern tests are much better (around 99.8% specificity), but even then only about 1 in 3 positive screens is a true positive at 0.1% prevalence: 99 true positives vs. about 200 false positives per 100,000. That's why a positive screen is always followed by a confirmatory test before anyone is diagnosed.

- My point here is not that these tests are worthless (two slides on, "Does this mean tests are useless?" takes that up). Rather, what I want to point out is that probability is often unpredictable and unintuitive.

# The base rate paradox {#base-rate-paradox}

- Name the thing we just counted. The base rate paradox: when something is rare, most positive results are false, even from an accurate test.
- The same count as the table, as a picture, with 1,000 people. First frame: HIV prevalence is 0.1%, so one of them has it. Point at the single blue square. That's the base rate.
- Click. The test catches that one person. But it also wrongly flags 3% of the other 999: about 30 red squares.
- Click. 31 positive results, and only 1 is real. About 3%, the same 3.2% as the table.
- The test isn't bad. The problem is that the healthy group is so much bigger that even a small error rate in it swamps the one true case.
- Keep this picture in mind. It comes back, almost square for square, when we ask why most published research is wrong.
- Next: the app lets students change the prevalence and the test accuracy and watch this happen. Then the obvious question: does this mean tests are useless?

# Base Rate Paradox Demo {#baserate-demo}

- The same calculation, with sliders. Left: prevalence (0–10%), sensitivity and specificity, starting at today's numbers (0.1%, 99%, 97%). Top: P( condition+ | test+ ), the positive predictive value, the number papers use for "the chance a positive is real". Bottom: 100,000 people flowing into the four cells of the table.
- It starts at 3.2%, the number from the last two slides.
- Things to try, in this order. (1) Push sensitivity to 100%: the answer barely moves. Catching every true case doesn't help when there are so few. (2) Push specificity from 97% to 99%: the false positives shrink to a third, and the answer roughly triples, to about 9%. (The modern tests' 99.8% from the table's fine print would give 33%, but the slider moves in whole percents.) (3) Raise prevalence to 1%, then 10%: the biggest change of all.
- Stop on the third one. Same test, very different answer, just from who is being tested. That's the next slide.

# Does this mean tests are useless? {#who-gets-tested}

- Before the first click, ask the room: who actually gets an HIV test? Someone with symptoms, a known exposure, a partner who tested positive, a pregnancy check-up, a visa medical.
- Click: "Not at all, because they're not administered randomly."
- Click: the table, with its first row: everyone, tested at random. That's the 3% we counted. Visa screening (the US did it for immigrant visas until 2010) is close to this row: nobody was tested because they seemed at risk.
- Click: a group with higher risk, where 1 in 100 has HIV. The same positive result now means 25%. The fine print appears with it: every row uses the same test.
- Click: a group with even higher risk, say people who come in with symptoms or a known exposure, where 1 in 10 has HIV: 79%.
- The shares are illustrative, not measured. Don't defend them; the point is the direction and the size.
- Last two clicks: results are meaningful only relative to what we already know, and the same test gives the same result but is 3% accurate for one person and 79% for another.
- Same test, same result. The answer went from 3% to 79% because of what we knew before the test: who this person is, and why they came in. A test result is never read on its own; it changes what we already believed.
- "What we already know" is in red because it's the prior. Don't name it yet; the updating section does ("You already understand Bayesian updating"). It comes back on "Numbers don't speak for themselves" and "The science comes first".

# So why is most published research wrong? {#why-research-wrong}

- Now we close the loop on Ioannidis. His argument is the HIV example in disguise: "has HIV" becomes "the idea is true," and "tests positive" becomes "gets a significant result."
- First frame: 1,000 ideas that researchers test. Most new ideas are wrong, so only 10 are true (the blue squares). That's the "HIV is rare" part.
- Click. Good studies catch most true ideas: 8 of the 10 light up.
- Click. But they also get a significant result for about 5% of the false ones, purely by chance: about 50 red squares, scattered everywhere.
- Click. 58 discoveries, and only 8 are real: about 14%. Let that land before moving on.
- The point isn't that scientists are dishonest or bad at math. The math is fine. A significant result answers P(data | hypothesis), and when true ideas are rare, P(hypothesis | data) is very different. (That's where we go in two slides.)
- 1 in 100 is one scenario, realistic for exploratory work. Confirmatory research can be closer to 50%, and then most discoveries are real. The next slide's table shows the range, if there's time.
- Don't resolve it yet. First: why do smart people get fooled? Then updating, and why it's okay: once you expect many single findings to be wrong, you stop treating one p < 0.05 as truth and start treating each one as a nudge to what we already know, not the final word.

# Types of research, by the numbers {#research-math}

- First "Mechanics" slide: point out the tag in the corner. It means this is the machinery under the hood. Nice to follow, not necessary for the big picture. Optional: it generalizes the 1,000-ideas picture to other kinds of study.
- A study is a test of an idea, so it has the same two kinds of accuracy as the HIV test. Sensitivity: of the true ideas, the share it finds. Specificity: of the false ideas, the share it correctly rejects.
- Papers use different names for the same two numbers, which is the second half of each definition line. Sensitivity is called power. Specificity is 1 − the significance level α. α = 1 − specificity is the false-positive rate, usually set at 5%. β = 1 − sensitivity is the miss rate. Power, a term students will meet in papers, is just sensitivity (1 − β). Same idea as the HIV test, counted from the other side.
- Every cell is the same calculation as the HIV table: (true share × sensitivity) / (true share × sensitivity + (1 − true share) × (1 − specificity)).
- Read down the rows. A large trial of a treatment with strong earlier evidence is usually right (94%). A plausible new idea is right more often than not in a large study (64%), but not in a small one (31%). The search for new effects, our 1,000 ideas, is usually wrong (14%), and worse with small samples (4%). Same sensitivity, same specificity; the difference is how many tested ideas were true to begin with. That's the takeaway line.
- Sensitivity of 20% (β = 80%) isn't a strawman. Median power is around 20% in fields like neuroscience (Button et al. 2013) and economics (Ioannidis, Stanley & Doucouliagos 2017).
- The p-hacked row: α = 5% assumes one pre-planned test. Trying several outcomes, subgroups or controls until something works pushes the real false-positive rate up; 20% is illustrative, and Simmons, Nelson & Simonsohn (2011) showed common choices can push it past 60%. When sensitivity equals 1 − specificity (20% each), a significant result is equally likely whether the idea is true or false, so the chance stays at the starting 1%. The study taught us nothing.
- If asked about fixes: a stricter threshold (p < 0.005, Benjamin et al. 2018) helps but needs much bigger samples. Replication works better: a finding that keeps holding up in new studies earns trust no threshold can give it.
- Ask the room: which row does your own field live in?

# Statistical significance (revisited) {#statistical-significance-revisited}

- Clicks: (1) the red phrase lights up, (2) then the blue one. (3) They turn into P( data | hypothesis ), each phrase sitting under the part it becomes. (4) The reverse appears beside it, P( hypothesis | data ): the same two words, swapped. (5) The closing line.

There's a lot of very dense jargon here, but we don't need to unpack it all. Let's just take a minute to think about what is being measured here.

I don't want to get bogged down at this point in the specifics, but the structure is important: In frequentist analysis, we're treating our hypothesis as a fixed assumption and our data as a probability.

That's fine, but it's not how we actually experience the practice of science most of the time. It's not how we think about uncertainty. More often, our data are the thing we know, and our hypothesis is the thing we're unsure of.

What we're usually actually trying to figure out is the reverse conditional dependency: 
P( hypothesis | data )
i.e., given the data we observed, how likely is our hypothesis to be true?

Both frequentists and Bayesians are interested in building links between observations and theory, but their primary measurements are structured in precisely the opposite ways.

For Frequentists, it's about P( data | hypothesis )
For Bayesians, it's about P( hypothesis | data )

This is a subtle difference, but it reveals a fundamental philosophical divide in how these two approaches think about the problem of probability.

Let me give a very concrete example.

This morning, I asked my wife if she thought the shop near our house was open. She said, "probably". What does that word probably mean?

For Bayesians, it's simple. It means that she doesn't know for sure. But, not knowing for sure doesn't mean that she doesn't know anything. Rather, based on prior knowledge of some sort or another, she considers both possibilities as plausible but the open possibility as more likely. Probability, to Bayesians, is a way of talking about the uncertainty of our knowledge.

For Frequentists, it's a bit more complicated. "Probably" here would refer to the long run frequency of different outcomes over repeated observations. If we visited the store in a million parallel universes governed by rules similar to this one, the store would be open in most of them. This is a valid way to think about things, but I want to suggest that it's a bit unintuitive. If you've ever heard somebody say that a p-value is the probability that a hypothesis is true, they are making a serious mistake.

- The closing line (click 5). Reassure people first. Lots of smart people find p-values confusing, and the reason is structural, not personal.
- Observation runs from data to the world. You see something and ask what it tells you. That's how we reason in daily life, and how ethnographers reason about an interview.
- A p-value runs the other way. It starts from a world we usually don't believe in (the null: nothing is going on), and asks how surprising our data would be there. It's a statement about the data, given an imagined world.
- The significance level α is the study's false-positive rate, the same kind of number as the HIV test's 3% (the trust table's footnote: specificity is 1 − α). It's true, and it controls something worth controlling, but it isn't P( hypothesis | data ). Treating p < 0.05 as "95% likely true" is the same mistake as treating a 97%-specific test as a 97% diagnosis. We just saw how wrong that can be.
- Call back to "Direction of conditions": it's the same slip as reading P( Rural | Sociology ) off P( Sociology | Rural ).
- Bayesian updating is the fix: it runs in the direction we actually observe.

# Bayesian Updating: What it is not {#what-it-is-not}

- McElreath's flowchart (*Statistical Rethinking*, Figure 1.1): pick the right statistical test by answering questions about your data. Many students met statistics exactly this way, as a decision tree that ends in the name of a test.
- Don't read it. Let it look overwhelming; that's the point. Each box is a special-purpose procedure with its own assumptions, and choosing among them becomes a ritual. McElreath calls these procedures "golems": powerful, but mindless, and they do exactly what they're told even when it's the wrong thing.
- The contrast for the next slide: instead of a tree of tests, one rule.

# Bayesian Updating: What it is {#bayesian-updating}

So I said that we were going to derive our entire statistics from first principles, and I meant it. Instead of a million pre-built tests, we have one process, called Bayesian updating. Everything we build will be an application of that same logic.

Frame it as science first: this is how a community of researchers changes its mind, and the formula is just that process written down. We come back to this at the end of the section ("done by people instead of a formula").

For those interested in math, I definitely encourage you to look into where the theorem comes from and how it's derived, but for our purposes, we need just one simple idea: prior × likelihood → posterior.

- The mayor example is the appendix's poll in miniature: a prior from the last election, a small survey as the data, and a belief that moves between them. The TA session works through it with the class's own prior.
- Last click: if we gather more data, today's posterior becomes the prior. Plant it; don't develop it.
- Next: they've already done this, twice.

# You already understand Bayesian updating {#already-updated}

- The payoff: nothing on this slide is new. Every number is one they counted earlier. The rule only gives the parts names.
- Prior row (visible from the start): the base rate. "Does this mean tests are useless?" showed it's the number that matters most, and it's the one that comes from knowing about the world.
- Click: the likelihood. How expected the result is, for each possibility: two numbers, one if the person has HIV (or the idea is true) and one if not. That's the "for each possible answer" from the last slide.
- Click: the posterior, what the counting gave: 3% and 14%.
- Click: a different prior. Same test, same study, so the likelihood row doesn't change. Start where 10% of those tested have HIV (the "even higher risk" group from "Does this mean tests are useless?") and a positive means 79%, not 3%. Start where 10% of ideas are true (the "plausible new idea" in the research table) and a discovery is true 64% of the time, not 14%.
- Same evidence, different starting point, very different answer. That's why the prior is worth arguing about, and why it has to be written down where others can see it ("Most studies are wrong..." comes back to this). The poll's "What if I'd started from a different prior?" slide lets them try it.
- Click: the umbrella. Back to the rain slides: July is the prior (rain is likely), the clouds are the data, and grabbing the umbrella is acting on the posterior. Nobody needs a formula for that.
- Click: the point of the slide. Updating isn't something this course invented; it's how everyone learns from experience. Ask the room for something they changed their mind about this week, and what made them change it: that's a prior, some evidence and a posterior. What statistics adds is doing it out loud, with the prior written down where others can check it. "Most studies are wrong..." picks that up.

# Bayesian Updating Example {#stones-demo}

- The same rule, run one observation at a time. A bag holds 9 stones, each blue or black. We don't know how many are blue, so there are 10 possible bags: 0 blue, 1 blue, ..., 9 blue.
- Leave "Contents of the bag" on Hidden: the app picks a bag at random, and nobody knows which. (Picking one instead lets you show that the posterior homes in on the truth.)
- Before any draws, the graph is flat. That's the prior: no bag is more plausible than another.
- Draw a stone (it goes back in the bag). The table counts, for each possible bag, the ways it could have produced what we've drawn so far: a bag with 3 blue stones has 3 ways to give a blue one and 6 ways to give a black one. Multiply across the draws. That's the garden of forking paths from "Counting the ways a thing could happen", one branch per draw.
- The ways, rescaled to add up to 1, are the posterior: the graph. The gray ghosts are the earlier posteriors, so the room can watch belief move with each draw.
- The thing to say out loud: after each draw, the last posterior is the starting point for the next. Prior × likelihood → posterior, again and again.
- "Random" draws one stone; shift-click draws ten. After many draws the graph narrows around one or two bags: more data, more sure. "Reset" clears the draws.
- If someone asks why some bars drop to zero: the all-black bag can't produce a blue stone, so it's ruled out by the first blue draw, and the all-blue bag by the first black one. A possibility that can't produce the data gets no ways at all.

# Bayes' theorem {#bayes-theorem}

- Another "Mechanics" slide. If you only remember "prior × likelihood → posterior", you're fine.
- After the click, it's the same rule as before, written as a formula, in the same colors. Walk through the terms in order: the prior (what we believed), the likelihood (how well the data fit each belief), the posterior (what we believe now).
- The bottom, P(data), is the same whichever belief we're considering, so it only rescales the answer to add up to 1. Drop it and you're left with prior × likelihood → posterior.
- Two things worth noticing. First, the formula reverses a conditional: it turns P(data | belief), which is what a test or study gives us, into P(belief | data), which is what we want. That's the HIV test again. Second, it describes updating: we believed something, we saw something, and now we believe something slightly or very different.
- It opens in the textbook form, P(A | B) = P(B | A) P(A) / P(B), which some students will have seen. Click: A becomes belief and B becomes data, term for term, and the colors appear.

# Most studies are wrong... {#is-that-a-problem}

- Back to the capybara: most published research is wrong, and that's okay.
- It's okay because a study was never supposed to be a verdict. It's one observation. Single observations are messy, and they often contradict each other.
- Ask the room: what makes science work? Most people say experiments, or careful observation. Push back: what makes science work is people, groups of scientists arguing about how to fit many observations together.
- The three steps are Bayesian updating in plain words, in the same colors as prior × likelihood → posterior. Assume: a prior is an assumption we write down, so others can see it and argue with it. Assumptions we hide can't be checked. Look: new data test it; if what we saw fits what we assumed, confidence grows, and if not, the assumption moves. Update: the posterior is the improved assumption, and tomorrow it's the prior. No single step has to be right. The process gets better.
- Then the line that ties it to the formula: prior × likelihood → posterior, done by people instead of a formula. The formula is a model of how science already works, not the other way round. That's why we can be relaxed about any single study being wrong.
- The big statement: science isn't the experiments we do, it's the debates we have about them. Over time, those debates make us less, and less, and less wrong.

# Numbers don't speak for themselves {#objective-subjective}

- Read the quote. Students will have heard it, and some will half believe it.
- Click: the Spider-Men. Let the laugh happen. Both camps have said this about the other, and both are a little right, which is the point of the table that comes next.
- Both kinds of work have an observational part and an inferential part. We can call the observation "objective" if we want: the survey responses are what they are, just like the interview transcript is what it is.
- The first thing in the quantitative row is today's lecture: even a perfect measurement is one draw, and deciding that a pattern isn't just chance is an inference, not an observation. The rest of the row is the rest of the course.
- Some inferences are almost mechanical. But the interesting ones, about causes, about people we didn't observe, about what would happen if, are always built on strong assumptions: what causes what, how the data were generated, which priors are reasonable. Those are as subjective as the ethnographer's assumptions about what people meant. A number only tells us something against a background of what we expected.
- So the difference isn't between objective and subjective fields. The job in both is the "written down where others can argue with it" from the last slide: state the assumptions openly so others can challenge them.
- Nearly every important choice happens before any numbers: what question to ask, what to observe, who to include, what to assume. The calculation comes last.
- That means students can already critique statistical arguments without the mechanics. Ask what a study assumes, how its data were made, and what else could explain the result. Those questions don't need a formula.

# The science comes first {#science-first}

- The closing idea of the lecture. Statistics, like any research, weighs new observations (the data, in blue, like "Look") against what we already assume (in red, like "Assume"). Sometimes the data confirm what we thought; sometimes they challenge it.
- First bullet: the base rate paradox is this slide's point, already demonstrated. The base rate is prior knowledge. Read the test result without it and an accurate HIV test points the wrong way; read a significant result without it and most "discoveries" aren't real. Data without assumptions don't just say less, they mislead.
- Second bullet: the callback to the tea slide, "interesting predictions make big assumptions". Every model that says something interesting assumes things: who answered, what causes what, how the data were made. Don't explain them yet. Week 2 starts on them (a pattern that's real and still doesn't mean what it seems), and Weeks 3 to 5 build on that.
- Third bullet: even when they're written in math, these are claims about the world. "Each answer is an independent coin flip" is a claim about how people answer surveys. That's why ethnographers, economists and doctors can all question them.
- The big statement: the math is the least interesting part of statistics, and the course looks at everything else. Week 5 comes back to it ("Ask what's missing and what's hidden").
- Say it out loud here: It's a relief for many students. The calculation comes last, and it's the part a computer does. This course puts everything else first: the question, the assumptions, and how the data came to be.

# What's ahead {#whats-ahead}

- One row per week, and each has one punchline. Read the punchlines, not the topics: if students remember five sentences from this course, these are the five.
- The order is the argument. Week 1: a study is one observation, not the truth, so science is updating. Week 2: describe variation as distributions, then meet the two ways a pattern misleads, chance and hidden causes. Weeks 3 and 4: draw the causal story and use it to decide what to control for. Week 5: use all of it on real studies and their own questions.
- Most stats courses go tests first, science later. We're doing it the other way round.
- That's the end of the main lecture. What follows is the appendix: the mayor poll, which they'll work through with the TA in the second class.

# Practical work: Election polling {#poll-demo}

- We're going to run the whole prior → likelihood → posterior loop on one concrete question: what share of voters will choose the current mayor?
- Be upfront that this model is too simple for a real poll. Real surveys aren't random samples: some groups answer more than others, and not everyone votes. Post-stratification and turnout models fix that, and we'll build them later. Today the point is the logic of updating.
- The order: how to read the graphs, the three steps on the class's own prior and survey, then one slide that reads the class's posterior to answer the question, "What to try" (three questions to explore), and three "What if" slides that answer them, changing one input at a time. The full workflow and the formal model are at the end, for anyone who wants them.

# Reading these graphs {#poll-graphs}

- One idea on this slide, and it's the one that disorients people at first: these graphs don't show an answer. They show every possible answer at once, each compared with the others.
- Point at the spikes. There's one for each value of the mayor's share in steps of 5: 0%, 5%, 10%, all the way to 100%. These are the same 21 points they'll drag on Step 1, and the same 21 rows in its table. Each spike's height is how plausible that value is; the curve runs through their tops.
- If someone asks about 37%: the real share can be anything in between. Twenty-one points are enough to draw a shape, and Steps 2 and 3 fill in the values between them when they calculate.
- The height has no units, and the actual numbers don't matter. What matters is how the heights compare: 40% is about 3 times as plausible as 20%, and about 7 times as plausible as 70%. Rescale the whole graph and nothing changes.
- The prior, the likelihood and the posterior are all drawn this way. They're the same kind of map, the relative plausibility of every value, built from different things: what we believed before, what the survey says, and both together.
- Students have seen this already: the bag of stones had 10 possible answers, one point each. Here there are 21.
- From here on, every curve on the poll slides is scaled to its own peak, so they all reach the same height (the y axis says so). That keeps the prior the shape the class drew, however tall or flat the other curves get. Compare shapes, positions and widths; don't compare heights between curves.
- Don't define "distribution" yet. Week 2 is all about it; today they just need to read the picture.

# Step 1: The prior {#poll-prior}

- Ask the room to draw their own prior. Someone who remembers the 60% result from last election might pile weight around 60%. Someone with no opinion might leave it flat.
- The prior is red here and on every slide after, like the "prior" in prior × likelihood → posterior.
- Two ways to shape it, no switching. Press anywhere on the plot (not on a point) and sweep across it: the curve follows, freehand. It's the quickest way to sketch a whole prior.
- Grab a point and move it up or down to fine-tune. Its neighbors follow, less and less farther out, so one drag makes a smooth hump. It pulls but never pushes: raising a point lifts the lower points around it, but leaves higher ones alone until you pass them. So you can shape one side of a hump without moving the peak. A drag that moves sideways off its point's column turns into freehand drawing.
- The line through the points is a smooth curve, not straight segments, and every later slide uses the same curve. It's an assumption about what you meant between the points, a gentle one: it passes through every point and never adds a bump. That's fine for a deliberately rough way of drawing a belief.
- The "Score" column is just the height you drew. "Probability" rescales the scores so they add up to 1. Only the *shape* matters.
- This prior carries over to every slide after it, so whatever is drawn here is what gets updated.

# Step 2: The likelihood {#poll-likelihood}

- This is where the data come in. The sliders set the survey: how many people we asked, and what share said "mayor". It starts at 4 of 20 (20%).
- The red curve is the prior from Step 1, for comparison. The new thing is the dashed blue curve.
- Same question we asked about the HIV test, turned around: for each possible θ, how likely are the data we saw?
- Read the table: 4 of 20 is quite likely if θ is 20% (0.22), much less so at 40% (0.035), unlikely at 60%, and almost impossible at 80%.
- Move the survey size up to a few hundred at the same 20%: the curve gets much narrower. More data rule out more values of θ.
- Point out that the likelihood curve is not a probability distribution over θ. It's a set of answers to "P(data | θ)" for many θs, and only its shape means anything.
- Whatever survey is set here is the one Step 3 and the slides after it use.

# Step 3: Prior × likelihood → posterior {#poll-posterior}

- At each value of θ, multiply the prior's height by the likelihood's height, then rescale so the total is 1. That's the posterior. (On the plot each curve is scaled to its own peak, so read where the posterior sits and how wide it is, not how tall: narrower means more sure.) Nothing else is going on. Where the prior is zero, the posterior is zero, however well the data fit.
- With a flat prior, the green curve sits right on the dashed blue one. With a 60% prior, it lands in between.
- Go back to Step 2 and raise the survey size to a few hundred. Back here, the likelihood is narrower, and the prior matters less and less.
- "P( mayor wins )" is the share of the posterior above 50%. The next slide, "Answering the question", shows it.
- "Make this posterior my new prior" copies the posterior back onto the 21 draggable points, sets the survey back to 20 people, and goes to Step 1 so everyone sees the new prior. Change the survey on Step 2 for a "second poll". It's coarse, since 21 points can't capture a very narrow curve, but it shows the idea.

# Answering the question {#poll-answer}

- The posterior is a whole distribution, so we can ask it any question. The one we care about here: will the mayor get more than half the vote? The answer is the share of the posterior above 50%: the dark green area.
- The table compares it with the prior's answer, before the survey. The survey changes the answer to the question we actually asked.
- The key idea: the posterior doesn't predict a result. It's a distribution, our belief spread over every possible result, and the answer to "will the mayor win?" is how much of that belief sits above 50%.
- The bold line turns it into words: we're about this sure the mayor will get a majority. Not a yes or no.
- Connect it back to the rain slide. "A 31% chance of rain" didn't mean the weather was random; physics decides it. It meant we were uncertain. Same here: the election isn't a lottery, and the percentage describes how sure we are about it, given what we assumed and what we saw.
- The footnote is the slide's fine print, and the course's point in miniature: the model only knows what share of people say "mayor". Calling that "the mayor wins" assumes the survey represents the people who'll actually vote, that they vote the way they said, and that more than half wins. The number is only as good as those assumptions.
- If someone asks: strictly this is "more than half the vote". In an election with several candidates, the mayor can win with less than half, and modelling that would need every candidate's share, not just the mayor's.

# What to try {#poll-try}

- This slide sets up the next three. Each question has its own tool: a different prior, a different survey size, a different result. Read the questions, let students guess, then go to the slides to check.
- Let students drive. Good pairs to compare: a flat vs. a strong prior with 20 people, then the same two with 1,000.
- For later, if there's time: Step 3's "Make this posterior my new prior" button, then a second survey on Step 2, shows today's posterior becoming tomorrow's prior.
- The closing question is the habit we're building, in two halves. First: how much does the answer depend on the assumptions we can change here (the prior, the survey)? The next three slides make that concrete. Second: which assumptions can't these sliders touch? The coin-flip model assumes a random sample, independent answers, and people voting the way they said. Weeks 2 to 5 are about those.

# What if I'd started from a different prior? {#whatif-prior}

- From here, three slides each change one input and keep the others as the class set them. The gray dotted curve is the class's own posterior from Step 3, so there's always something to compare with. The table puts the two side by side.
- This one changes the prior. "Move it" slides the class's prior left or right; "How sure" makes it flatter or sharper. The buttons are a few ready-made versions: no opinion at all, less sure, more sure, and the same shape 20 points lower or higher.
- Things to point out: with 20 people, a different prior moves the answer noticeably. A flat prior ("No opinion") puts the posterior right on the likelihood. A more sure prior drags the posterior toward itself.
- This is the honest answer to "isn't the prior subjective?": yes, so show how much it matters. If the answer barely moves across reasonable priors, the data are doing the work. If it moves a lot, say so.
- If the class left its prior flat, moving or sharpening it changes nothing, and the slide says so. Draw a hump around 60% on Step 1 first.
- Changing the prior or survey on Steps 1–3 resets all three slides to the class's own inputs.

# What if I'd asked more (or fewer) people? {#whatif-size}

- Same prior, same share saying "mayor", different survey size. The slider runs from nobody to 2,000 people, on a scale that gives small surveys as much room as big ones.
- "Nobody": no data, so the posterior is just the prior. Five people: it barely moves. A thousand: the likelihood is a narrow spike, and the posterior sits on it whatever the prior was.
- The 90% range shrinks as the survey grows. That's how sure we are, and it's what more data buy.
- Tie it back to the start of the lecture: this is why one small study shouldn't settle anything, and why many studies together can.

# What if the survey had been different? {#whatif-result}

- Same prior, same number of people, different answer. Slide the share saying "mayor" from 0% to 100%.
- Watch the posterior follow the data, but not all the way: it stays between the prior and the likelihood. With a strong prior and a small survey, a surprising result moves it only part of the way.
- A good question for the room: what result would it take to make P( mayor wins ) better than even? That's a question about the data we'd need, asked before collecting it.

# The model, written formally {#poll-model}

- Mechanics slide, for anyone who wants the notation behind the widgets. The formal model is two lines. The first line is the likelihood (how the data are generated, given θ), and the second is the prior (what we believe about θ before any data: here, whatever the class drew on Step 1).
- Nobody needs to read Binomial notation fluently yet. The point is that the whole model is just a likelihood and a prior. The table is the key: n and k are data we know, θ is the one thing we don't.
- The question students may be sitting on: where did Step 2's likelihood curve come from? From line 1. Once we say how the data were made, the chance of our survey at any θ follows. Writing that down is one of the main jobs of a model.
- The slide's answer: Binomial(n, θ) gives the chance of every possible k, and working that out at each θ gives Step 2's curve. That's the step from "a statement about k" to "a curve over θ", which is what usually puzzles people.
- If someone asks how the binomial gets its numbers, say it aloud rather than writing it: the chance that k particular people say "mayor" is θ^k, the chance everyone else doesn't is (1 − θ)^(n−k), and there are "n choose k" different groups of k people who could have been the ones (4,845 ways to pick 4 of 20). Multiply them. It's the garden of forking paths from earlier, with more flips. At θ = 20%, 4 of 20 comes out at about 0.22, the number in Step 2's table.
- The coin-flip picture carries assumptions: everyone answers independently, with the same chance θ. A real survey breaks both (households, neighborhoods, who picks up the phone), which is what the later weeks are about.

# More resources {#more-resources}

- For students who want to go further. The book is where this course's approach comes from: Bayesian, causal models first, built up from simple counting.
- The YouTube lectures cover the whole book, for free. They're a good way in for anyone who'd rather watch than read, and the early lectures line up well with Weeks 1 to 3.

# The Bayesian workflow {#workflow}

- Reference slide, for anyone who wants the whole road map. Don't teach it today; Week 3 does, and workflow.qmd works through all ten steps on a real question.
- The mayor poll touched a few of the steps: asking the question, writing the formal model, computing the estimate, and the "What if" slides, which are step 10 (how much does the estimate depend on our assumptions?). It skipped the causal model and the simulation, which is where Week 3 starts.
