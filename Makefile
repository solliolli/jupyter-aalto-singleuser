VER_BASE=0.4.3
VER_STD=0.4.3
VER_R=0.4.3

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
	cp -r tests/* /tmp/tests/
	docker run --volume=/tmp/tests:/tests:ro aaltoscienceit/notebook-server:$(VER_STD) pytest /tests/python/

test-r:
	mkdir -p /tmp/tests
	cp tests/* /tmp/tests/
	docker run --volume=/tmp/tests:/tests:ro -it aaltoscienceit/notebook-server-r-ubuntu:$(VER_R) Rscript /tests/r/test-bayes.r


push-standard:
	docker push aaltoscienceit/notebook-server:$(VER_STD)
push-r:
	docker push aaltoscienceit/notebook-server-r-ubuntu:$(VER_R)
push-dev:
	time docker save aaltoscienceit/notebook-server-r-ubuntu:${VER_STD} | ssh manager ssh jupyter-k8s-node2.cs.aalto.fi 'docker load'
