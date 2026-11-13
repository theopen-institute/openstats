// Reported violence (yes/no) by group, with any set of other predictors and with
// villages, interviewers and districts each switched on or off. One model for every
// DAG in the violence example (violence.Rmd): the data say which parts are in.
// "Group" is whatever categorical exposure the estimand is about: caste/ethnicity for
// the disparities, the husband's drinking for the effect of drunkenness.
functions {
  // adjustment for sum_to_zero_vector[K] SDs
  real stz_correction(int K) {
    return inv_sqrt(1 - inv(K));
  }
}
data {
  // prior predictive toggle (skips likelihood calculations)
  int<lower=0, upper=1> prior_only;

  int<lower=1> n;
  array[n] int<lower=0, upper=1> y;

  // group (caste/ethnicity)
  int<lower=2> n_group;
  array[n] int<lower=1, upper=n_group> group;

  // other predictors, standardized or 0/1 (k = 0 for none)
  int<lower=0> k;
  matrix[n, k] X;

  // villages: 0 = left out, 1 = partial pooling, 2 = no pooling
  int<lower=0, upper=2> village_model;
  int<lower=1> n_village;
  array[n] int<lower=1, upper=n_village> village;

  // interviewers and districts: 0 = left out, 1 = partial pooling
  int<lower=0, upper=1> interviewer_model;
  int<lower=1> n_interviewer;
  array[n] int<lower=1, upper=n_interviewer> interviewer;
  int<lower=0, upper=1> district_model;
  int<lower=1> n_district;
  array[n] int<lower=1, upper=n_district> district;

  // how much each woman counts in the estimand (survey weights, or all 1)
  vector<lower=0>[n] w;
}
transformed data {
  // a part that is switched off gets a vector of length 1, which sums to zero: no
  // parameters
  int n_v = village_model > 0 ? n_village : 1;
  int n_i = interviewer_model > 0 ? n_interviewer : 1;
  int n_d = district_model > 0 ? n_district : 1;
  real no_pooling_sd = 5; // wide enough that villages learn nothing from each other
}
parameters {
  real alpha;
  sum_to_zero_vector[n_group] beta;
  vector[k] gamma;

  sum_to_zero_vector[n_v] z_village;
  array[village_model == 1] real<lower=0> sigma_village;
  sum_to_zero_vector[n_i] z_interviewer;
  array[interviewer_model] real<lower=0> sigma_interviewer;
  sum_to_zero_vector[n_d] z_district;
  array[district_model] real<lower=0> sigma_district;
}
transformed parameters {
  // partial pooling: z is in standard deviations of the spread between villages,
  // which is estimated. No pooling: z is the village's own effect.
  vector[n_v] a_village = village_model == 1 ? sigma_village[1] * z_village : z_village;
  vector[n_i] a_interviewer = interviewer_model ? sigma_interviewer[1] * z_interviewer
                                                : z_interviewer;
  vector[n_d] a_district = district_model ? sigma_district[1] * z_district : z_district;
}
model {
  alpha ~ normal(-1.5, 1);
  beta ~ normal(0, 1 * stz_correction(n_group));
  gamma ~ normal(0, 1);

  if (village_model == 1) {
    z_village ~ normal(0, stz_correction(n_v));
    sigma_village ~ exponential(2);
  } else if (village_model == 2) {
    z_village ~ normal(0, no_pooling_sd * stz_correction(n_v));
  }
  if (interviewer_model) {
    z_interviewer ~ normal(0, stz_correction(n_i));
    sigma_interviewer ~ exponential(2);
  }
  if (district_model) {
    z_district ~ normal(0, stz_correction(n_d));
    sigma_district ~ exponential(2);
  }

  if (!prior_only) {
    vector[n] eta = alpha + beta[group] + X * gamma;
    if (village_model) eta += a_village[village];
    if (interviewer_model) eta += a_interviewer[interviewer];
    if (district_model) eta += a_district[district];
    y ~ bernoulli_logit(eta);
  }
}
generated quantities {
  // The average probability of violence if every woman in the sample belonged to
  // group g, everything else about her unchanged, weighted by w. Group gaps are
  // differences between these.
  vector[n_group] p_group;
  // Replicated data for posterior predictive checks: how many women the model says
  // would report violence, counted by group and by interviewer
  array[n_group] int rep_group = rep_array(0, n_group);
  array[n_interviewer] int rep_interviewer = rep_array(0, n_interviewer);
  {
    vector[n] eta = alpha + X * gamma;
    if (village_model) eta += a_village[village];
    if (interviewer_model) eta += a_interviewer[interviewer];
    if (district_model) eta += a_district[district];
    for (g in 1 : n_group)
      p_group[g] = dot_product(w, inv_logit(eta + beta[g])) / sum(w);
    for (i in 1 : n) {
      int y_rep = bernoulli_logit_rng(eta[i] + beta[group[i]]);
      rep_group[group[i]] += y_rep;
      rep_interviewer[interviewer[i]] += y_rep;
    }
  }
}
