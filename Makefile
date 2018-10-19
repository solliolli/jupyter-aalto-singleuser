VER_BASE=0.4.3
VER_STD=0.4.3
VER_R=0.4.3

TEST_MEM_LIMIT="--memory=2G"

.PHONY: default

default:
	echo "Please specifiy a command to run"

full-rebuild: base standard test-standard


base:
	docker build -t aaltoscienceit/notebook-server-base:$(VER_BASE) . -f Dockerfile.base
standard:
	docker build -t aaltoscienceit/notebook-server:$(VER_STD) . -f Dockerfile.standard --build-arg=VER_BASE=$(VER_BASE)
#r:
#	docker build -t aaltoscienceit/notebook-server-r:0.4.0 --pull=false . -f Dockerfile.r
r:
	docker build -t aaltoscienceit/notebook-server-r-ubuntu:$(VER_R) --pull=false . -f Dockerfile.r-ubuntu --build-arg=VER_BASE=$(VER_BASE)


test-standard:
	mkdir -p /tmp/tests
	rsync -a tests/ /tmp/tests/
	docker run --volume=/tmp/tests:/tests:ro ${TEST_MEM_LIMIT} aaltoscienceit/notebook-server:$(VER_STD) pytest /tests/python/
#	CC="clang" CXX="clang++" jupyter nbconvert --exec --ExecutePreprocessor.timeout=300 pystan_demo.ipynb --stdout

test-r:
	mkdir -p /tmp/tests
	rsync -a tests/ /tmp/tests/
	docker run --volume=/tmp/tests:/tests:ro ${TEST_MEM_LIMIT} aaltoscienceit/notebook-server-r-ubuntu:$(VER_R) Rscript /tests/r/test_bayes.r



push-standard:
	docker push aaltoscienceit/notebook-server:$(VER_STD)
push-r:
	docker push aaltoscienceit/notebook-server-r-ubuntu:$(VER_R)
push-dev:
	time docker save aaltoscienceit/notebook-server-r-ubuntu:${VER_STD} | ssh manager ssh jupyter-k8s-node2.cs.aalto.fi 'docker load'
