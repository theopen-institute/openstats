<!-- The ten-step workflow, shared by workflow.qmd and the week 1 deck. -->

- **Scientific model:** what we believe about the world, before any statistics.
  1. **Ask the question.** Say in plain words what you want to know, and picture what the answer would look like.
  2. **Draw the causal model (DAG).** Write down what you assume causes what, based on what you know about the domain.
  3. **Define the estimand.** Use the DAG to turn your question into one exact number, before you touch the data.
  4. **Simulate the population.** Write a simulation that could produce data like yours.
- **Statistical model:** the machinery that turns data into an estimate, tested where we already know the truth.
  5. **Write the formal model.** Derive the statistical model from the DAG, in math notation.
  6. **Write the Stan code.** Translate the formal model into a program.
  7. **Test on simulated data.** Check that the priors imply plausible data and that the model recovers parameters we already know.
- **Analysis:** the real data, the estimate, and how far to trust it.
  8. **Fit and validate the model.** Run the sampler, check its diagnostics, and run posterior predictive checks. Can we trust the model?
  9. **Compute the estimate.** Use the fitted model to estimate the estimand from step 3.
  10. **Test its robustness.** How much does the estimate depend on our assumptions?
