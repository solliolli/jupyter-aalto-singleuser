ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

USER root

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
        libssl-dev \
        libopenblas-dev \
        liblapack-dev \
        r-base \
        # TODO: remove when base image is updated
        build-essential \
        # for rstan
        libnode-dev \
        # htbioinformatics2019, for fastcq
        openjdk-11-jre-headless \
        # dependencies for samtools
        libbz2-dev \
        libncurses5-dev \
        liblzma-dev \
        # devtools dependencies
        libharfbuzz-dev \
        libfribidi-dev \
        libxml2-dev \
        # rstanarm dependency
        cmake \
          && \
    update-alternatives --set cc  /usr/bin/clang && \
    update-alternatives --set c++ /usr/bin/clang++ && \
    update-alternatives --set c89 /usr/bin/clang && \
    update-alternatives --set c99 /usr/bin/clang && \
    clean-layer.sh

#libnlopt-dev --> NO, not compatible

#libprce2-dev
#libbz2-dev
#liblzma-dev

ARG CRAN_URL
ARG INSTALL_JOB_COUNT

# TODO: remove when base contains this
COPY scripts/install-r-packages.sh  /usr/local/bin/
RUN chmod +x /usr/local/bin/install-r-packages.sh

RUN \
    install-r-packages.sh --url ${CRAN_URL} -j ${INSTALL_JOB_COUNT} \
        IRkernel \
        repr \
        IRdisplay \
        evaluate \
        crayon \
        pbdZMQ \
        uuid \
        digest \
          && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh && \
    Rscript -e 'IRkernel::installspec(user = FALSE)'
RUN jupyter kernelspec remove -f python3

# Packages from jupyter r-notebook
RUN \
    install-r-packages.sh --url ${CRAN_URL} -j ${INSTALL_JOB_COUNT} \
        plyr \
        devtools \
        tidyverse \
        shiny \
        markdown \
        forecast \
        RSQLite \
        reshape2 \
        nycflights13 \
        caret \
        RCurl \
        crayon \
        randomForest \
        htmltools \
        sparklyr \
        htmlwidgets \
        hexbin \
        caTools \
          && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

RUN Rscript -e 'install.packages("BiocManager")' && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

#
# Course setup
#

# NOTE: building this takes ~40 minutes
RUN \
    install-r-packages.sh --url ${CRAN_URL} -j ${INSTALL_JOB_COUNT} \
        # bayesian data analysis course, RT#13568
        bayesplot \
        rstan \
        rstanarm \
        shinystan \
        loo \
        brms \
        GGally \
        MASS \
        coda \
        gridBase \
        gridExtra \
        here \
        projpred \
        # " RT#17144
        StanHeaders \
        tweenr \
        gganimate \
        ggforce \
        ggrepel \
        av \
        magick \
        # " RT#15341
        markmyassignment \
        RUnit \
        # htbioinformatics RT#17450
        aods3 \
        # compgeno2022 RT#21822
        ape \
        ggplot2 \
        reshape2 \
        HMM \
        phangorn \
        testit \
        # unknown purpose, was included in the original Dockerfile
        nloptr \
          && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# Bioconductor
RUN \
    install-r-packages.sh --bioconductor \
        # RT#15527 htbioinformatics
        edgeR \
        GenomicRanges \
        rtracklayer \
        BSgenome.Hsapiens.NCBI.GRCh38 \
        # RT#17450 htbioinformatics
        BiSeq \
        limma \
        # compgeno2022 RT#21822
        DECIPHER \
        ORFik \
        Biostrings \
          && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

# Packages from Stan
RUN \
    install-r-packages.sh --url 'https://mc-stan.org/r-packages/' \
        # bayesian data analysis, RT#21752
        cmdstanr \
          && \
    fix-permissions /usr/local/lib/R/site-library && \
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

# ====================================

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

RUN \
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

# ====================================

# TODO: remove when base has a new enough nbgrader
RUN \
    pip uninstall nbgrader -y && \
    pip install --no-cache-dir \
        git+https://github.com/AaltoSciComp/nbgrader@live-2022#egg=nbgrader==0.7.0-dev3+aalto && \
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    clean-layer.sh

# ====================================

#
# TODO: Last-added packages, move to above when rebuilding
#

# # coursecode, RT#00000
# RUN \
#     install-r-packages.sh --url ${CRAN_URL} -j ${INSTALL_JOB_COUNT} \
#         packagename \
#           && \
#     fix-permissions /usr/local/lib/R/site-library && \
#     clean-layer.sh
#
#
# # coursecode, RT#00000
# RUN \
#     install-r-packages.sh --bioconductor \
#         packagename_from_bioc \
#           && \
#     fix-permissions /usr/local/lib/R/site-library && \
#     clean-layer.sh

# bayesda2022, RT#22450
RUN \
    install-r-packages.sh --url ${CRAN_URL} -j ${INSTALL_JOB_COUNT} \
        latex2exp \
          && \
    fix-permissions /usr/local/lib/R/site-library && \
    clean-layer.sh

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
