ARG VER_STD
FROM aaltoscienceit/notebook-server:${VER_STD}

USER root

RUN apt-get update && \
    apt-get install -y -q wget libxml2 build-essential module-init-tools \
                          python3 python3-setuptools libegl1-mesa
RUN mkdir /opt/nvidia-installer
RUN cd /opt/nvidia-installer && \
    wget "https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.168_418.67_linux.run" && \
    chmod +x cuda_10.1.168_418.67_linux.run && \
    mkdir extract && \
    ./cuda_10.1.168_418.67_linux.run --extract=/opt/nvidia-installer/extract/ && \
    cd extract && \
    ./NVIDIA-Linux-x86_64-418.67.run -x --driver --toolkit && \
    cd NVIDIA-Linux-x86_64-418.67 && \
    ./nvidia-installer -q -s --no-kernel-module; cat /var/log/nvidia-installer.log && \
    cd / && rm -rf /opt/nvidia-installer
ENV CUDA_PATH /opt/nvidia-installer/extract/cuda-toolkit/
