data {
  int<lower=1> n;
  vector[n] weight;
  vector[n] height_std;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  // linear predictor
  vector[n] mu = alpha + beta * height_std;
  
  // priors
  alpha ~ normal(50, 10);
  beta ~ normal(0, 2);
  sigma ~ normal(0, 10);
  
  // likelihood function
  weight ~ normal(mu, sigma);
}
