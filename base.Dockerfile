ARG UPSTREAM_MINIMAL_NOTEBOOK_VER
FROM jupyter/minimal-notebook:${UPSTREAM_MINIMAL_NOTEBOOK_VER}

USER root

ADD scripts/clean-layer.sh /usr/local/bin/

# Debian package
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        clang \
        file \
        git-annex \
        git-lfs \
        git-svn \
        graphviz \
        less \
        man-db \
        && \
    clean-layer.sh

#RUN touch /.nbgrader.log && chmod 777 /.nbgrader.log
# sed -r -i 's/^(UMASK.*)022/\1002/' /etc/login.defs

# JupyterHub 1.0.0 is included in the current scipy-notebook image
# JupyterHub says we can use any existing jupyter image, as long as we properly
# pin the JupyterHub version
# https://github.com/jupyterhub/jupyterhub/tree/master/singleuser
RUN mamba install jupyterhub==1.1.0 && \
    clean-layer.sh


# Custom extension installations
#   importnb allows pytest to test ipynb
RUN conda config --prepend channels conda-forge && \
    conda config --system --set channel_priority strict && \
    mamba install \
        bash_kernel \
        conda-tree \
        importnb \
        inotify_simple \
        ipywidgets \
        jupyter_contrib_nbextensions \
        nbval \
        pipdeptree \
        pytest \
        voila \
        && \
    jupyter contrib nbextension install --sys-prefix && \
    python -m bash_kernel.install --sys-prefix && \
    ln -s /notebooks /home/jovyan/notebooks && \
    rm --dir /home/jovyan/work && \
    clean-layer.sh

RUN \
    mamba install jupyterlab==2.* && \
    mamba install \
        jupyterlab-git \
        nbdime \
        nbgitpuller \
        nbstripout \
        && \
    jupyter labextension install \
                                # Deprecated, hub is now a built-in
                                #  @jupyterlab/hub-extension \
                                 @jupyter-widgets/jupyterlab-manager \
                                 @jupyterlab/git \
                                 @fissio/hub-topbar-buttons \
                                # Incompatible with jupyterlab 1.0.2
                                 nbdime-jupyterlab \
                                 @lckr/jupyterlab_variableinspector \
                                jupyter-matplotlib \
                                && \
    nbdime config-git --enable --system && \
    jupyter serverextension enable nbgitpuller --sys-prefix && \
    git config --system core.editor nano && \
    clean-layer.sh

#    jupyter serverextension enable --py nbdime --sys-prefix && \
#    jupyter nbextension install --py nbdime --sys-prefix && \
#    jupyter nbextension enable --py nbdime --sys-prefix && \
#    jupyter nbextension enable varInspector/main --sys-prefix && \
#    jupyter serverextension enable --py --sys-prefix jupyterlab_git && \
#    jupyter serverextension enable --py nbzip --sys-prefix && \
#    jupyter nbextension install --py nbzip && \
#    jupyter nbextension enable --py nbzip && \



# Nbgrader
RUN pip install --no-cache-dir git+https://github.com/AaltoSciComp/nbgrader@ce02a88c && \
    jupyter nbextension install --sys-prefix --py nbgrader --overwrite && \
    jupyter nbextension enable --sys-prefix --py nbgrader && \
    jupyter serverextension enable --sys-prefix --py nbgrader && \
    jupyter nbextension disable --sys-prefix formgrader/main --section=tree && \
    jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader && \
    jupyter nbextension disable --sys-prefix create_assignment/main && \
    jupyter nbextension disable --sys-prefix course_list/main --section=tree && \
    jupyter serverextension disable --sys-prefix nbgrader.server_extensions.course_list && \
    clean-layer.sh

# Hooks and scrips are also copied at the end of other Dockerfiles because they
# might update frequently
COPY hooks/ scripts/ /usr/local/bin/
RUN chmod a+rx /usr/local/bin/*.sh

USER $NB_UID
