
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

- Thats a paradox. 

- It's okay for a very simple reason. Statistics is observation, and observation is always messy. It's only a problem if we expect it to be tidy.

- To make sense of it, we need to understand what statistics is. We need to stop treating statistics as mathmatical rituals and start treating it like a way to reflect on and update our own thinking. Thats the goal of this course.

## This week's goals {#goals}

- This approach is null hypothesis significance testing, the most familiar part of frequentist (or "classical") statistics. Most people just call it "statistics".
- There's nothing wrong with frequentist approaches. They are valid, capable, convenient and useful.
- The math is 100% valid.
- But it's a terrible way to learn statistics
- The way it thinks about probability is deeply, deeply unintuitive.

# Probability {#probability}

- Imagine asking a friend if it will rain tomorrow. They say, "Probably". What does that word "probably" mean?
- Intuitively, probability is a way of talking about uncertainty.
- To frequentists, it's a way of talking about the long run outcome of repeated measurements. Strange.
- We're going to build statistics using a more intuitive set of concepts.

# Probability is counting {#counting}

- Before any notation: probability is counting. Count everything that could happen, count the ones you care about, compare the two.
- Take the examples slowly. Students already know all of these. The point is that they already understand probability; they just haven't been told that's what it is.
- The class example is made up. Swap in real numbers from the room if you know them.
- Flag the promise: every probability in this lecture is a count. The HIV table counts 100,000 people. The published-research table counts 10,000 hypotheses. If they ever get lost, they can go back to counting.

# Counting ways {#counting-ways}

- This diagram is a "garden of forking paths" (McElreath's phrase, borrowed from Borges). Start at the dot. Each flip, every path splits in two: heads or tails. After four flips there are 2 × 2 × 2 × 2 = 16 paths, and each one is a different way the four flips could go.
- Trace one path with your finger, e.g. H, T, T, H. Read the number at its tip: the heads on that path.
- The blue paths are the ones that end with exactly two heads. Count them together: 6. So exactly two heads is 6 ways out of 16, a bit over a third.
- Ask the room first: what would you guess? A common answer is 1 in 5, because there are five possible head counts (0 to 4). But those five aren't equally likely: there's only one way to get 0 heads and six ways to get 2. Count paths, not outcomes. d'Alembert made the same mistake with two coins in 1754, arguing that one head out of two flips was 1 in 3.
- The row of counts (1, 4, 6, 4, 1) is worth pausing on. It's the shape of a distribution, and it comes back in Week 2.
- Foreshadow the bag-of-stones demo. Bayesian updating is the same move: for each possible bag, count the ways it could have produced the stones we drew. More ways means more plausible. (This is how McElreath introduces it in *Statistical Rethinking*, ch. 2.)

# Let's count {#lets-count}

- Actually do it. Count the room, type it into "People here," ask for hands, type the count into "Hands up." The dots fill in live.
- Swap the question for anything quick: came by bus, has a sibling abroad, slept less than six hours.
- Make the distinction explicit. "9 out of 25 had tea" is a count, a fact about the room. Nothing about it is uncertain.
- It becomes a probability when we use it to say something we don't know. Ask: if I picked one of you at random, without looking, what's the chance they had tea? They'll answer without thinking. That answer is a probability, and they built it from the count.
- This distinction matters later. Data are counts and measurements. Probabilities are statements about what we don't know: the next person, the whole population, next year's rain, whether a hypothesis is true.
- Bridge: the next two slides are just conventions for writing these counts down.

# Probability: Convention 1 {#convention-1}

- The format part is quick: 0 is impossible, 1 is certain, and percentages are the same numbers times 100.
- Spend the time on the nuance. Ask: what does "a 31% chance of rain tomorrow" actually mean? Is the weather random?
- Most people will say no, or not really. Tomorrow's weather is decided by physics: wind, pressure, moisture, the monsoon. If we knew everything, there'd be nothing random about it.
- So the randomness isn't in the sky. It's in us. "31%" describes how uncertain we are about a day when all we know is that it's a day in Kathmandu. It's as if we picked a date from the calendar without looking.
- This is the Bayesian way of thinking about probability, and it's the one we'll use all course: probability describes our knowledge, not a property of the world. A coin flip is the same: a perfect physicist could predict it. We call it 50% because we can't.
- Connect back to "Let's count": the count (about 113 rainy days a year) is a fact. The probability (0.31) is what we say about a day we don't know.

# Probability: Convention 2 {#convention-2}

- Pure notation. P( something ) is read "the probability of something."
- The examples are deliberately ones they've already worked out: rain, coins, the die and the raffle from "Probability is counting."
- Emphasize that whatever goes inside the brackets is the thing we're unsure about. That habit matters later, when the thing inside is a hypothesis.

# Probability: Convention 3 {#rain}

- The bar is read "given." P( rain | July ) is "the probability of rain, given that it's July."
- A condition narrows down which cases we count. P( rain ) counts all days. P( rain | July ) counts only July days.
- Adding information changes the probability, sometimes a lot: from 31% overall to 81% in July and 3% in December. Same city, same sky.
- This is also the Convention 1 point again: the more we know about a day, the less uncertain we are.

- These numbers come from the past: the last five years (2021–2025) of daily records from the Kathmandu Airport weather station. We're using history as a guide to what's likely in a given month. Say the assumption out loud: next year will be like the average of the last five.
- The record has gaps; each month has 58–97% of its days. We fill the missing days at that month's average rate, so every month is "out of" five full years: 150 days for 30-day months, 155 for 31-day months, 140 for February. That's why the denominators differ.
- April is a good example of how much the choice of years matters: using 2019–2021 instead, April came out at 43%; 2021–2025 gives 23%. A small reminder that every number rests on choices about which data to use.
- That doesn't make them exactly right for this year. They're a reasonable basis for a probability, not a precise forecast.
- In fact, the climate is definitely changing, and we could model those changes (trends over time, monsoon timing, and so on). For now, we'll just treat historical data as our basis for prediction.

# Conditional risk {#conditional-risk}

- Give people a moment to read it. Let the laugh happen.
- The joke is about conditioning. "One in 7,000,000" is P(killed by lightning) for an average American over a year. Almost none of those people were standing outside in a thunderstorm at the time.
- The two people in the comic aren't average. They're outside, in a storm, right now. The number that matters for them is P(killed by lightning | outside in a storm), which is far higher.
- The "one in six" in the caption is a joke, not a statistic. Don't defend the number; the point is the conditioning.
- Takeaway: an unconditional probability can be correct and still be the wrong number for your situation. Always ask: conditional on what? This sets up the HIV example, where the condition is a positive test.

# Applied Probability {#applied-probability}

One common use of statistics is to evaluate the accuracy of predictive tests.

I want to illustrate a very famous example involving HIV testing. This is relevant because, until 2010, anyone from Nepal applying for an immigrant visa to the US had to take an HIV test as part of the required medical exam.

# Applied Probability (continued) {#base-rate}

- This, as we can see, an imperfect but reasonably good test. There's a problem, though. Can anybody spot it?

- If we already know somebody's HIV status, why would be bother giving them a test? Far, far more often, when we think about the accuracy of a test, we are actually interested in the reverse question:

- Sensitivity and Specificity describe a situation where we already know somebody's HIV status. Why test if we already know? What we usually really want a different thing

-Think about that. If you pick a person at random, give them an HIV test and it comes back positive, there is only about a 3% chance that they actually have HIV. 97% of them are getting a positive test (and, likely, quite a scare) erroneously.

- This goes against most people's expectations. Why this happens actually isn't that hard to understand. Of people with HIV, 99% will get a positive test result.
- Of people who don't have HIV, only 3% will get a positive test result.

- But, the important fact is that HIV is actually quite rare. 3% of a big population is bigger than 99% of a very small population.

- So, this test is 99% accurate at detecting HIV among people who have it, but for a random person getting a test, a positive test result is only accurate 3.2% of the time.

- These are historical numbers, from older screening tests. Modern tests are much better (around 99.8% specificity), but even then only about 1 in 3 positive screens is a true positive at 0.1% prevalence: 99 true positives vs. about 200 false positives per 100,000. That's why a positive screen is always followed by a confirmatory test before anyone is diagnosed.

- My point here is not that these tests are worthless. Rather what I want to point out is that probability is often unpredictable and unintuitive.

# Statistical Significance (revisited) {#statistical-significance-revisited}

There's a lot of very dense jargon here, but we don't need to unpack it all. let's just take a minute to think about what is being measured here.

I don't want to get bogged down at this point in the specifics, but the structure is important: In frequentist analysis, We're treating our hypothesis as a fixed assumption and our data as a probability.

That's fine, but it's not how we actually experience the practice of science most of the time. It's not how we think about uncertainty. More often, our data is the thing we know, and our hypothesis is the thing we're unsure of.

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

For Frequentists, it's a bit more complicated. "Probably" here would refer to the long run frequency of different outcomes over repeated observations. If we visited the store in a million parallel universes governed by rules similar to this one, the store would be open in most of them. This is a valid way to think about things, but I want to suggest that it's a bit unintuitive. If you've ever heard somebody say that p-value is the probability that an hypothesis is true, they are making a serious mistake.

# The problem with p-values {#pvalue-direction}

- Reassure people first. Lots of smart people find p-values confusing, and the reason is structural, not personal.
- Observation runs from data to the world. You see something and ask what it tells you. That's how we reason in daily life, and how ethnographers reason about an interview.
- A p-value runs the other way. It starts from a world we usually don't believe in (the null: nothing is going on), and asks how surprising our data would be there. It's a statement about the data, given an imagined world.
- So it can't tell you how likely your hypothesis is. Treating p < 0.05 as "95% likely true" is the same mistake as treating a 97%-specific test as a 97% diagnosis. We just saw how wrong that can be.
- Bayesian updating is the fix: it runs in the direction we actually observe.

# So why is most published research wrong? {#why-research-wrong}

- Now we can close the loop on Ioannidis. His argument is the HIV example in disguise.
- Swap the labels: "has the disease" becomes "the hypothesis is actually true," and "tests positive" becomes "gets a significant result (p < 0.05)."
- The base rate matters just as much here. Genuinely novel, interesting hypotheses are rare — most of the things researchers test are not true. That's the "disease is rare" part.
- With a 1% base rate, 80% power, and the usual 5% false positive rate, only about 14% of significant results point to a true hypothesis. The other 86% are false positives, exactly like the false-positive HIV tests.
- The 1% base rate is one scenario, not a universal figure. It's low, but realistic for exploratory work. Confirmatory research (e.g. a well-designed trial of a plausible treatment) can have base rates closer to 50%, and then most significant results are true. The variation across fields is the point.
- 80% power, on the other hand, is generous. Median power is around 20% in fields like neuroscience (Button et al. 2013) and economics (Ioannidis, Stanley & Doucouliagos 2017). At 1% base rate and 20% power, only about 4% of significant results are true.
- On top of that, researchers run many comparisons, and p-hacking inflates the effective false positive rate well past 5%. Push those and the true-discovery rate drops further.
- So the punchline isn't that scientists are dishonest or bad at math. The math is fine. It's that significance testing answers P(data | hypothesis) when the base rate makes P(hypothesis | data) the thing that actually matters — and the two can be wildly different.
- This is why it's okay. Once you expect most single findings to be noise, you stop treating one p < 0.05 as truth and start thinking like a Bayesian: accumulating evidence and updating.

# How bad does it get? {#scenarios-grid}

- Mechanics slide. Every cell is the same calculation as the HIV table: (base rate × power) / (base rate × power + (1 − base rate) × α).
- Read across a row: lower power hurts, but not catastrophically when the base rate is high. At 50% true, even 20% power gives 80%.
- Read down a column: the base rate is what really drives it. At 80% power, going from 50% true to 1% true drops us from 94% to 14%.
- The perfect study: even with 100% power, a 1% base rate gives only 17%. The false positives come from the 99% of false hypotheses, and power does nothing about them. No study design rescues an unlikely hypothesis.
- The last column is p-hacking. α = 5% assumes exactly one pre-planned test. Real analyses have forks: which outcome, which subgroup, which controls. Nobody has to be dishonest; it's usually a sincere search for "the right analysis" that stops when something works. 20% is illustrative; Simmons, Nelson & Simonsohn (2011) showed a handful of common choices can push the false-positive rate past 60%.
- In that column, power equals α, so a significant result is equally likely whether the hypothesis is true or false. The posterior equals the prior: each cell is just the base rate. The study taught us nothing.
- If asked about fixes: a stricter threshold (p < 0.005, Benjamin et al. 2018) lifts the 1% row from 14% to 62% at 80% power, but needs much bigger samples. Replication works better, which is the next slide.
- Ask the room: which row does your own field live in?

# Scenarios: replication {#scenarios-replication}

- This is the HIV confirmatory test again. A positive screen at 3% isn't a diagnosis, so you test again. Same here.
- Each row uses the previous row's answer as the new base rate. That's Bayesian updating, before we've even named it. Today's posterior is tomorrow's prior.
- At 80% power: 1% → 14% → 72% → 98%. Three independent significant results and we can be fairly confident.
- At 20% power it takes longer, but it still gets there: 1% → 4% → 14% → 39% → 72% after four results. (Not on the slide; mention it if someone asks about weak studies.)
- The caveat matters. This only works if replications are independent. If every lab uses the same flawed measure, or only successful replications get published, the evidence doesn't really add up. That's why the scientific process includes critique, not just repetition.

# Bayesian Updating: What it is {#bayesian-updating}

So I said that we were going to derive our entire statistics from first principles, and I meant it. Instead of a million pre-built tests, we have one process: Bayesian updating

A million tests. We have one process, called Bayesian updating. Everything we build will be an application of that same logic.

For those interested in math, I definitely encourage you to where the theorem comes from and how it's derived, but for our purposes, we need just one simple idea:

# You've already done this {#prior-likelihood-posterior}

- Read the definitions row first, then go down the examples. The point: the HIV test and the published-research table were Bayesian updates all along. We just didn't use the names.
- In the HIV row, the prior is prevalence, the likelihood is sensitivity and the false-positive rate, and the posterior is P(HIV+ | test+).
- In the research row, the prior is the base rate, the likelihood is power and α, and the posterior is P(true | significant).
- The mayor poll is the same thing with many possible answers (every vote share from 0 to 100%) instead of two. We'll do it live in the demonstration.
- Address the obvious question head on: "Isn't the likelihood backwards too, like a p-value?" Yes. On its own, it's P(data | belief). A p-value stops there, and only for one imagined world. Bayes computes it for every possibility and combines it with the prior, which turns it around into P(belief | data).

# From two possibilities to many {#two-to-many}

- This is the bridge from the HIV and research examples to real models. Those had two possibilities. Most questions have many.
- Nothing about the rule changes. We just do it once for each possibility and compare.
- For the bag of stones, the likelihood is literally counting: for a bag with 3 blue stones, how many ways could we draw blue, black, blue? Compare with a bag with 6 blue. This is the "Counting ways" slide again.
- The output is a distribution, which is why the bag app shows a bar chart rather than a single number. Everything from Week 2 on is about distributions like this.

# Bayesian Updating: Why one rule helps {#bayesian-updating-how}

The nice thing about having one process is that a lot of the rules you may have learned for tests simply go away.

Tests need a stopping rule fixed in advance: if you peek at the data and stop when p dips below 0.05, your false positive rate quietly balloons. (Sequential designs can plan for interim looks, but the looks have to be planned and paid for.) Bayesian updating doesn't care when you stop. The posterior is just what you believe given what you've seen so far.

Updating is also cumulative. Last week's posterior becomes this week's prior, and you end up in the same place as if you'd analyzed everything at once.

We still make assumptions, but we choose them to fit the data and we write them down, instead of inheriting them from whichever test we picked. (This is really a contrast between picking tests and building models; frequentist GLMs build models too.) And small samples don't break anything; they leave us more uncertain, and the prior matters more, so it deserves more scrutiny.

Most importantly, it answers the question we actually care about: how plausible is the hypothesis, given the data?

# Bayes Theorem {#bayes-theorem}

- First "Mechanics" slide: point out the tag in the corner. It means this is the machinery under the hood. Nice to follow, not necessary for the big picture. If you only remember "prior × likelihood → posterior", you're fine.

That's all statistics is.

We're going to dig into an example here that is very simple, but it represents the entire philosophical underpinnings of statistical analysis:


I just want you to notice two things here:

- first the main purpose of this function is to reverse conditional dependency, turning P(B | A) into P(A | B).
- second, the combination of priors, likelihoods, and posteriors drives a process called "updating". We used to believe something, then we saw something, and now we believe something slightly or significantly different.

believe something (prior), observe something (likelihood), update beliefs (posterior)

With this simple process, we're going to do some very cool things.
instead, we have updating

# Isn't the prior subjective? {#prior-subjective}

- Someone will ask. Better to raise it ourselves.
- Yes, priors are a choice. But every method makes choices: which test, which variables to control for, when to stop collecting data, which outcome to report. Frequentist methods make those choices too; they're just less visible.
- A prior is visible. It's written down, so it can be criticized, and we can check how much the answer depends on it (sensitivity analysis, later in the course).
- With plenty of data, reasonable priors converge. With little data, the prior matters, and that is honest: the data alone can't tell us much.
- Lead into the next slide: this isn't special to statistics. Every field that learns from observation makes assumptions.

# Hard data? {#hard-data}

- Put the claim up plainly, and don't mock it. Many students have heard it from supervisors, reviewers or funders, and some believe it.
- Ask for a show of hands: who has heard this? Who has said it? It's a fair question to test, and we now have the tools to test it.

# What's true about it {#hard-data-true}

- Be fair to the claim first. The arithmetic really is objective: give two people the same data and the same model, and they get the same number.
- Numbers are also easy to share and recompute, which is a real strength.
- The catch: the arithmetic is the last and smallest step. Everything before it (what to measure, who to ask, which model) involves judgment.

# Every number today rested on a choice {#hard-data-choices}

- Walk down the table. Every number came from earlier in today's lecture, and each one moved when a choice changed.
- Rain: a different station, a different decade or a 0.1 mm threshold gives a different number.
- HIV: the 3.2% is for a random person from the general population. For people tested at a clinic because they have symptoms, the base rate is far higher, and so is the answer.
- p < 0.05: the 5% is a convention from the 1920s, not a law of nature. Choosing the test, the controls and the stopping point are all researcher decisions.
- 14%: depends on a base rate nobody can observe.
- The mayor: depends on who we reached, who answered and what prior we drew.
- None of these choices is wrong. The point is that they are choices, made by people, just like an ethnographer's choices about whom to interview and how to read what they said.

# Objective and subjective {#statistics-is-observation}

Updating is the foundation of our statistics: We believed something, we saw something, and we now believe something slightliy or significantly different from what we believed before.

What does that mean?

It's why it's okay that most published research is false.

Observation is messy. We love the mess. We live in the mess. Observation doesn't give us simple answers, but it continuously challenges and reshapes our assumptions.

Science is not the experiments we do. Rather, it's the debates we have about the experiments we do. Over time, we can become less, and less, and less, and less, and less, and less wrong.

This is why I'm always confused when people say statistics is "objective" or "more concrete", and ethnography is "subjective". I don't know what that means. Both have an observational part and an inferential part. We can call the observation part "objective" if we want: the survey responses are what they are, just like the interview transcript is what it is. Inference isn't necessarily subjective. Some inferences are almost mechanical. But the interesting ones, the ones that say something about causes, about people we didn't observe, about what would happen if, are always built on strong assumptions. What causes what, how the data were generated, which priors are reasonable: those assumptions are subjective, just like the ethnographer's assumptions about what people meant are subjective. The difference isn't between objective and subjective fields. The job in both is to state our assumptions openly so others can challenge them.

# The same standard for both {#hard-data-standard}

- The useful distinction isn't objective vs. subjective fields. It's transparent vs. hidden choices.
- Ethnography has spent decades building habits for this: reflexivity (how did I shape what I saw?), positionality (who am I to the people I studied?), thick description (show enough that readers can judge for themselves). Statistics talks less about these habits, and is worse for it.
- Tie it back to Ioannidis: "hard data" is exactly the belief that lets a single significant result pass as truth. Drop the belief, and the problem of most research being wrong becomes manageable. That's the next section.

# Is that a problem? {#is-that-a-problem}

- Back to the capybara: most published research is wrong, and that's okay.
- It's okay because nobody (should) read a study as a verdict. A study is a contribution to an ongoing conversation.
- The process around the study is what does the work: other labs try it again, critics poke holes, someone proposes a better explanation, theory says whether it even makes sense.
- The replication table showed this with numbers. One study: 14%. A field that keeps looking: 98%.
- Science works really well. It just doesn't work one study at a time.

# Statistics is observation, not answers {#observation-not-answers}

- So where do the problems come from? Not from statistics being wrong. The math is fine.
- They come from expecting too much of it. We treat a p-value as an answer to "is this true?" It isn't. It's an observation.
- Go back through today: the person terrified by one positive HIV screen, the 86% of "discoveries" that are false, the analyst trying forks until p < 0.05. Every one of those is someone believing statistics is more powerful than it is.
- Ethnographers already know how to handle this. Nobody writes an ethnography from one interview, or treats one informant as the truth. One interview is an observation. You weigh it against others, think about context, argue about what it means.
- We just need to do the same thing with statistics. A regression, a survey, a significant result: one observation, to be weighed and argued about.
- The science always comes first. The question, the theory, the knowledge of the context. Statistics serves that. It never replaces it.

# Doing science {#doing-science}

- "Science first" can sound like a slogan. Make it concrete: these are three habits, and none of them needs math.
- Question every observation. We've already done this today: a positive HIV test turned out to be wrong most of the time, and so did a significant result. Ask how the observation was made and what else could explain it. That's what an ethnographer does with an interview, too.
- Look from different perspectives. No method sees everything. A survey sees breadth, an interview sees meaning, an experiment sees cause in one place, history sees change over time. Agreement across perspectives is strong evidence; disagreement tells you where to look next.
- Think in likelihood, not proof. Science never proves anything for good. We hold beliefs with more or less confidence and move them as evidence comes in. The replication table is the picture to keep in mind: 1% → 14% → 72% → 98%.
- That last habit is exactly what Bayesian updating formalizes, which is where we're heading.

# Summary {#summary}

- Four ideas, one per part of the lecture. Read them out slowly.
- If students remember one line, it's the last one: the science always comes first.
- Check for questions here, before the course preview and the appendix.

# What's ahead {#whats-ahead}

- Keep this quick, about 30 seconds. It's a map, not a lesson.
- The order is the point. We learn to describe data (week 2), then spend two whole weeks on causal thinking (weeks 3 and 4) before we lean on any model, then practice using all of it on real studies and their own questions (week 5).
- Most stats courses go tests first, science later. We're doing it the other way round.
- That's the end of the main lecture. What follows is the appendix: the mayor poll, which they'll work through with the TA in the second class.

# Demonstration: Will the mayor win? {#poll-demo}

- We're going to run the whole prior → likelihood → posterior loop on one concrete question: what share of voters will choose the current mayor?
- Be upfront that this model is too simple for a real poll. Real surveys aren't random samples: some groups answer more than others, and not everyone votes. Post-stratification and turnout models fix that, and we'll build them later. Today the point is the logic of updating.

# The model, written formally {#poll-model}

- Mechanics slide. The formal model is two lines. The first line is the likelihood (how data are generated given θ), and the second is the prior (what we believe about θ before data).
- Nobody needs to read Binomial notation fluently yet. The point is that the whole model is just a likelihood and a prior.

# Step 1: The prior {#poll-prior}

- Ask the room to draw their own prior. Someone who remembers the 60% result from last election might pile weight around 60%. Someone with no opinion might leave it flat.
- The "Score" column is just the height you drew. "Probability" rescales the scores so they add up to 1. Only the *shape* matters.
- This prior carries over to the posterior slide, so whatever is drawn here is what gets updated.

# Step 2: The likelihood {#poll-likelihood}

- Same question we asked about the HIV test, turned around: for each possible θ, how likely is the data we saw?
- 6 of 20 is very plausible if θ is 30%, plausible-ish at 50%, unlikely at 60%, and almost impossible at 80%.
- Point out that the likelihood curve is not a probability distribution over θ. It's a set of answers to "P(data | θ)" for many θs.

# Step 3: Prior × likelihood → posterior {#poll-posterior}

- At each value of θ, multiply the prior's height by the likelihood's height, then rescale so the total is 1. That's the posterior. Nothing else is going on.
- Start at 20 people and 30%. With a flat prior, the green curve sits right on the dashed blue one. With a 60% prior, it lands in between.
- Drag the survey size up to a few hundred. The likelihood narrows, and the prior matters less and less.
- "P( mayor wins )" is the share of the posterior above 50%. That's the answer people actually want, and it's the P(hypothesis | data) we couldn't get from a significance test.
- "Make this posterior my new prior" copies the posterior back onto the 21 draggable points and clears the survey. Then run a "second poll". It's coarse, since 21 points can't capture a very narrow curve, but it shows the idea.

# What to try {#poll-try}

- Let students drive. Good pairs to compare: flat vs. strong prior at n = 20, then the same two at n = 500.
- Close by tying this back to the workflow slide: even this toy model raises the question of how much the answer depends on our assumptions (here, the prior). Answering that honestly is the habit we're building.
