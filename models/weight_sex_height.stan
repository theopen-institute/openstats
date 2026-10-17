data {
  int<lower=1> n;
  int<lower=1> n_sex;
  
  vector[n] weight;
  vector[n] height_std;
  array[n] int<lower=1, upper=n_sex> sex;
}
parameters {
  vector[n_sex] alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  // linear predictor
  vector[n] mu = alpha[sex] + beta * height_std;
  
  // priors
  alpha ~ normal(50, 10);
  beta ~ normal(0, 2);
  sigma ~ normal(0, 10);
  
  // likelihood function
  weight ~ normal(mu, sigma);
}
