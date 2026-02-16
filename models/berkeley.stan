data {
  // dimensions
  int<lower=1> n;
  int<lower=1> n_sex;
  int<lower=1> n_dept;
  
  // observed outcomes
  array[n] int<lower=0, upper=1> admitted;
  
  // group indices
  array[n] int<lower=1, upper=n_sex> sex;
  array[n] int<lower=1, upper=n_dept> dept;
  
  // prior predictive toggle (skips likelihood calculations)
  int<lower=0, upper=1> prior_only;
}
parameters {
  real alpha;
  sum_to_zero_vector[n_sex] beta;
  sum_to_zero_vector[n_dept] gamma;
  sum_to_zero_matrix[n_sex, n_dept] delta;
}
model {
  alpha ~ normal(0, 1.5);
  beta ~ normal(0, 1);
  gamma ~ normal(0, 1);
  to_vector(delta) ~ normal(0, 0.5);
  
  if (!prior_only) {
    vector[n] eta;
    for (i in 1 : n) 
      eta[i] = alpha + beta[sex[i]] + gamma[dept[i]] + delta[sex[i], dept[i]];
    admitted ~ bernoulli_logit(eta);
  }
}
generated quantities {
  // prior/posterior predictive draws
  array[n] int admitted_sim;
  for (i in 1 : n) {
    real eta = alpha + beta[sex[i]] + gamma[dept[i]] + delta[sex[i], dept[i]];
    admitted_sim[i] = bernoulli_logit_rng(eta);
  }
}
