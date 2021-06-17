# docker-jenkins-slave

## Description


## Usage

* Configure environment variables :

```bash
export JENKINS_URL=http://jenkins:8080
export JENKINS_USER=mborne
# API TOKEN for user mborne (http://jenkins.localhost/user/mborne/configure)
export JENKINS_PASSWORD=secret
```

* Start slaves :

```bash
sudo -E docker-compose up --build --scale jenkins-slave=3
```

