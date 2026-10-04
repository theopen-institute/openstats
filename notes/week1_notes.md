
## Data Lunch: Week 1 {#title}

- Statistical backgrounds?
- Goal: ask questions and observe the world
- There is technical material, but it's easy to forget that the technical material is not the point.

## Most published research is false {#published-research}

- Article by a Greek-American medical scientist at Stanford named John Ioannidis
- purely theoretical argument, based on some very mathy arguments
- Argues that the majority of claims made in published scientific articles are wrong.

- He doesn't state a specific number, but he does say more than half and probably a lot more than half of all findings are false. 
- Others have attempted to test this claim empirically, and sure enough in many fields findings were reproducible as little as 10-20% of the time.

- This was a shocking and controversial claim when it was published in 2006, but today I think there's a consensus that Ioannidis is right.

- But how can he make this argument, purely theoretically? And what do we do with that? In medicine, sociology, economics, psychology, engineering, as much as 80-90 percent of our hard, statistical findings are just wrong.

- I'm here to tell you, it's both true and okay. Most science is wrong, and that's okay. 

- Published research findings may be wrong 80-90% of the time, but science still works. It works really, really well.

- Thats a paradox. 

- It's okay for a very simple reason. Statistics is observation, and observation is always messy. It's only a problem if we expect it to be tidy.

- To make sense of it, we need to understand what statistics is. We need to stop treating statistics as mathmatical rituals and start treating it like a way to reflect on and update our own thinking. Thats the goal of this course.

## This week's goals {#goals}

- This approach goes by a number of different names: frequentist statistics, null hypothesis significance testing, classical statistics, p-value statistics, or just "statistics"
- There's nothing wrong with frequentist approaches. They are valid, capable, convenient and useful.
- The math is 100% valid.
- But it's a terrible way to learn statistics
- The way it thinks about probability is deeply, deeply unintuitive.

# Probability {#probability}

- Imagine asking a friend if it will rain tomorrow. They say, "Probably". What does that word "probably" mean?
- Intuitively, probability is a way of talking about uncertainty.
- To frequentists, it's a way of talking about the long run outcome of repeated measurements. Strange.
- We're going to build statistics using a more intuitive set of concepts.

# Applied Probability {#applied-probability}

One common use of statistics is to evaluate the accuracy of predictive tests.

I want to illustrate a very famous example involving HIV testing. This is relevant because, until relatively recently, everybody who traveled to the US from Nepal had to take an HIV test for medical clearance.

# Applied Probability (continued) {#base-rate}

- This, as we can see, an imperfect but reasonably good test. There's a problem, though. Can anybody spot it?

- If we already know somebody's HIV status, why would be bother giving them a test? Far, far more often, when we think about the accuracy of a test, we are actually interested in the reverse question:

- Sensitivity and Specificity describe a situation where we already know somebody's HIV status. Why test if we already know? What we usually really want a different thing

-Think about that. If you pick a person at random, give them an HIV test and it comes back positive, there is a 3% chance that they actually have HIV. 97% of them are getting a positive test (and, likely, quite a scare) erroneously.

- This goes against most people's expectations. Why this happens actually isn't that hard to understand. Of people with HIV, 99% will get a positive test result.
- Of people who don't have HIV, only 3% will get a positive test result.

- But, the important fact is that HIV is actually quite rare. 3% of a big population is bigger than 99% of a very small population.

- So, this test is 99% accurate at detecting HIV among people who have it, but for a random person getting a test, a positive test result is only accurate 3.4% percent of the time.

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

# So why is most published research wrong? {#why-research-wrong}

- Now we can close the loop on Ioannidis. His argument is the HIV example in disguise.
- Swap the labels: "has the disease" becomes "the hypothesis is actually true," and "tests positive" becomes "gets a significant result (p < 0.05)."
- The base rate matters just as much here. Genuinely novel, interesting hypotheses are rare — most of the things researchers test are not true. That's the "disease is rare" part.
- With a 1% base rate, 80% power, and the usual 5% false positive rate, only about 14% of significant results point to a true hypothesis. The other 86% are false positives, exactly like the false-positive HIV tests.
- And 14% was generous. Real studies are often underpowered (closer to 50% power), researchers run many comparisons, and p-hacking inflates the effective false positive rate well past 5%. Push those and the true-discovery rate drops further.
- So the punchline isn't that scientists are dishonest or bad at math. The math is fine. It's that significance testing answers P(data | hypothesis) when the base rate makes P(hypothesis | data) the thing that actually matters — and the two can be wildly different.
- This is why it's okay. Once you expect most single findings to be noise, you stop treating one p < 0.05 as truth and start thinking like a Bayesian: accumulating evidence and updating.

# Bayesian Updating: What it is {#bayesian-updating}

So I said that we were going to derive our entire statistics from first principles, and I meant it. Instead of a million pre-built tests, we have one process: Bayesian updating

A million tests. We have one process, called Bayesian updating. Everything we build will be an application of that same logic.

For those interested in math, I definitely encourage you to where the theorem comes from and how it's derived, but for our purposes, we need just one simple idea:


# Bayes Theorem {#bayes-theorem}

That's all statistics is.

We're going to dig into an example here that is very simple, but it represents the entire philosophical underpinnings of statistical analysis:


I just want you to notice two things here:

- first the main purpose of this function is to reverse conditional dependency, turning P(B | A) into P(A | B).
- second, the combination of priors, likelihoods, and posteriors drives a process called "updating". We used to believe something, then we saw something, and now we believe something slightly or significantly different.

believe something (prior), observe something (likelihood), update beliefs (posterior)

With this simple process, we're going to do some very cool things.
instead, we have updating

# Statistics is Observation {#statistics-is-observation}

Updating is the foundation of our statistics: We believed something, we saw something, and we now believe something slightliy or significantly different from what we believed before.

What does that mean?

It's why it's okay that most published research is false.

Observation is messy. We love the mess. We live in the mess. Observation doesn't give us simple answers, but it continuously challenges and reshapes our assumptions.

Science is not the experiments we do. Rather, it's the debates we have about the experiments we do. Over time, we can become less, and less, and less, and less, and less, and less wrong.

# Demonstration: Will the mayor win? {#poll-demo}

- We're going to run the whole prior → likelihood → posterior loop on one concrete question: what share of voters will choose the current mayor?
- Be upfront that this model is too simple for a real poll. Real surveys aren't random samples: some groups answer more than others, and not everyone votes. Post-stratification and turnout models fix that, and we'll build them later. Today the point is the logic of updating.
- The formal model is two lines. The first line is the likelihood (how data are generated given θ), and the second is the prior (what we believe about θ before data).

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
