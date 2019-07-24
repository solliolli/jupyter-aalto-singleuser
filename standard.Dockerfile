ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

USER root

# Custom installations
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*


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
    conda clean --all --yes && \
    rm -rf /opt/conda/pkgs/cache/ && \
    fix-permissions $CONDA_DIR /home/$NB_USER

## TODO: Combine layers
# imbalanced-learn (student request)
RUN \
    conda install \
        keras \
        pystan prompt_toolkit
RUN \
    conda install -c pytorch \
        pytorch=1.1.0 \
        torchvision=0.3.0
RUN \
    # Installing from pip because the tensorflow and tensorboard versions found
    # from the anaconda repos don't support python 3.7 yet
    pip install \
        tensorflow==1.13.1 \
        tensorflow-tensorboard==1.5.1 \
        && \
    conda install -c conda-forge \
        imbalanced-learn=0.4.3 \
        && \
    conda clean --all --yes && \
    rm -rf /opt/conda/pkgs/cache/ && \
    fix-permissions $CONDA_DIR /home/$NB_USER



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
    # TODO: remove when updating base image
    pip install --upgrade --no-deps https://github.com/rkdarst/nbgrader/archive/a16f915.zip && \
    conda clean --all --yes && \
    rm -rf /opt/conda/pkgs/cache/ && \
    fix-permissions $CONDA_DIR /home/$NB_USER
RUN \
    conda install -c conda-forge \
        bcolz \
        tqdm
RUN pip install gpflow
RUN \
    pip install \
        calysto \
        cvxopt \
        cvxpy==1.0.4 \
        metakernel \
        && \
    conda clean --all --yes && \
    rm -rf /opt/conda/pkgs/cache/ && \
    fix-permissions $CONDA_DIR /home/$NB_USER
RUN \
    conda install -c anaconda \
           tensorflow && \
    conda install \
           tensorflow-hub
RUN \
    pip install qiskit==0.10.3

#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

# Duplicate of base, but hooks can update frequently and are small so
# put them last.
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

USER $NB_UID
