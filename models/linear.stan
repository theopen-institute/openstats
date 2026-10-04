// Linear regression on standardized variables, with any number of predictors
data {
  int<lower=1> n;
  int<lower=1> k;
  matrix[n, k] X;
  vector[n] y;
}
parameters {
  real alpha;
  vector[k] beta;
  real<lower=0> sigma;
}
model {
  // priors
  alpha ~ normal(0, 0.5);
  beta ~ normal(0, 1);
  sigma ~ exponential(1);

  // likelihood function
  y ~ normal(alpha + X * beta, sigma);
}
