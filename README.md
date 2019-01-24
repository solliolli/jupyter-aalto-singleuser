This is the default singleuser image for the Aalto teaching and light
computing JupyterHub at https://jupyter.cs.aalto.fi.

Submit issues and pull requests to this repository for user server
environment.  Note that some courses may possibly have different
images.

The built images are on DockerHub:  https://hub.docker.com/r/aaltoscienceit/notebook-server

# How it works

`Dockerfile.base` contains the basic setup for the Jupyter environment.

`Dockerfile.standard` contains Python packages (all via the conda
install at `/opt/conda`).

`Dockerfile.r-ubuntu` contains R packages, but installed via Ubuntu
instead of via conda since there were some difficulties with using the
conda ones.

The `Makefile` provides some basic automation - check the rules in
there to see what they do.