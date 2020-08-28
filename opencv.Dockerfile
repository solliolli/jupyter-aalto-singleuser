ARG VER_STD
FROM aaltoscienceit/notebook-server:${VER_STD}
ENV OPENCV_VERSION 4.1.0

USER root
COPY files/patches /usr/local/src

# Installation steps from
# https://docs.opencv.org/master/d7/d9f/tutorial_linux_install.html
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        && \
    clean-layer.sh

# The course requested, should be in the base image already but making sure
RUN \
    sed -i '/python.*/d' /opt/conda/conda-meta/pinned && \
    echo "python ==3.7.8" >> /opt/conda/conda-meta/pinned

RUN \
    cd /usr/local/src && \
    git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv_contrib && \
    git checkout -q $OPENCV_VERSION && \
    cd ../opencv && \
    git checkout -q $OPENCV_VERSION && \
    # https://github.com/opencv/opencv/issues/17952#issuecomment-666664154
    if [ "$OPENCV_VERSION" = "4.4.0" ]; then \
      git apply /usr/local/src/0001-Fix-build-error-regarding-gkernel.patch; \
    fi && \
    mkdir build && cd build && \
    # https://stackoverflow.com/a/54176727
    cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D BUILD_EXAMPLES=ON \
        -D PYTHON3_EXECUTABLE=$(which python3) \
        -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -D PYTHON3_LIBRARY=$(python3 -c "from distutils.sysconfig import get_config_var; from os.path import dirname,join ; print(join(dirname(get_config_var('LIBPC')), get_config_var('LDLIBRARY')))") \
        -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy; print(numpy.get_include())") \
        -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        .. && \
    make -j$(nproc) && \
    make install && \
    cd /usr/local/src && rm -r /usr/local/src/*

RUN conda install --quiet --yes pyflann line_profiler

USER $NB_UID
