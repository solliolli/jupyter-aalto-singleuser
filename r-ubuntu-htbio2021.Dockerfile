# NOTE: This is a temporary file, to be removed once r-ubuntu is fixed and rebuilt
ARG VER_R
FROM aaltoscienceit/notebook-server-r-ubuntu:${VER_R}

USER root

RUN \
    sed -i 's@/usr/bin/python@/usr/bin/python2@' /opt/tophat-2.1.1.Linux_x86_64/tophat

USER $NB_UID
