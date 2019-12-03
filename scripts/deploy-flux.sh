#!/bin/bash

set -e

# Script to install Flux & Helm Operator using Helm

# Pre-reqs
# 1) Helm is installed and configured (locally & in the target cluster)
# 2) kubectl is configured locally, with required RBAC permissions over the K8s cluster

# Parmameters
# 1 - SSH URL to the Flux config git repo e.g git@github.com:michaelprice232/flux-config-repo.git

# Assign the Flux git config repo (SSH only)
GITREPO=${1:?"Error: <GITREPO> parameter has not been passed. Usage: $0 <GITREPO>"}


# Generate a new OpenSSH keypair that Flux will use to read/write to config git repo
printf "\n> Generating a new OpenSSH keypair that Flux will use to read/write to config git repo\n"
if ! ssh-keygen -b 4096 -t rsa -C "Flux Operator" -N "" -f ./keys/flux; then
  printf "\nError: unable to generate OpenSSH keys...\n"
  exit 1
fi
# Assign the path to the OpenSSH private key
SSH_PRIVATE_KEY_PATH="./keys/flux"

# Dump out the variables
printf "\nGITREPO=${GITREPO}"
printf "SSH_PRIVATE_KEY_PATH=${SSH_PRIVATE_KEY_PATH}\n"


# Create flux namespace (if it doesn't already exist)
kubectl create namespace flux || true

# Create k8s secret based on the SSH private key
kubectl --namespace flux delete secret flux-git-deploy || true
kubectl --namespace flux create secret generic flux-git-deploy --from-file=identity="${SSH_PRIVATE_KEY_PATH}" || true

# Add flux repo to helm
printf "\n> Adding flux repo\n"
helm repo add fluxcd https://charts.fluxcd.io

# Add CRD's beforehand to allow them to apply in the K8s API server, before rolling out the helm operator
printf "\n> Apply CRD's\n"
kubectl apply -f https://raw.githubusercontent.com/fluxcd/flux/helm-0.10.1/deploy-helm/flux-helm-release-crd.yaml
sleep 2   # allow these to apply to the k8s API server

# Install flux chart
printf "\n> Install FluxCD chart\n"
if ! helm install --name "fluxcd" --namespace "flux" --wait \
--set helmOperator.create=true \
--set helmOperator.createCRD=false \
--set git.url="${GITREPO}" \
--set git.secretName="flux-git-deploy" \
--set git.user="flux.operator" \
--set git.email="flux.operator@weaveworks.com" \
--set git.pollInterval="15s" \
--set helmOperator.chartsSyncInterval="15s" \
--set registry.automationInterval="15s" \
--set helmOperator.allowNamespace="default" \
fluxcd/flux; then
  printf "\nError: Failed to deploy Helm chart 'fluxcd'\n"
  exit 1
fi

printf "\nINFO: You MUST upload the ./keys/flux.pub key as a DEPLOY KEY with read AND write permissions at ${GITREPO}"
printf "INFO: Flux will not be able to read/write config until you do so...\n"