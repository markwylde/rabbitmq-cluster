#!/bin/bash

echo $CLUSTER_SECRET > /var/lib/rabbitmq/.erlang.cookie
chmod 600 /var/lib/rabbitmq/.erlang.cookie

if [ -z "$CLUSTER_BOOTSTRAP" ]; then
  echo "Starting new RabbitMQ cluster"
  /usr/sbin/rabbitmq-server &

  /opt/rabbit/wait-for-it.sh -t 0 localhost:15672

  rabbitmqctl add_user $ADMIN_USERNAME $ADMIN_PASSWORD
  rabbitmqctl set_user_tags $ADMIN_USERNAME administrator
  rabbitmqctl set_permissions -p / $ADMIN_USERNAME ".*" ".*" ".*"

  rabbitmqctl delete_user guest

  tail -f /usr/var/log/rabbitmq/rabbit*.log
else
  echo "Starting new RabbitMQ node for cluster: $CLUSTER_BOOTSTRAP"

  /opt/rabbit/wait-for-it.sh -t 0 $CLUSTER_BOOTSTRAP:15672

  /usr/sbin/rabbitmq-server &
  /opt/rabbit/wait-for-it.sh -t 0 localhost:15672

  rabbitmqctl stop_app
  if [ -z "$RAM_NODE" ]; then
    echo "Joining cluster $CLUSTER_BOOTSTRAP"
    rabbitmqctl join_cluster rabbit@$CLUSTER_BOOTSTRAP
  else
    echo "Joining cluster as a RAM node $CLUSTER_BOOTSTRAP"
    rabbitmqctl join_cluster --ram rabbit@$CLUSTER_BOOTSTRAP
  fi
  rabbitmqctl start_app

  tail -f /usr/var/log/rabbitmq/rabbit*.log
fi
