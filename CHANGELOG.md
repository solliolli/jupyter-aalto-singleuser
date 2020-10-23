# Changelog

## [Unreleased]

## [3.0.5] - r-ubuntu - 2020-10-23
### Added
- r-ubuntu: packages aods3 (CRAN) and (BiSeq, limma) (bioconductor)

### Fixed
- Made sure that copied scripts have the executable bit set within the image
  after building

## [3.0.4] r-umuntu - 2020-09-03
### Added
- Ubuntu packages libavfilter-dev and libmagick++-dev, for the below:
- Add R packages av and magick

## [3.0.3] r-ubuntu - 2020-08-27
### Added
- New packages: gifski ggforce ggrepel

## [3.0.1] r-ubuntu - 2020-08-21
### Added
- New package: StanHeaders

## [3.0.0] - 2020-07-14
### Changed
- Upgrade Python from 3.7.6 to 3.8.3
- Upgrade CRAN snapshot to 2020-07-12
- Upgrade nbgrader to version 26 Jun 2020 (b5ae9f8)
- Upgrade scipy notebook to version 2020-07-05 (5197709e9f23)
- Upgrade julia to v1.4.2
- Bump package versions:
  - tensorflow 2.0 -> 2.2
  - keras 2.3 -> 2.4
  - pytorch 1.3 -> 1.5
  - torchvision 0.4 -> 0.6
  - rstudio 1.2.5001 -> 1.3.959

### Fixed
- Fix python-igraph unit test

## [2.0.6] Standard - 2020-06-30
### Added
- Basic unit test for ortools package
- New packages: inotify, configargparse, conda-tree

### Changed
- Made `.bash_history` persistent across server instances

## [2.0.5] Standard - 2020-02-02
### Added
- New package: ortools

## [2.0.4] Standard - 2020-01-16
### Fixed
- Fix nbgrader permissions problem

## [2.0.3] Standard - 2020-01-15
### Added
- New packages: jupyter-matplotlib, ipympl

## [2.0.2] Standard - 2020-01-13
### Added
- New package: opencv

## [2.0.1] Standard - 2020-01-07
### Added
- New package: owslib

## [2.0.0] - 2019-12-30
### Changed
- Upgrade jupyterlab to v1.2.4
- Upgrade scipy notebook to version 12 Dec 2019
- Upgrade nbgrader to version 12 Nov 2019 (4c5d6f6)
- Downgrade gpflow to v2.0.0rc1
- Upgrade julia to v1.3.0
- Upgrade CRAN snapshot to 2019-12-29
- Bump package versions:
  - tensorflow 2.0.0
  - keras 2.3
  - pytorch 1.3

### Added
- New package: pipdeptree

## 1.8.12 (standard)
- Install nltk

## [1.8.11] r-ubuntu - 2019-11-21
### Changed
- Fix rtracklayer installation

## 1.8.8 (standard)
- Install cma, pydub (intcompmedia)
- Install nbgitpuller

## 1.8.7 (r-ubuntu)
Add htseq and samtools for htbioinformatics2019

## 1.8.6 (r-ubuntu)
fix tophat2 python interpreter, clean layers

## 1.8.5 (r-ubuntu)
- add packages for htbioinformatics2019, including bioconductor
  and command-line tools

## [1.8.4]
- r-ubuntu: add markmyassignment

## [1.8.3]
### Changed
- Update RStudio version

## [1.8.1]
### Changed
- Add groups.sh hook create groups and set them as server requests

## [1.8.0]
### Changed
- Try to make images work for bayesian data analysis course
  - Set clang as default compilers for R, or try to
  - Set CC and CXX to clang/clang++ in standard image
- Combine standard layer creation to speed up build
- Change location of clean-layer.sh, add some stuff to it
- Updateto JupyterLab 1.1.3 ( (fixes file list with git-extension, jupyterlab/jupyterlab#7204)

## [1.7.1] Standard - 2019-09-06
### Added
- Packages wordcloud and geopy for course datasci2019

## [1.7.0] - 2019-08-26
### Changed
- Update scipy-notebook image to version 2ce7c06a61a1,
  version published Aug 11, 2019 03:40 AM

## [1.6.1] R - 2019-08-26
### Changed
- Update jupyter-rsession-proxy

## [1.6.1] Standard - 2019-08-26
### Changed
- Update qiskit to version 0.12.0

## [1.6] Base - 2019-08-26
### Changed
- Update nbgrader to commit 49d2d1f

## R [1.0.2] - 2019-08-23
### Added
- Add jupyterlab server proxy
### Changed
- Update CRAN to version 2019-07-05

## [1.0.5] - 2019-08-22
### Added
- Add variable inspector to notebook and lab
### Changed
- Update nbgrader to commit db70a60

## [1.0.4] - 2019-08-07
### Changed
- Add hub topbar button lab extension

## [1.0.3] - 2019-08-05
### Changed
- Update scipy-notebook image to version 58169ec3cfd3,
  version published Aug 4, 2019 05:21 AM

## [1.0.2] - 2019-08-05
### Changed
- Update nbgrader

## [1.0.1] - 2019-07-26
### Changed
- Update scipy-notebook image to version 7a3e968dd212,
  version published on July 17, 2019 12:15 AM
### Fixed
- Stop pip from caching files

## [1.0.0] - 2019-07-24
### Updated images for JupyterHub 1.0

## [0.5.19-1.0] - 2019-07-24
- Improve image layer cache clearing

## [0.5.18-1.0] - 2019-07-24
### Changed
- Update nbgrader to the latest commit

## [0.5.17-1.0] - 2019-07-24
### Changed
- Update JupyterHub to version 1.0

## [0.5.16] - 2019-07-23
- Prepare for JupyterHub 1.0 upgrade

## [0.5.15] - 2019-07-09
### Fixed
- Ensure that scripts are executable after copying

## [0.5.14] - 2019-06-10
### Updated
- anaconda to version 4.6.14
- the scipy image to version d4cbf2f80a2a, version published on
  June 2, 2019 03:45 AM

## [0.5.13] - 2019-06-07
### Added
- qiskit

## [0.5.12] - 2019-06-03
### Added
- calysto
- metakernel

## [0.5.11] - 2019-04-06
### Added
- tensorflow_hub
### Updated
- tensorflow

## [0.5.10] - 2019-04-05
### Fixed
- cvxpy fixes

## [0.5.9] - 2019-03-04
### Added
- julia

## [0.5.8] - 2019-02-25
### Added
- gpflow

## [0.5.7] - 2019-02-20
### Added
- cvxopt
- lapack
- cvxpy
### Updated
- nbgrader

## [0.5.5] - 2019-01-28
### Added
- nbstripoutput
### Updated
- pytorch

## [0.5.3] - 2019-01-06
### Added
- mlxetend
- scikit-plot

## [0.5.1] - 2019-01-02
### Updated
- nbgrader

## [0.5.0] - 2018-12-29
### Updated
- Major update to latest notebook and software
