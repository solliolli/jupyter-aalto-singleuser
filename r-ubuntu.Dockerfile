ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

## R support

USER root

# libxml2-dev: for R package xml2, indirect dependency of devtools
# libnode-dev: for rstan

RUN wget -q https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
         -O /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    echo "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
        > /etc/apt/sources.list.d/cran.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        clang \
        ed \
        file \
        fonts-dejavu \
        tzdata \
        gfortran \
        gzip \
        libavfilter-dev \
        libblas-dev \
        libcurl4-openssl-dev \
        libgit2-dev \
        libmagick++-dev \
        libnode-dev \
        libssl-dev \
        libopenblas-dev \
        liblapack-dev \
        libxml2-dev \
        r-base \
        # TODO: remove when base image is updated
        build-essential \
          && \
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
    echo "install.packages(c(" \
            "'IRkernel'," \
            "'repr'," \
            "'IRdisplay'," \
            "'evaluate'," \
            "'crayon'," \
            "'pbdZMQ'," \
            "'uuid'," \
            "'digest'" \
        "), repos='${CRAN_URL}', clean=TRUE)" | Rscript - && \
    Rscript -e 'IRkernel::installspec(user = FALSE)'
RUN jupyter kernelspec remove -f python3

# Packages from jupyter r-notebook
RUN \
    echo "install.packages(c(" \
            "'plyr'," \
            "'devtools'," \
            "'tidyverse'," \
            "'shiny'," \
            "'markdown'," \
            "'forecast'," \
            "'RSQLite'," \
            "'reshape2'," \
            "'nycflights13'," \
            "'caret'," \
            "'RCurl'," \
            "'crayon'," \
            "'randomForest'," \
            "'htmltools'," \
            "'sparklyr'," \
            "'htmlwidgets'," \
            "'hexbin'," \
            "'caTools'" \
        "), repos='${CRAN_URL}', clean=TRUE)" | Rscript - && \
    fix-permissions /usr/local/lib/R/site-library

#
# Course setup
#

RUN \
    echo "install.packages(c(" \
            # Packages needed for bayesian macheine learning course, RT#13568
            "'bayesplot'," \
            "'rstan'," \
            "'rstanarm'," \
            "'shinystan'," \
            "'loo'," \
            "'brms'," \
            "'GGally'," \
            "'MASS'," \
            "'coda'," \
            "'gridBase'," \
            "'gridExtra'," \
            "'here'," \
            "'projpred'," \
            # " RT#17144
            "'StanHeaders'," \
            "'tweenr'," \
            "'gganimate'," \
            "'ggforce'," \
            "'ggrepel'," \
            "'av'," \
            "'magick'," \
            # " RT#15341
            "'markmyassignment'," \
            "'RUnit'," \
            # htbioinformatics RT#17450
            "'aods3'," \
            # unknown purpose, included in the original Dockerfile
            "'nloptr'" \
        "), repos='${CRAN_URL}', clean=TRUE)" | Rscript - && \
    fix-permissions /usr/local/lib/R/site-library

# Try to disable Python kernel
# https://github.com/jupyter/jupyter_client/issues/144
RUN rm -r /home/$NB_USER/.local/ && \
    echo >> /etc/jupyter/jupyter_notebook_config.py && \
    echo 'c.NotebookApp.iopub_data_rate_limit = .8*2**20' >> /etc/jupyter/jupyter_notebook_config.py && \
    echo 'c.LabApp.iopub_data_rate_limit = .8*2**20' >> /etc/jupyter/jupyter_notebook_config.py && \
    echo "c.KernelSpecManager.whitelist={'ir', 'bash'}" >> /etc/jupyter/jupyter_notebook_config.py

ENV R_MAKEVARS_SITE /usr/lib/R/etc/Makevars

#
# Rstudio
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libclang-dev \
        libapparmor1 \
        libedit2 \
        libssl1.1 \
        lsb-release \
        psmisc \
        && \
        clean-layer.sh


ENV RSTUDIO_PKG=rstudio-server-1.3.959-amd64.deb
# https://github.com/jupyterhub/nbrsessionproxy
# Download url: https://www.rstudio.com/products/rstudio/download-server/
RUN wget -q https://download2.rstudio.org/server/bionic/amd64/${RSTUDIO_PKG} && \
    test "$(md5sum < ${RSTUDIO_PKG})" = "24c0dd4a9622aa3229ea5006fc83e7bd  -" && \
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
    git checkout e8c45f9565844df9497360b767f07fe1b84e19cc && \
    npm install && npm run build && jupyter labextension link . && \
    npm run build && jupyter lab build && \
    jupyter labextension install @techrah/text-shortcuts && \
    cd /usr/local/src && rm -r /usr/local/src/* && \
    ln -s /usr/lib/rstudio-server/bin/rserver /usr/local/bin/ && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# openjdk-11-jre-headless: htbioinformatics2019, for fastcq
# python-htseq:            htbioinformatics2019, https://htseq.readthedocs.io/en/release_0.11.1/install.html
# libbz2-dev:              dependency for samtools
# libncurses5-dev:         dependency for samtools
# liblzma-dev:             dependency for samtools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libncurses5-dev \
        liblzma-dev \
        openjdk-11-jre-headless \
        python-htseq \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir \
        htseq==0.11.1 \
        && \
    clean-layer.sh

RUN cd /opt && \
    mkdir fastcq && \
    wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip && \
    rm fastqc_v0.11.8.zip && \
    chmod a+x ./FastQC/fastqc && \
    ln -s $PWD/FastQC/fastqc /usr/local/bin/ && \
    fix-permissions /opt/fastcq /usr/local/bin


# htbioinformatics2019, RT#15527
# http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#obtaining-bowtie-2
RUN conda config --append channels bioconda && \
    conda config --system --set channel_priority flexible && \
    conda install \
        bowtie2 \
        && \
    clean-layer.sh

# htbioinformatics2019
# https://ccb.jhu.edu/software/tophat/tutorial.shtml
# TODO: changed https->http because of a SSL error in ubuntu as of
# 2020-07-10, convert http->https later and see if it works
RUN cd /opt && \
    wget http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.1.Linux_x86_64.tar.gz && \
    tar xf tophat-2.1.1.Linux_x86_64.tar.gz && \
    sed -i 's@/usr/bin/env python@/usr/bin/python2@' tophat-2.1.1.Linux_x86_64/tophat && \
    ln -s $PWD/tophat-2.1.1.Linux_x86_64/tophat2 /usr/local/bin/ && \
    rm tophat-2.1.1.Linux_x86_64.tar.gz && \
    fix-permissions /opt/fastcq /usr/local/bin


# Bioconductor
# edgeR, GenomicRanges, rtracklayer: htbioinformatics
# BiSeq, limma: htbioinformatics


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libomp-dev r-cran-xml llvm-10-dev \
        && \
    echo 'if (!requireNamespace("BiocManager", quietly = TRUE)) '\
            'install.packages("BiocManager") ; ' \
            'BiocManager::install()' \
        | Rscript - && \
    echo 'BiocManager::install(c('\
            '"edgeR", ' \
            '"GenomicRanges", ' \
            '"rtracklayer", ' \
            '"BSgenome.Hsapiens.NCBI.GRCh38", ' \
            '"BiSeq", ' \
            '"limma" ' \
        '))' | Rscript - && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# samtools: htbioinformatics, http://www.htslib.org/download/
# pysam:    same --^
# macs2:    "
RUN \
    mkdir /opt/samtools && \
    cd /opt/samtools && \
    wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar xf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure --prefix=/opt/samtools/install/ --bindir=/usr/local/bin/ && \
    make && \
    make install && \
    pip install --no-cache-dir \
        pysam \
        macs2 \
        && \
    clean-layer.sh

# ELEC-A8720 - Biologisten ilmiöiden mittaaminen (Quantifying/measuring biological phenomena).
RUN \
    echo 'BiocManager::install(c('\
            '"biomaRt", ' \
            '"snpStats" ' \
        '))' | CC=gcc CXX=g++ Rscript - && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# plink: ELEC-A8720 - Biologisten ilmiöiden mittaaminen (Quantifying/measuring biological phenomena).
RUN \
    mkdir /opt/plink && \
    cd /opt/plink && \
    wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20190304.zip && \
    unzip plink_linux_x86_64_20190304.zip && \
    ln -s $PWD/plink /usr/local/bin/ && \
    fix-permissions /opt/plink /usr/local/bin

#
# Last-added packages, move to above
#

# RUN \
#     echo "install.packages(c(" \
#             "'packagename'," \
#         "), repos='${CRAN_URL}', clean=TRUE)" | Rscript - && \
#     fix-permissions /usr/local/lib/R/site-library

# ====================================


# Set default R compiler to clang to save memory.
RUN echo "CC=clang"     >> /usr/lib/R/etc/Makevars && \
    echo "CXX=clang++"  >> /usr/lib/R/etc/Makevars && \
    sed -i  -e "s/= gcc/= clang -flto=thin/g"  -e "s/= g++/= clang++/g"  /usr/lib/R/etc/Makeconf

ENV CC=clang CXX=clang++
ENV BINPREF=PATH
# Duplicate of base, but hooks can update frequently and are small so
# put them last.
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+rx /usr/local/bin/*.sh

USER $NB_UID
