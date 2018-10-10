
## Stops working in stan 3.0
#def test_bayes_old():
#    import numpy as np
#    import pystan
#    fit = pystan.stan(model_code="parameters {real theta;} model {theta ~ normal(0,1);}")
#    samples = fit.extract(permuted=True)
#    assert np.mean(samples['theta']) < 1

def test_bayes_new():
    import numpy as np
    import pystan
    sm = pystan.StanModel(model_code="parameters {real theta;} model {theta ~ normal(0,1);}")
    #fit = pystan.stan(model_code="parameters {real theta;} model {theta ~ normal(0,1);}")
    fit = sm.sampling()
    samples = fit.extract(permuted=True)
    assert np.mean(samples['theta']) < 1

