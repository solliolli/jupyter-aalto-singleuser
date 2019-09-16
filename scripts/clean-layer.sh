rm -rf /tmp/*

rm -rf /home/$NB_USER/.cache/yarn

conda clean --all --yes
rm -rf /opt/conda/pkgs/cache/

npm cache clean --force
rm -rf /root/.cache/pip/*

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

fix-permissions $CONDA_DIR /home/$NB_USER
