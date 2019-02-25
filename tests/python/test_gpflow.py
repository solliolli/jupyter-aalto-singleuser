# From gpflow example: https://gpflow.readthedocs.io/en/latest/notebooks/models.html

def test_gpflow():
    import gpflow
    import numpy as np
    with gpflow.defer_build():
        X = np.random.rand(20, 1)
        Y = np.sin(12 * X) + 0.66 * np.cos(25 * X) + np.random.randn(20,1) * 0.01
        m = gpflow.models.GPR(X, Y, kern=gpflow.kernels.Matern32(1) + gpflow.kernels.Linear(1))
    print(m)
