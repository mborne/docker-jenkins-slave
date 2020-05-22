#!/bin/bash

#https://stackoverflow.com/a/56051519

#set -xe

NODE_NAME=docker-$HOSTNAME

echo "Downloading CLI jar from the master..."
#--user "${JENKINS_USERNAME}:${JENKINS_PASSWORD}"
curl -o /tmp/jenkins-cli.jar \
  ${JENKINS_URL}/jnlpJars/jenkins-cli.jar

# see http://jenkins.localhost/cli/?remoting=false
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

echo "Start JNLP agent..."
java -jar /usr/share/jenkins/agent.jar \
  -jnlpUrl ${JENKINS_URL}/computer/${NODE_NAME}/slave-agent.jnlp \
  -jnlpCredentials "${JENKINS_USERNAME}:${JENKINS_PASSWORD}" \
  -workDir "/home/jenkins"
