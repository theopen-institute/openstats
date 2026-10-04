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
}
model {
  alpha ~ normal(0, 1.5);
  // the sum-to-zero constraints shrink each effect's spread; widening the scales
  // undoes that, so each effect's prior SD matches the formal model (1)
  beta ~ normal(0, 1 * inv_sqrt(1 - inv(n_sex)));
  gamma ~ normal(0, 1 * inv_sqrt(1 - inv(n_dept)));

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
