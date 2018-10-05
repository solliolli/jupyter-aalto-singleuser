
base:
	docker build -t aaltoscienceit/notebook-server-base:0.4.0 . -f Dockerfile.base
standard:
	docker build -t aaltoscienceit/notebook-server:0.4.0 . -f Dockerfile.standard
r:
	docker build -t aaltoscienceit/notebook-server-r:0.4.0 --pull=false . -f Dockerfile.r
r-ubuntu:
	docker build -t aaltoscienceit/notebook-server-r-ubuntu:0.4.0 --pull=false . -f Dockerfile.r-ubuntu

