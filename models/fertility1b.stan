data {
  int<lower=0> n;
  vector[n] infant_mortality;
  vector[n] fertility_rate;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  vector[n] mu = alpha + beta * infant_mortality;
  
  alpha ~ normal(0, 5);
  beta ~ normal(0, 2);
  sigma ~ exponential(1);
  
  fertility_rate ~ normal(mu, sigma);
}
