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

  // optional prior overrides: set override_priors = 0 to use the defaults below,
  // or 1 and supply all three scales as (alpha, beta, gamma)
  int<lower=0, upper=1> override_priors;
  vector<lower=0>[override_priors ? 3 : 0] prior_sd;
}
transformed data {
  // default prior scales
  real alpha_sd = 1.5;
  real beta_sd = 1;
  real gamma_sd = 1;

  if (override_priors) {
    alpha_sd = prior_sd[1];
    beta_sd = prior_sd[2];
    gamma_sd = prior_sd[3];
  }
}
parameters {
  real alpha;
  sum_to_zero_vector[n_sex] beta;
  sum_to_zero_vector[n_dept] gamma;
}
model {
  alpha ~ normal(0, alpha_sd);
  // the sum-to-zero constraints shrink each effect's spread; widening the scales
  // undoes that, so each effect's prior SD matches the formal model
  beta ~ normal(0, beta_sd * inv_sqrt(1 - inv(n_sex)));
  gamma ~ normal(0, gamma_sd * inv_sqrt(1 - inv(n_dept)));

  if (!prior_only) {
    vector[n] eta;
    for (i in 1 : n)
      eta[i] = alpha + beta[sex[i]] + gamma[dept[i]];
    admitted ~ bernoulli_logit(eta);
  }
}
generated quantities {
  // admission probability for every sex x department cell
  matrix[n_sex, n_dept] p;
  for (s in 1 : n_sex)
    for (d in 1 : n_dept)
      p[s, d] = inv_logit(alpha + beta[s] + gamma[d]);
}
