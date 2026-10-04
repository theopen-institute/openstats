functions {
  // adjustment for sum_to_zero_vector[K] SDs
  real stz_correction(int K) {
    return inv_sqrt(1 - inv(K));
  }
}
data {
  // prior predictive toggle (skips likelihood calculations)
  int<lower=0, upper=1> prior_only;
  
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
parameters {
  real alpha;
  sum_to_zero_vector[n_sex] beta;
  sum_to_zero_vector[n_dept] gamma;
}
model {
  alpha ~ normal(0, 1.5);
  beta ~ normal(0, 1 * stz_correction(n_sex));
  gamma ~ normal(0, 1 * stz_correction(n_dept));
  
  vector[n] eta = alpha + beta[sex] + gamma[dept];
  if (!prior_only) 
    admitted ~ bernoulli_logit(eta);
}
generated quantities {
  // admission probability for every sex x department cell
  matrix[n_sex, n_dept] p;
  for (s in 1 : n_sex) 
    for (d in 1 : n_dept) 
      p[s, d] = inv_logit(alpha + beta[s] + gamma[d]);
}
