
base:
	docker build -t aaltoscienceit/notebook-server-base . -f Dockerfile.base
standard:
	false
	docker build -t aaltoscienceit/notebook-server-standard:0.4.0 . -f Dockerfile.standard
r:
	docker build -t aaltoscienceit/notebook-server-r:0.4.0 --pull=false . -f Dockerfile.r
r-ubuntu:
	docker build -t aaltoscienceit/notebook-server-r-ubuntu:0.4.0 --pull=false . -f Dockerfile.r-ubuntu

