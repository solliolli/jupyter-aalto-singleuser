{
rm -rf /tmp/*

rm -rf /home/$NB_USER/.cache/yarn

conda clean --all --yes
mamba clean --all --yes
mountpoint -q /opt/conda/pkgs/cache/ || rm -rf /opt/conda/pkgs/cache/
mountpoint -q /root/.cache/pip/ || rm -rf /root/.cache/pip/*
npm cache clean --force

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

fix-permissions $CONDA_DIR /home/$NB_USER

} 2>&1 > /dev/null
