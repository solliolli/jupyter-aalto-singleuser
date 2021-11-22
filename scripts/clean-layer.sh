{
rm -rf /tmp/*

rm -rf /home/$NB_USER/.cache/yarn

conda clean --all --yes
mamba clean --all --yes
mountpoint /opt/conda/pkgs/cache/ || rm -rf /opt/conda/pkgs/cache/
mountpoint /root/.cache/pip/ || rm -rf /root/.cache/pip/*
npm cache clean --force

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

fix-permissions $CONDA_DIR /home/$NB_USER

} 2>&1 | sed -e 's/^/clean-layer:    /'
