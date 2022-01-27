ARG VER_BASE
FROM aaltoscienceit/notebook-server-base:${VER_BASE}

USER root

ARG ENVIRONMENT_NAME
ARG ENVIRONMENT_VERSION
ARG ENVIRONMENT_HASH
ENV JUPYTER_SOFTWARE_IMAGE=${ENVIRONMENT_NAME}_${ENVIRONMENT_VERSION}_${ENVIRONMENT_HASH}

# NOTE: files contained in the tar archive must have gid=100 and file mode g=rw
#       if the user is supposed to be able to use `mamba install` on the base
#       environment when running the image
ADD conda/${JUPYTER_SOFTWARE_IMAGE}.tar.gz /opt/software
RUN chown --reference=/opt/software/environment.yml /opt/software && \
    chmod g+rw /opt/software

# NOTE: Running this would massively inflate the image size, permissions should
#       be set correctly when creating the archive, or we should mount the
#       archive and exctract manually. Currently fixed using make
# RUN fix-permissions /opt/software

# TODO: Move the scripts to the base image when updating
COPY scripts/tar-patch /usr/local/bin
COPY scripts/update-software.sh /usr/local/bin

# Incremental updates to the software stack:
COPY delta_e97c272-443f529f.tardiff /tmp/delta.tardiff
RUN /usr/local/bin/update-software.sh /tmp/delta.tardiff
# The delta file was generated using the following command:
#   tar-diff /m/scicomp/software/anaconda-ci/aalto-jupyter-anaconda-dev/packs/jupyter-generic_2021-11-23_{e97c2729,443f529f}.tar.gz delta_e97c272-443f529f.tardiff

COPY delta_443f529f-0db9baab.tardiff /tmp/delta.tardiff
RUN /usr/local/bin/update-software.sh /tmp/delta.tardiff

# Custom installations
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#           ... \
#           && \
#    clean-layer.sh

# Update nbgrader
RUN \
    pip uninstall nbgrader -y && \
    pip install --no-cache-dir \
        git+https://github.com/AaltoSciComp/nbgrader@live-2022#egg=nbgrader==0.7.0-dev2+aalto \
        'nbconvert<6' && \
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    clean-layer.sh

# requires bdaaccounting collection in the builder
# RUN \
#     echo [FreeTDS] >> /etc/odbcinst.ini && \
#     echo Description=FreeTDS Driver >> /etc/odbcinst.ini && \
#     echo Driver=/opt/conda/lib/libtdsodbc.so >> /etc/odbcinst.ini && \
#     echo Setup=/opt/conda/lib/libtdsS.so >> /etc/odbcinst.ini && \
#     clean-layer.sh


# ========================================

RUN /opt/software/bin/python -m ipykernel install --prefix=/opt/conda --display-name="Python 3"

ENV CC=clang CXX=clang++

RUN echo "import os ; os.environ['PATH'] = '/opt/software/bin:'+os.environ['PATH']" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "import os ; os.environ['PATH'] = '/opt/software/bin:'+os.environ['PATH']" >> /etc/jupyter/jupyter_server_config.py

ENV PATH=/opt/software/bin:${PATH}
ENV CONDA_DIR=/opt/software

# Duplicate of base, but hooks can update frequently and are small so
# put them last.
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+rx /usr/local/bin/*.sh

# Save version information within the image
ARG VER_STD
RUN echo IMAGE_VERSION=${VER_STD} >> /etc/cs-jupyter-release && \
    echo JUPYTER_SOFTWARE_IMAGE=${JUPYTER_SOFTWARE_IMAGE} >> /etc/cs-jupyter-release

USER $NB_UID
