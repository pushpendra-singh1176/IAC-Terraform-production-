#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1

echo "===== START BOOTSTRAP ====="

# ------------------ BASE ------------------
apt update -y
apt install -y curl unzip git ca-certificates apt-transport-https gnupg

# ------------------ DOCKER ------------------
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | bash
  usermod -aG docker ubuntu
fi

# ------------------ AWS CLI ------------------
if ! command -v aws >/dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  unzip awscliv2.zip
  ./aws/install
fi

# ------------------ KUBECTL ------------------
if ! command -v kubectl >/dev/null; then
  curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv kubectl /usr/local/bin/
fi

# ------------------ HELM ------------------
if ! command -v helm >/dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# ------------------ CONNECT TO EKS ------------------
aws eks update-kubeconfig \
  --region us-south-1 \
  --name prod-eks

# ------------------ TRIVY ------------------
if ! command -v trivy >/dev/null; then
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
  mv bin/trivy /usr/local/bin/
fi

# ================== HELM INSTALLS ==================

# -------- ArgoCD --------
kubectl create namespace argocd || true

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd

# -------- Jenkins --------
kubectl create namespace jenkins || true

helm repo add jenkins https://charts.jenkins.io
helm repo update

helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins

# -------- SonarQube --------
kubectl create namespace sonarqube || true

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

helm upgrade --install sonarqube sonarqube/sonarqube \
  --namespace sonarqube

echo "===== BOOTSTRAP COMPLETED SUCCESSFULLY ====="