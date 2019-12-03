#!/bin/bash

# Script to:
# - Create a new VPC, with public & private subnets via eksctl
# - Deploy EKS cluster (inc. workers) via eksctl
# - Deploy Tiller (Helm)
# - Deploy nginx ingress controller via Helm
# - Deploy Flux & Helm operator via Helm
# - Deploy terraform resources for simple app CI pipeline (builds Docker images & pushes to ECR)

set -e

# Update variables here
REGION='eu-west-2'
GIT_REPO_SSH='git@github.com:michaelprice232/flux-config-repo.git'
OWNER='mikeprice'

bash ./scripts/deploy-eks-cluster.sh "${REGION}" "${OWNER}"
bash ./scripts/install-tiller.sh
bash ./scripts/deploy-nginx-ingress-controller.sh
bash ./scripts/deploy-flux.sh "${GIT_REPO_SSH}"
bash ./scripts/create-app-build-ci-pipeline.sh
