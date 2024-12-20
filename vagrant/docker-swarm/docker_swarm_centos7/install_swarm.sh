
#!/bin/bash
sudo yum -y update
sudo yum -y install epel-release

# ENABLE TOOLS
DOCKER=19.03 # supported value [ON, OFF, X.X]

# install docker
sudo yum install -y git
# Install docker
case $DOCKER in
  ON)
    echo "Only ON and OFF value supported"
    sudo curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
    sudo usermod -aG docker vagrant
    sudo systemctl enable docker
    sudo systemctl start docker
    ;;
  OFF)
    echo "skip docker installation"
    ;;
  *)
    echo "Only ON and OFF value supported"
    sudo curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh --version $DOCKER
    sudo usermod -aG docker vagrant
    sudo systemctl enable docker
    sudo systemctl start docker
    ;;
esac
sudo yum install -y sshpass

if [ $1 == "master" ]
then
        echo "###################################################"
        echo "Initialize docker swarm cluster"
        echo "###################################################"
        docker swarm init --advertise-addr $2
        echo "###################################################"
        echo "For this Stack, you will use $(ip -f inet addr show enp0s8 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p') IP Address"
        echo "###################################################"
else
        echo "###################################################"
        echo "Add worker to cluster"
        echo "###################################################"
        TOKEN=$( sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@${2} "docker swarm join-token -q worker" | tail -1)
        docker swarm join --token $TOKEN ${2}:2377
        echo "For this Stack, you will use $(ip -f inet addr show enp0s8 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p') IP Address"
fi
