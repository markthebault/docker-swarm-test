SWARM_WORKER=swarm-worker
SWARM_WORKER_COUNT=3

SWARM_MASTER=swarm-master
SWARM_MASTER_COUNT=3

all: create-machines init-swarm join-workers start-interface


create-machines:
	$(foreach number,$(shell seq 1 ${SWARM_MASTER_COUNT}),\
		docker-machine create --driver virtualbox ${SWARM_MASTER}-$(number) \
	;)
	$(foreach number,$(shell seq 1 ${SWARM_WORKER_COUNT}),\
		docker-machine create --driver virtualbox ${SWARM_WORKER}-$(number) \
	;)

test:
	$(if $(filter 1,1),\
		$(foreach number,$(shell seq 1 ${SWARM_MASTER_COUNT}),\
		echo toto\
		;)\
	)


init-swarm:
	docker `docker-machine config ${SWARM_MASTER}-1` swarm init --advertise-addr `docker-machine ip ${SWARM_MASTER}-1`
	$(if $(filter-out ${SWARM_MASTER_COUNT},1),\
		$(foreach number,$(shell seq 2 ${SWARM_MASTER_COUNT}),\
			docker `docker-machine config ${SWARM_MASTER}-${number}` swarm join \
				--token `docker-machine ssh ${SWARM_MASTER}-1 docker swarm join-token manager -q` \
				--advertise-addr `docker-machine ip ${SWARM_MASTER}-${number}` \
				`docker-machine ip ${SWARM_MASTER}-1` \
		;)\
	)

join-workers:
	$(foreach number,$(shell seq 1 ${SWARM_WORKER_COUNT}),\
		docker `docker-machine config ${SWARM_WORKER}-${number}` swarm join \
			--token `docker-machine ssh ${SWARM_MASTER}-1 docker swarm join-token worker -q` \
			--advertise-addr `docker-machine ip ${SWARM_WORKER}-${number}` \
			`docker-machine ip ${SWARM_MASTER}-1` \
	;)


check-nodes:
	docker `docker-machine config ${SWARM_MASTER}-1` node ls




leave-cluster-force:
	$(foreach number,$(shell seq 1 ${SWARM_MASTER_COUNT}),\
		docker `docker-machine config ${SWARM_MASTER}-${number}` swarm leave -f || true\
	;)
	$(foreach number,$(shell seq 1 ${SWARM_WORKER_COUNT}),\
		docker `docker-machine config ${SWARM_WORKER}-${number}` swarm leave -f || true\
	;)



start-interface:
	docker `docker-machine config ${SWARM_MASTER}-1` container run -it -p 8080:8080 \
	-v /var/run/docker.sock:/var/run/docker.sock  julienbreux/docker-swarm-gui:latest



clean:
	$(foreach number,$(shell seq 1 ${SWARM_MASTER_COUNT}),\
		docker-machine rm -y ${SWARM_MASTER}-$(number) \
	;)
	$(foreach number,$(shell seq 1 ${SWARM_WORKER_COUNT}),\
		docker-machine rm -y ${SWARM_WORKER}-$(number) \
	;)
