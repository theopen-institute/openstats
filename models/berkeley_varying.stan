// berkeley.stan, with a sex effect that varies by department
functions {
  // adjustment for sum_to_zero_vector[K] SDs
  real stz_correction(int K) {
    return inv_sqrt(1 - inv(K));
  }
}
data {
  // prior predictive toggle (skips likelihood calculations)
  int<lower=0, upper=1> prior_only;

  // prior scales
  real<lower=0> alpha_sd;
  real<lower=0> beta_sd;
  real<lower=0> tau_sd;
  real<lower=0> gamma_sd;

  // dimensions
  int<lower=1> n;
  int<lower=1> n_sex;
  int<lower=1> n_dept;

  // group indices
  array[n] int<lower=1, upper=n_sex> sex;
  array[n] int<lower=1, upper=n_dept> dept;

  // observed outcomes
  array[n] int<lower=0, upper=1> admitted;
}
transformed data {
  // each applicant's sex x department cell, as a position in to_vector(beta)
  array[n] int cell;
  for (i in 1 : n)
    cell[i] = sex[i] + n_sex * (dept[i] - 1);
}
parameters {
  real alpha;
  sum_to_zero_vector[n_sex] beta_bar; // average sex effect
  real<lower=0> tau; // how much the sex effect varies between departments
  array[n_dept] sum_to_zero_vector[n_sex] z; // each department's deviation, in units of tau
  sum_to_zero_vector[n_dept] gamma;
}
transformed parameters {
  // sex effect in each department: beta[s, d]
  matrix[n_sex, n_dept] beta;
  for (d in 1 : n_dept)
    beta[ : , d] = beta_bar + tau * z[d];
}
model {
  alpha ~ normal(0, alpha_sd);
  beta_bar ~ normal(0, beta_sd * stz_correction(n_sex));
  tau ~ normal(0, tau_sd);
  for (d in 1 : n_dept)
    z[d] ~ normal(0, stz_correction(n_sex));
  gamma ~ normal(0, gamma_sd * stz_correction(n_dept));

  vector[n] eta = alpha + to_vector(beta)[cell] + gamma[dept];
  if (!prior_only)
    admitted ~ bernoulli_logit(eta);
}
generated quantities {
  // admission probability for every sex x department cell
  matrix[n_sex, n_dept] p;
  for (s in 1 : n_sex)
    for (d in 1 : n_dept)
      p[s, d] = inv_logit(alpha + beta[s, d] + gamma[d]);
}
