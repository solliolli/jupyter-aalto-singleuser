FROM jupyter/scipy-notebook:8d22c86ed4d7


USER root

# Debian package
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
           less \
           && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN touch /.nbgrader.log && chmod 777 /.nbgrader.log

COPY start.sh /usr/local/bin/
COPY disable_formgrader.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/disable_formgrader.sh


USER $NB_UID

# JupyterHub says we can use any exsting jupyter image, as long as we properly pin the JupyterHub version
# https://github.com/jupyterhub/jupyterhub/tree/master/singleuser
RUN pip install jupyterhub==0.9.1 && \
           fix-permissions $CONDA_DIR /home/$NB_USER

# Custom installations
# nose: mlbp2018
# scikit-learn: mlbp2018
RUN conda install \
           nose \
           scikit-learn && \
           fix-permissions $CONDA_DIR /home/$NB_USER

# plotchecker: for nbgrader, mlbp2018
RUN pip install \
           plotchecker && \
           fix-permissions $CONDA_DIR /home/$NB_USER

RUN pip install git+https://github.com/rkdarst/nbgrader@live && \
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    jupyter nbextension enable --sys-prefix --py nbgrader && \
    jupyter serverextension enable --sys-prefix --py nbgrader && \
    fix-permissions $CONDA_DIR /home/$NB_USER



# In the Jupyter image, the default start command is
# start-notebook.sh.  If the env var JPY_API_TOKEN is defined, it will
# thun run start-singleuser.sh which then starts the single-user
# server properly.  It starts the singleuser server by calling
# start.sh with the right arguments.  If start.sh runs as root, it
# will use some env vars like NB_USER, NB_UID, NB_GID,
# GRANT_SUDO[=yes] to do various manipulations inside to set
# permissions to this particular user before running sudo to NB_USER
# to start the single-user image.  So thus, we need to do our initial
# setup and then call this.

# Note: put hooks in /usr/local/bin/start-notebook.d/ and start.sh
# will run these (source if end in .sh, run if +x).

#CMD " && start-notebook.sh"
