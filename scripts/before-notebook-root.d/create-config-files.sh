if [ -n "$AALTO_nbgrader_config" ] ; then
    echo "$AALTO_nbgrader_config" >> /etc/jupyter/nbgrader_config.py
    unset AALTO_nbgrader_config
fi

if [ -n "$AALTO_jupyter_notebook_config" ] ; then
    echo "$AALTO_jupyter_notebook_config" >> /etc/jupyter/jupyter_notebook_config.py
    unset AALTO_jupyter_notebook_config
fi

