data {
  int<lower=1> n;
  vector[n] weight;
  int<lower=1> n_sex;
  array[n] int<lower=1, upper=n_sex> sex;
}
parameters {
  vector[n_sex] alpha;
  real<lower=0> sigma;
}
model {
  // linear predictor
  vector[n] mu = alpha[sex];
  
  // priors
  alpha ~ normal(50, 10);
  sigma ~ normal(0, 10);
  
  // likelihood function
  weight ~ normal(mu, sigma);
}
