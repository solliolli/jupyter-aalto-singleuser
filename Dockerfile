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
# sed -r -i 's/^(UMASK.*)022/\1002/' /etc/login.defs

COPY start.sh /usr/local/bin/
COPY disable_formgrader.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/disable_formgrader.sh


# JupyterHub says we can use any exsting jupyter image, as long as we properly pin the JupyterHub version
# https://github.com/jupyterhub/jupyterhub/tree/master/singleuser
RUN pip install jupyterhub==0.9.1 && \
           fix-permissions $CONDA_DIR /home/$NB_USER

# Custom installations
# nose: mlbp2018
# scikit-learn: mlbp2018
# plotchecker: for nbgrader, mlbp2018
RUN conda install \
           nose \
           scikit-learn && \
    pip install \
           plotchecker && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR /home/$NB_USER

# Custom extension installations
RUN conda install -c conda-forge \
           ipywidgets \
	   jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --sys-prefix && \
    pip install \
           nbdime && \
    jupyter labextension install @jupyterlab/hub-extension && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter serverextension enable --py nbdime --sys-prefix && \
    jupyter nbextension install --py nbdime --sys-prefix && \
    jupyter nbextension enable --py nbdime --sys-prefix && \
    jupyter labextension install nbdime-jupyterlab && \
    nbdime config-git --enable --system && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    conda clean -tipsy && \
    npm cache clean --force && \
    fix-permissions $CONDA_DIR /home/$NB_USER && \
    rm -rf /opt/conda/pkgs/cache/
#    jupyter labextension install @jupyterlab/git &&

RUN pip install git+https://github.com/rkdarst/nbgrader@bd9c4fa && \
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    jupyter nbextension enable --sys-prefix --py nbgrader && \
    jupyter serverextension enable --sys-prefix --py nbgrader && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR /home/$NB_USER

USER $NB_UID


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
