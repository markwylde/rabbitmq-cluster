# RabbitMQ Cluster
This project provides a docker image that can be easily
scaled using Docker Swarm or any orchestration engine
that uses the docker-compose format.

## Usage
### Setup docker
If you don't already have a swarm cluster, make one:

```bash
docker swarm init
```

### The Stack File
```yaml
version: "3.7"

services:
  rabbit-bootstrap:
    image: markwylde/rabbitmq-cluster
    hostname: rabbit-bootstrap
    environment:
      - ADMIN_USERNAME=myuser
      - ADMIN_PASSWORD=mypass
      - CLUSTER_SECRET=w89240tygiwuvb

  rabbit:
    image: markwylde/rabbitmq-cluster
    deploy:
      replicas: 2
    depends_on:
      - rabbit-bootstrap
    environment:
     - CLUSTER_BOOTSTRAP=rabbit-bootstrap
     - CLUSTER_SECRET=w89240tygiwuvb
     - RAM_NODE=true
    ports:
      - "5672:5672"
      - "15672:15672"
```

### Running Everything
Run the following command on your docker swarm host:
```
docker stack deploy -c docker-compose.yml rabbit
```

You should now be able to navigate to the admin UI.

http://192.168.99.100:15672/

### Scaling Nodes
You can now scale up to as many services as you want
at any time:

```bash
docker service scale rabbit_rabbit=5
```
