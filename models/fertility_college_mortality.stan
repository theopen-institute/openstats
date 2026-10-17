data {
  int<lower=0> n;
  vector[n] women_in_college;
  vector[n] infant_mortality;
  vector[n] fertility_rate;
}
parameters {
  real alpha;
  real beta_college;
  real beta_mortality;
  real<lower=0> sigma;
}
model {
  vector[n] mu = alpha + beta_college * women_in_college
                 + beta_mortality * infant_mortality;
  
  alpha ~ normal(0, 5);
  beta_college ~ normal(0, 2);
  beta_mortality ~ normal(0, 2);
  sigma ~ exponential(1);
  
  fertility_rate ~ normal(mu, sigma);
}
