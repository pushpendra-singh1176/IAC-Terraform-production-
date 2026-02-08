#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1

echo "===== STARTING DOCKER-BASED AUTOMATION ====="

# 1. Update & Base Tools
apt-get update -y
apt-get install -y curl unzip git ca-certificates apt-transport-https gnupg

# 2. Docker Install
if ! command -v docker >/dev/null; then
  apt-get install -y docker.io
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ubuntu
fi

# 3. AWS CLI & Kubectl (EKS access ke liye)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y && unzip awscliv2.zip && ./aws/install
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

# ------------------ DOCKER CONTAINERS START ------------------

# 4. Jenkins Container (Port 8080)
echo "Starting Jenkins Container..."
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  --restart always \
  jenkins/jenkins:lts

# 5. SonarQube Container (Port 9000)
# SonarQube ko thoda zyada memory/limit chahiye hoti hai
sysctl -w vm.max_map_count=262144
echo "Starting SonarQube Container..."
docker run -d --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  --restart always \
  sonarqube:lts-community

# 6. ArgoCD (Ye hamesha K8s pe hi achha lagta hai)
# Agar ArgoCD bhi Docker pe chahiye toh 'argocd-util' use hota hai, 
# par standard practice use EKS pe hi chalane ki hai.
echo "Waiting for EKS to be ACTIVE for ArgoCD..."
while [ "$(aws eks describe-cluster --name prod-eks --region us-east-1 --query 'cluster.status' --output text 2>/dev/null)" != "ACTIVE" ]; do
  sleep 30
done

aws eks update-kubeconfig --region us-east-1 --name prod-eks
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "===== SETUP COMPLETED ====="