library(rstan)
fit <- stan(model_code="parameters {real theta;} model {theta ~ normal(0,1);}")
print(mean(as.matrix(fit)))
stopifnot(abs(mean(as.matrix(fit))) < 1)
