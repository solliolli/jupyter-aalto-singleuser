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
    # TODO: clean-layer.sh instead (rebuild)
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

# NOTE: building this takes ~40 minutes
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
            # compgeno2022 RT#21822
            "'ape'," \
            "'ggplot2'," \
            "'reshape2'," \
            "'HMM'," \
            "'phangorn'," \
            "'testit'", \
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
        # rstudio-server dependencies, parsed from the .deb file
        libclang-10-dev \
        libclang-dev \
        libpq5 \
        && \
    clean-layer.sh

ENV RSTUDIO_PKG=rstudio-server-2022.07.1-554-amd64.deb
ENV RSTUDIO_CHECKSUM=b6778c0a78d69d836d5c812342a3697a19b83c80c2d6eb7162b38dedc6ad6b56
# https://github.com/jupyterhub/nbrsessionproxy
# Download url: https://www.rstudio.com/products/rstudio/download-server/
RUN wget -q https://download2.rstudio.org/server/bionic/amd64/${RSTUDIO_PKG} && \
    test "$(sha256sum < ${RSTUDIO_PKG})" = "${RSTUDIO_CHECKSUM}  -" && \
    dpkg -i ${RSTUDIO_PKG} && \
    rm ${RSTUDIO_PKG}

# Rstudio for jupyterlab
RUN pip install --no-cache-dir jupyter-rsession-proxy && \
    pip install jupyter-server-proxy && \
    jupyter labextension install @jupyterlab/server-proxy && \
    jupyter labextension install @techrah/text-shortcuts && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# openjdk-11-jre-headless: htbioinformatics2019, for fastcq
# libbz2-dev:              dependency for samtools
# libncurses5-dev:         dependency for samtools
# liblzma-dev:             dependency for samtools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libncurses5-dev \
        liblzma-dev \
        openjdk-11-jre-headless \
        && \
    pip install --upgrade --no-cache-dir \
        # upgrading because htseq complains about invalid numpy version, and
        # current scipy version is incompatible with newer numpy
        numpy \
        scipy \
        && \
    pip install --no-cache-dir \
        # htbioinformatics, RT#15527
        htseq \
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
# 2022-08-22: the site still serves insecure signatures not accepted by cURL
RUN cd /opt && \
    wget http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.1.Linux_x86_64.tar.gz && \
    tar xf tophat-2.1.1.Linux_x86_64.tar.gz && \
    sed -i 's@/usr/bin/env python@/usr/bin/python2@' tophat-2.1.1.Linux_x86_64/tophat && \
    ln -s $PWD/tophat-2.1.1.Linux_x86_64/tophat2 /usr/local/bin/ && \
    rm tophat-2.1.1.Linux_x86_64.tar.gz && \
    fix-permissions /opt/fastcq /usr/local/bin


# Bioconductor

RUN Rscript -e 'install.packages("BiocManager")' && \
    echo 'BiocManager::install(c('\
            # RT#15527 htbioinformatics
            '"edgeR", ' \
            '"GenomicRanges", ' \
            '"rtracklayer", ' \
            '"BSgenome.Hsapiens.NCBI.GRCh38", ' \
            # RT#17450 htbioinformatics
            '"BiSeq", ' \
            '"limma", ' \
            # compgeno2022 RT#21822
            "'DECIPHER'," \
            "'ORFik'," \
            "'Biostrings'" \
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

# ELEC-A8720 - Biologisten ilmiöiden mittaaminen
#              (Quantifying/measuring biological phenomena).
# RT#18146
# TODO: check if CC, CXX are needed. If not, move to above
RUN \
    echo 'BiocManager::install(c('\
            '"biomaRt", ' \
            '"snpStats" ' \
        '))' | CC=gcc CXX=g++ Rscript - && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# plink: ELEC-A8720 - Biologisten ilmiöiden mittaaminen
#                     (Quantifying/measuring biological phenomena).
# RT#18146
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

# TODO: remove when base has a new enough nbgrader
RUN \
    pip uninstall nbgrader -y && \
    pip install --no-cache-dir \
        git+https://github.com/AaltoSciComp/nbgrader@live-2022#egg=nbgrader==0.7.0-dev3+aalto && \
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    clean-layer.sh


# bayesian machine learning, RT#21752
RUN \
    echo "install.packages(c(" \
            "'cmdstanr'" \
        "), " \
        "repos=c('https://mc-stan.org/r-packages/', getOption('repos'))," \
        "clean=TRUE)" | Rscript - && \
    fix-permissions /usr/local/lib/R/site-library


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
