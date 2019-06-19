# This serves no useful purpose other than to pre-make this directory
# so that "conda install" won't fail later.  It fails, but the dir is
# made anyway and conda install works again.  This just removes some
# confusion.
mkdir -p /opt/conda/pkgs/cache
