FROM erlang:alpine

WORKDIR /home

RUN apk update && apk add bash

RUN wget -O rabbitmq.tar.xz https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.16/rabbitmq-server-generic-unix-3.7.16.tar.xz
RUN tar -xvJf rabbitmq.tar.xz -C /usr --strip-components 1

RUN rabbitmq-plugins list
RUN rabbitmq-plugins enable --offline \
  rabbitmq_mqtt \
  rabbitmq_stomp \
  rabbitmq_management \
  rabbitmq_management_agent \
  rabbitmq_federation \
  rabbitmq_federation_management

RUN addgroup rabbitmq
RUN adduser -DS -g "" -G rabbitmq -s /bin/sh -h /var/lib/rabbitmq rabbitmq

ADD rabbitmq.config /etc/rabbitmq/
ADD startrabbit.sh /opt/rabbit/
ADD wait-for-it.sh /opt/rabbit/

RUN chmod u+rw /etc/rabbitmq/rabbitmq.config \
&& mkdir -p /opt/rabbit \
&& mkdir -p /usr/var/log/rabbitmq \
&& chmod a+x /opt/rabbit/startrabbit.sh

CMD /opt/rabbit/startrabbit.sh
