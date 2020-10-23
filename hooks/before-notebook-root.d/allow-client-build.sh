# Change some file ownerships to enable running `jupyter lab build` on the
# client. JupyterLab documentation doesn't recommend installing extensions in
# the global environment for security reasons but this isn't an issue here
# because the single user image is not shared across multiple users. See
# https://jupyterlab.readthedocs.io/en/stable/user/extensions.html#jupyterlab-build-process
# for more details.
chown $NB_UID /opt/conda/share/jupyter/lab/staging/*.js \
  /opt/conda/share/jupyter/lab/staging/.yarnrc
