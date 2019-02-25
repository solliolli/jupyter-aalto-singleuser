
def test_modules():
    # Generic
    import igraph
    import imblearn
    import keras
    #import nbstripout        # not importable in tests/notebooks
    import networkx
    import nose
    #import pandas_datareader # currently broken
    import plotly
    import pystan
    import sklearn
    import tensorflow
    import torch ; assert torch.__version__ >= '1.0.0'
    import torchvision ; assert torchvision.__version__ >= '0.2.1'

    # Misc requested courses
    import gpflow

    # BuiltEnv remote sensing course
    #import geopandas   # does not work at start of 2019.
    #import rasterio
    import folium

    # Bayes course
    import pystan

    # DSFB
    import pydotplus

    # DataSci
    import librosa

    # mlkern2019
    import cvxopt
    import cvxpy
