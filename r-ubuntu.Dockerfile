ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

## R support

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        clang \
        ed \
        fonts-dejavu \
        tzdata \
        gfortran \
        gzip \
        libblas-dev \
        libgit2-dev \
        libssl-dev \
        libopenblas-dev \
        liblapack-dev \
        r-base && \
    update-alternatives --set cc  /usr/bin/clang && \
    update-alternatives --set c++ /usr/bin/clang++ && \
    update-alternatives --set c89 /usr/bin/clang && \
    update-alternatives --set c99 /usr/bin/clang && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#libnlopt-dev --> NO, not compatible

#libprce2-dev
#libbz2-dev
#liblzma-dev

ARG CRAN_URL

RUN \
    Rscript -e "install.packages(c('repr','IRdisplay','evaluate','crayon','pbdZMQ','devtools','uuid','digest'), repos='${CRAN_URL}', clean=TRUE)" && \
    Rscript -e "devtools::install_github('IRkernel/IRkernel')" && \
    Rscript -e 'IRkernel::installspec(user = FALSE)'
RUN jupyter kernelspec remove -f python3

# Packages from jupyter r-notebook
RUN \
    Rscript -e "install.packages(c('plyr', 'devtools', 'tidyverse', 'shiny', 'markdown', 'forecast', 'RSQLite', 'reshape2', 'nycflights13', 'caret', 'RCurl', 'crayon', 'randomForest', 'htmltools', 'sparklyr', 'htmlwidgets', 'hexbin', 'caTools'), repos='${CRAN_URL}', clean=TRUE)" && \
    fix-permissions /usr/local/lib/R/site-library

#
# Course setup
#

# Packages needed for bayesian macheine learning course
RUN \
    Rscript -e "install.packages(c('nloptr', 'bayesplot', 'rstan', 'rstanarm', 'shinystan', 'loo', 'brms', 'GGally', 'MASS', 'coda', 'gridBase', 'gridExtra', 'here', 'projpred'), repos='${CRAN_URL}', clean=TRUE)" && \
    fix-permissions /usr/local/lib/R/site-library

# Try to disable Python kernel
# https://github.com/jupyter/jupyter_client/issues/144
RUN rm -r /home/$NB_USER/.local/ && \
    echo >> /etc/jupyter/jupyter_notebook_config.py && \
    echo 'c.NotebookApp.iopub_data_rate_limit = .8*2**20' >> /etc/jupyter/jupyter_notebook_config.py && \
    echo 'c.LabApp.iopub_data_rate_limit = .8*2**20' >> /etc/jupyter/jupyter_notebook_config.py && \
    echo "c.KernelSpecManager.whitelist={'ir'}" >> /etc/jupyter/jupyter_notebook_config.py

# Set default R compiler to clang to save memory.
RUN echo "CC=clang"     >> /usr/lib/R/etc/Makevars && \
    echo "CXX=clang++"  >> /usr/lib/R/etc/Makevars && \
    sed -i  -e "s/= gcc/= clang -flto=thin/g"  -e "s/= g++/= clang++/g"  /usr/lib/R/etc/Makeconf

ENV R_MAKEVARS_SITE /usr/lib/R/etc/Makevars

#
# Rstudio
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libapparmor1 \
        libedit2 \
        lsb-release \
        psmisc \
        libssl1.0.0 \
        && \
        clean-layer.sh

ENV RSTUDIO_PKG=rstudio-server-1.1.456-amd64.deb
# https://github.com/jupyterhub/nbrsessionproxy
RUN wget -q http://download2.rstudio.org/${RSTUDIO_PKG} && \
    dpkg -i ${RSTUDIO_PKG} && \
    rm ${RSTUDIO_PKG}

# Rstudio for jupyterlab
#   Viasat/nbrsessionproxy is not compatible with JL 1.0
RUN set -x && pip install --no-cache-dir jupyter-rsession-proxy && \
    # The npm version of jupyterlab-server-proxy is not yet compatible
    # with JupyterLab 1.0 -> using git version.
    # See https://github.com/jupyterhub/jupyter-server-proxy/issues/139#issuecomment-516665020
    # jupyter labextension install jupyterlab-server-proxy && \
    cd /usr/local/src/ && \
    git clone https://github.com/jupyterhub/jupyter-server-proxy && \
    cd jupyter-server-proxy/jupyterlab-server-proxy && \
    git checkout daeb5aa08074758bf7922f6ca5b557f713feb4dd && \
    npm install && npm run build && jupyter labextension link . && \
    npm run build && jupyter lab build && \
    cd /usr/local/src && rm -r /usr/local/src/* && \
    ln -s /usr/lib/rstudio-server/bin/rserver /usr/local/bin/ && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# Duplicate of base, but hooks can update frequently and are small so
# put them last.
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

USER $NB_UID
