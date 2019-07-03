## Changelog:
##
## 0.5.14-dev: 	new scipy image, conda 4.6.14
## 0.5.13: 		old scipy image + qiskit

UPSTREAM_SCIPY_NOTEBOOK_VER=d4cbf2f80a2a  # Image updated June 2, 2019 03:45 AM
CRAN_URL=https://cran.microsoft.com/snapshot/2018-12-31/
VER_BASE=0.5.2-dev   # base image - jupyter stuff only, not much software
VER_STD=0.5.14-dev   # Python
VER_JULIA=0.5.10     # Julia
VER_R=0.5.4-dev      # R

TEST_MEM_LIMIT="--memory=2G"

.PHONY: default

default:
	echo "Please specifiy a command to run"

full-rebuild: base standard test-standard


base:
	docker build -t aaltoscienceit/notebook-server-base:$(VER_BASE) . -f base.Dockerfile --build-arg=UPSTREAM_SCIPY_NOTEBOOK_VER=$(UPSTREAM_SCIPY_NOTEBOOK_VER)
standard:
	docker build -t aaltoscienceit/notebook-server:$(VER_STD) . -f standard.Dockerfile --build-arg=VER_BASE=$(VER_BASE)
#r:
#	docker build -t aaltoscienceit/notebook-server-r:0.4.0 --pull=false . -f r.Dockerfile
r:
	docker build -t aaltoscienceit/notebook-server-r-ubuntu:$(VER_R) --pull=false . -f r-ubuntu.Dockerfile --build-arg=VER_BASE=$(VER_BASE) --build-arg=CRAN_URL=$(CRAN_URL)
julia:
	docker build -t aaltoscienceit/notebook-server-julia:$(VER_JULIA) --pull=false . -f julia.Dockerfile --build-arg=VER_BASE=$(VER_BASE)



test-standard:
	mkdir -p /tmp/nbs-tests
	rsync -a --delete tests/ /tmp/nbs-tests/
	docker run --volume=/tmp/nbs-tests:/tests:ro ${TEST_MEM_LIMIT} aaltoscienceit/notebook-server:$(VER_STD) pytest -o cache_dir=/tmp/pytestcache /tests/python/${TESTFILE} ${TESTARGS}
#	CC="clang" CXX="clang++" jupyter nbconvert --exec --ExecutePreprocessor.timeout=300 pystan_demo.ipynb --stdout
test-standard-full: test-standand
	docker run --volume=/tmp/nbs-tests:/tests:ro ${TEST_MEM_LIMIT} aaltoscienceit/notebook-server:$(VER_STD) bash -c 'cd /tmp ; git clone https://github.com/avehtari/BDA_py_demos ; cd BDA_py_demos/demos_pystan/ ; CC=clang CXX=clang++ jupyter nbconvert --exec --ExecutePreprocessor.timeout=300 pystan_demo.ipynb --stdout > /dev/null'
	@echo
	@echo
	@echo
	@echo "All tests passed..."

test-r:
	mkdir -p /tmp/tests
	rsync -a tests/ /tmp/tests/
	docker run --volume=/tmp/tests:/tests:ro ${TEST_MEM_LIMIT} aaltoscienceit/notebook-server-r-ubuntu:$(VER_R) Rscript /tests/r/test_bayes.r



push-standard:
	docker push aaltoscienceit/notebook-server:$(VER_STD)
push-r:
	docker push aaltoscienceit/notebook-server-r-ubuntu:$(VER_R)
push-julia:
#	time docker save aaltoscienceit/notebook-server-julia:${VER_JULIA} | ssh manager ssh jupyter-k8s-node2.cs.aalto.fi 'docker load'
	docker push aaltoscienceit/notebook-server-julia:$(VER_JULIA)
push-dev: check-khost
	## NOTE: Saving and loading the whole image takes a long time. Pushing
	##       partial changes to a DockerHub repo using `push-devhub` is faster
	# time docker save aaltoscienceit/notebook-server-r-ubuntu:${VER_STD} | ssh ${KHOST} ssh jupyter-k8s-node2.cs.aalto.fi 'docker load'
	time docker save aaltoscienceit/notebook-server:${VER_STD} | ssh ${KHOST} ssh jupyter-k8s-node2.cs.aalto.fi 'docker load'
push-devhub: check-khost check-hubrepo
	docker tag aaltoscienceit/notebook-server:${VER_STD} ${HUBREPO}/notebook-server:${VER_STD}
	docker push ${HUBREPO}/notebook-server:${VER_STD}
	ssh ${KHOST} ssh jupyter-k8s-node3.cs.aalto.fi "docker pull ${HUBREPO}/notebook-server:${VER_STD}"

pull-standard: check-khost check-knodes
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} "docker pull aaltoscienceit/notebook-server:${VER_STD}"
pull-r: check-khost check-knodes
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} "docker pull aaltoscienceit/notebook-server-r-ubuntu:${VER_R}"
pull-julia: check-khost check-knodes
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} "docker pull aaltoscienceit/notebook-server-julia:${VER_JULIA}"

# Clean up disk space
prune-images: check-khost check-knodes
#	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker rmi aaltoscienceit/notebook-server:0.5.{0,1,2,3,4,5,6,7}'
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker image prune -f'
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker container prune -f'
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker images' | cut '-d:' '-f2-' | sort

# Aborts the process if necessary environment variables are not set
# https://stackoverflow.com/a/4731504/3005969
check-khost:
ifndef KHOST
	$(error KHOST is undefined. Format: KHOST=user@kubernetes_host.tld)
endif

check-knodes:
ifndef KNODES
	$(error KNODES is undefined. Format: KNODES=kubernetes-node[1-n].tld)
endif

check-hubrepo:
ifndef HUBREPO
	$(error HUBREPO is undefined. Format: HUBREPO=dockerhub_repo_name)
endif
