ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

USER root

ADD pinned.standard  /opt/conda/conda-meta/pinned.standard
RUN cd /opt/conda/conda-meta/ && \
    cat pinned.standard >> pinned

# Custom installations
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    clean-layer.sh


# Custom installations
# arviz: bayesian data analysis
# cma: ??
# folium: BE remote sensing course
# geopandas: BE remote sensing course
# igraph: complex networks (general)
# keras: general use (for gpu, keras-gpu)
# librarosa: datasci2018
# networkx: complex networks (general)
# nose: mlbp2018
# plotchecker: for nbgrader, mlbp2018
# plotly: student request
# pydotplus - dsfb2018 instructor request
# pydub: ???
# pytorch: general use
# pystan: general use, bayes course (updated prompt_toolkit needed as dependency)
# rasterio: BE remote sensing course
# scikit-learn: mlbp2018
# tensorflow, tensorflow-tensorboard (general use)
# cvxopt       - mlkern2019
# nbstripout   - generic package
# nltk         -  datasci2019  (use conda  when upgrading)
# lapack       - dependency for cvxpy
# cvxpy        - mlkern2019
# gpflow       - special course Gaussian Processes, 2019
# bcolz        - introai2019
# tqdm         - introai2019
# qiskit       - Introduction to Quantum Technologies, Matti Raasakka, RT#14866
# wordcloud - datasci2019
# geopy - datasci2019
# imbalanced-learn (student request)
RUN \
    conda install \
        networkx \
        nose \
        pandas-datareader \
        plotly \
        pydotplus \
        scikit-learn \
        && \
    conda install -c conda-forge \
        arviz \
        folium \
        python-igraph \
        feather-format \
        librosa \
        bcolz \
        tqdm \
        wordcloud \
        geopy \
	rasterio \
	geopandas \
        lapack \
        mlxtend \
        scikit-plot \
        imbalanced-learn \
        nltk \
        && \
    pip install --no-cache-dir \
        plotchecker \
        gpflow \
        calysto \
        cma \
        cvxopt \
        cvxpy \
        metakernel \
        pydub \
        qiskit \
        && \
    clean-layer.sh
# Currently non-functional packages:
#   geopandas (conda-forge)
#   rasterio (conda-forge)

## TODO: Combine layers
    # Installing from pip because the tensorflow and tensorboard versions found
    # from the anaconda repos don't support python 3.7 yet
RUN \
    conda install \
        keras \
        pystan prompt_toolkit \
        && \
    pip install --no-cache-dir \
        tensorflow==2.0.0 \
        tensorboard \
        tensorflow-hub \
        && \
    clean-layer.sh
RUN conda install -c pytorch \
        pytorch \
        torchvision \
        && \
    clean-layer.sh

#RUN pip install --no-cache-dir \
#    && \
#    clean-layer.sh



#RUN \
#    conda install -c anaconda \
#    conda install \
#    clean-layer.sh

#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    clean-layer.sh

ENV CC=clang CXX=clang++


# Duplicate of base, but hooks can update frequently and are small so
# put them last.
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

USER $NB_UID
