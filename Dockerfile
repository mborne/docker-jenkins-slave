FROM jenkins/slave:latest

ENV JENKINS_URL=http://jenkins:8080
ENV JENKINS_USERNAME=admin
ENV JENKINS_PASSWORD=secret
ENV NUM_EXECUTORS=1
ENV DOCKER_URL=unix:///var/run/docker.sock

USER root
RUN apt-get update \
 && apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update && apt-get install -y docker-ce-cli

RUN addgroup --gid=134 docker \
 && usermod -a -G docker jenkins

COPY start.sh /start.sh
USER jenkins
CMD ["/bin/bash","/start.sh"]
