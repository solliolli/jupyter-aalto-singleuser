ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

USER root

ADD clean-layer.sh  /tmp/clean-layer.sh

# Custom installations
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    /tmp/clean-layer.sh


# Custom installations
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
# pytorch: general use
# pystan: general use, bayes course (updated prompt_toolkit needed as dependency)
# rasterio: BE remote sensing course
# scikit-learn: mlbp2018
# tensorflow, tensorflow-tensorboard (general use)
#           geopandas      # does not currently work
#          rasterio
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
        folium \
        python-igraph \
        feather-format \
        librosa \
        && \
    pip install --no-cache-dir \
        plotchecker \
        && \
    /tmp/clean-layer.sh

## TODO: Combine layers
# imbalanced-learn (student request)
RUN \
    conda install \
        keras \
        pystan prompt_toolkit \
        && \
    /tmp/clean-layer.sh
RUN conda install -c pytorch \
        pytorch=1.1.0 \
        torchvision=0.3.0 \
        && \
    conda install -c conda-forge \
        imbalanced-learn=0.4.3 \
        && \
    /tmp/clean-layer.sh
RUN \
    # Installing from pip because the tensorflow and tensorboard versions found
    # from the anaconda repos don't support python 3.7 yet
    pip install --no-cache-dir \
        tensorflow==1.13.1 \
        tensorflow-tensorboard==1.5.1 \
        && \
    /tmp/clean-layer.sh


# Last added packages - move to somewhere above when it makes sense
#  cvxopt       - mlkern2019
#  nbstripout   - generic package
#  lapack       - dependency for cvxpy
#  cvxpy        - mlkern2019
#  gpflow       - special course Gaussian Processes, 2019
#  bcolz        - introai2019
#  tqdm         - introai2019
#  qiskit       - Introduction to Quantum Technologies, Matti Raasakka, RT#14866
RUN \
    conda install -c conda-forge --only-deps --no-update-deps  \
        lapack \
        nbstripout \
        mlxtend \
        scikit-plot \
        lapack \
        python \
        && \
    conda upgrade -c pytorch pytorch && \
    /tmp/clean-layer.sh

# wordcloud - datasci2019
# geopy - datasci2019
RUN \
    conda install -c conda-forge \
        bcolz \
        tqdm \
        wordcloud \
        geopy \
        && \
    pip install --no-cache-dir \
        gpflow \
        calysto \
        cvxopt \
        cvxpy==1.0.4 \
        metakernel \
        qiskit==0.12.0 \
        && \
    /tmp/clean-layer.sh

RUN \
    conda install -c anaconda \
           tensorflow && \
    conda install \
           tensorflow-hub && \
    /tmp/clean-layer.sh

#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    /tmp/clean-layer.sh

# Duplicate of base, but hooks can update frequently and are small so
# put them last.
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

USER $NB_UID
