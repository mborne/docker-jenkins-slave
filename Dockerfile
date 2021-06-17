FROM jenkins/slave:latest

ENV JENKINS_URL=http://jenkins:8080
ENV JENKINS_USERNAME=admin
ENV JENKINS_PASSWORD=secret
ENV NUM_EXECUTORS=1
ENV DOCKER_URL=unix:///var/run/docker.sock

#-----------------------------------------------------
# docker-ce-cli and gosu
#-----------------------------------------------------
USER root
RUN apt-get update \
 && apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl gnupg2 software-properties-common \
      gosu \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli \
 && apt-get clean

COPY start.sh /start.sh
CMD ["/bin/bash","/start.sh"]
