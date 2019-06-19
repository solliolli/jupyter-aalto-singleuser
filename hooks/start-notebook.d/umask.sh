if [ -n "$NB_UMASK" ] ; then
    echo "Setting umask to $NB_UMASK"
    umask $NB_UMASK
fi
