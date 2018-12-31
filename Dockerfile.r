#FROM aaltoscienceit/notebook-server-base
FROM jupyter/r-notebook

## R support

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-dejavu \
        tzdata \
        gzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#        gfortran \
#        libnlopt0 \
#        gfortran \

#  conda update --all && \


RUN conda config --system --remove channels conda-forge && \
    conda config --system --append channels conda-forge && \
    conda install -c conda -v --quiet --yes \
    'gcc-ng' \
    'binutils' \
    'nlopt' && \
    conda install --quiet --yes \
    'r-base' \
    'r-irkernel' \
    'r-plyr' \
    'r-devtools' \
    'r-tidyverse' \
    'r-shiny' \
    'r-rmarkdown' \
    'r-forecast' \
    'r-rsqlite' \
    'r-reshape2' \
    'r-nycflights13' \
    'r-caret' \
    'r-rcurl' \
    'r-crayon' \
    'r-randomforest' \
    'r-htmltools' \
    'r-sparklyr' \
    'r-htmlwidgets' \
    'r-hexbin' && \
     conda install -c conda-forge --quiet --yes \
         'r-bayesplot' \
         'r-rstan' \
         'r-rstanarm' \
         'r-shinystan' \
         'r-loo' \
         'r-brms' \
         'r-ggally' \
         'r-mass' \
         'r-coda' \
         'r-gridbase' \
         'r-gridextra' \
         'r-here' && \
    Rscript -e 'install.packages("projpred", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR
#        'r-gridgraphics'  ??


#    Rscript -e 'install.packages("nlopt", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("bayesplot", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("rstan", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("rstanarm", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("shinystan", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("loo", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("brms", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("ggally", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("mass", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("coda", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("gridbase", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("gridextra", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \
#    Rscript -e 'install.packages("here", repos="https://ftp.acc.umu.se/mirror/CRAN/")' && \



USER $NB_UID
