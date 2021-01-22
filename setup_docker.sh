#!/bin/sh

sudo yum update -y
sudo amazon-linux-extras install docker
sudo yum install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info
docker run --name firstapptest -d -p 80:5000 russboshep/myfirstapp