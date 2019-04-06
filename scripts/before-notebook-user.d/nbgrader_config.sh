if [ -r /course/etc.jupyter.nbgrader_config.py.append -a -w /etc/jupyter/nbgrader_config.py ] ; then
    cat /course/etc.jupyter.nbgrader_config.py.append >> /etc/jupyter/nbgrader_config.py
fi
