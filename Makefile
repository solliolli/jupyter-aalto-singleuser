UPSTREAM_SCIPY_NOTEBOOK_VER=7254cdcfa22b
CRAN_URL=https://cran.microsoft.com/snapshot/2018-12-31/
VER_BASE=0.5.1       # base image - jupyter stuff only, not much software
VER_STD=0.5.12       # Python
VER_JULIA=0.5.9      # Julia
VER_R=0.5.3          # R

TEST_MEM_LIMIT="--memory=2G"

.PHONY: default

default:
	echo "Please specifiy a command to run"

full-rebuild: base standard test-standard


base:
	docker build -t aaltoscienceit/notebook-server-base:$(VER_BASE) . -f Dockerfile.base --build-arg=UPSTREAM_SCIPY_NOTEBOOK_VER=$(UPSTREAM_SCIPY_NOTEBOOK_VER)
standard:
	docker build -t aaltoscienceit/notebook-server:$(VER_STD) . -f Dockerfile.standard --build-arg=VER_BASE=$(VER_BASE)
#r:
#	docker build -t aaltoscienceit/notebook-server-r:0.4.0 --pull=false . -f Dockerfile.r
r:
	docker build -t aaltoscienceit/notebook-server-r-ubuntu:$(VER_R) --pull=false . -f Dockerfile.r-ubuntu --build-arg=VER_BASE=$(VER_BASE) --build-arg=CRAN_URL=$(CRAN_URL)
julia:
	docker build -t aaltoscienceit/notebook-server-julia:$(VER_JULIA) --pull=false . -f Dockerfile.julia --build-arg=VER_BASE=$(VER_BASE)



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
push-dev:
	time docker save aaltoscienceit/notebook-server-r-ubuntu:${VER_STD} | ssh ${KHOST} ssh jupyter-k8s-node2.cs.aalto.fi 'docker load'



pull-standard:
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} "docker pull aaltoscienceit/notebook-server:${VER_STD}"
pull-r:
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} "docker pull aaltoscienceit/notebook-server-r-ubuntu:${VER_R}"
pull-julia:
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} "docker pull aaltoscienceit/notebook-server-julia:${VER_JULIA}"


# Clean up disk space
prune-images:
#	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker rmi aaltoscienceit/notebook-server:0.5.{0,1,2,3,4,5,6,7}'
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker image prune -f'
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker container prune -f'
	ssh ${KHOST} time pdsh -R ssh -w ${KNODES} 'docker images' | cut '-d:' '-f2-' | sort

