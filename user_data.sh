#!/bin/bash
# Install Docker & add user to docker group
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl start docker 
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
# Install kubectl
