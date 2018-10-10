
def test_bayes():
    import numpy as np
    import pystan
    fit = pystan.stan(model_code="parameters {real theta;} model {theta ~ normal(0,1);}")
    samples = fit.extract(permuted=True)
    assert np.mean(samples['theta']) < 1

