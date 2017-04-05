create-machines:
	docker-machine create --driver virtualbox swarm-master
	docker-machine create --driver virtualbox swarm-worker-1
	docker-machine create --driver virtualbox swarm-worker-2
	docker-machine create --driver virtualbox swarm-worker-3

init-swarm:
	docker `docker-machine config swarm-master` swarm init --advertise-addr `docker-machine ip swarm-master`

join-workers:
	docker `docker-machine config swarm-worker-1` swarm join \
	--token $(shell docker `docker-machine config swarm-master` swarm join-token worker -q) \
	`docker-machine ip swarm-master`
	
	docker `docker-machine config swarm-worker-2` swarm join \
	--token $(shell docker `docker-machine config swarm-master` swarm join-token worker -q) \
	`docker-machine ip swarm-master`
	
	docker `docker-machine config swarm-worker-3` swarm join \
	--token $(shell docker `docker-machine config swarm-master` swarm join-token worker -q) \
	`docker-machine ip swarm-master`

check-nodes:
	docker `docker-machine config swarm-master` node ls


start-interface:
	docker `docker-machine config swarm-master` container run -it -p 8080:8080 \
	-v /var/run/docker.sock:/var/run/docker.sock  julienbreux/docker-swarm-gui:latest
