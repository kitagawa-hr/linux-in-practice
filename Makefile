build: ./Dockerfile
	docker build -t linux-practice .

run:
	docker run --security-opt seccomp:unconfined \
		-it linux-practice  /bin/bash
