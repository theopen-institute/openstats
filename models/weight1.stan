data {
  int<lower=1> n;
  vector[n] weight;
}
parameters {
  real mu;
  real<lower=0> sigma;
}
model {
  // priors
  mu ~ normal(50, 10);
  sigma ~ normal(0, 10);
  
  // likelihood
  weight ~ normal(mu, sigma);
}
