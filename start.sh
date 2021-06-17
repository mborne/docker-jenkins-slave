#!/bin/bash

NODE_NAME=docker-$HOSTNAME

#-----------------------------------------------------------------------
# Ensure that jenkins user is allowed to access /var/run/docker.sock
# https://github.com/jenkinsci/docker/issues/263#issuecomment-217955379
#-----------------------------------------------------------------------
if [ -S /var/run/docker.sock ]; then
    echo "Create docker group with gid corresponding to /var/run/docker.sock..."
    DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
    addgroup --gid=${DOCKER_GID} docker
    echo "Add jenkins to docker group..."
    usermod -a -G docker jenkins
fi

#-----------------------------------------------------------------------
# Register node throw jenkins API
# see http://jenkins.localhost/cli/?remoting=false
#-----------------------------------------------------------------------

echo "Downloading jenkins-cli.jar from ${JENKINS_URL}/jnlpJars/jenkins-cli.jar ..."
#--user "${JENKINS_USERNAME}:${JENKINS_PASSWORD}"
curl -o /tmp/jenkins-cli.jar \
  ${JENKINS_URL}/jnlpJars/jenkins-cli.jar

echo "Create node ${NODE_NAME}..."
cat <<EOF | java -jar /tmp/jenkins-cli.jar -auth "${JENKINS_USERNAME}:${JENKINS_PASSWORD}" create-node "${NODE_NAME}" |true
<slave>
  <name>${NODE_NAME}</name>
  <description></description>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>${NUM_EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label>docker</label>
  <nodeProperties/>
  <userId>${USER}</userId>
</slave>
EOF

#-----------------------------------------------------------------------
# Start node agent
#-----------------------------------------------------------------------
echo "Start JNLP agent..."
gosu jenkins java -jar /usr/share/jenkins/agent.jar \
  -jnlpUrl ${JENKINS_URL}/computer/${NODE_NAME}/slave-agent.jnlp \
  -jnlpCredentials "${JENKINS_USERNAME}:${JENKINS_PASSWORD}" \
  -workDir "/home/jenkins"
