#!/bin/bash

set -e

# Simple script to deploy an nginx ingress controller using Helm
# Pre-req - k8s cluster is deployed, Helm/tiller is deployed & your CLI credentials for kubectl are set
# https://github.com/helm/charts/tree/master/stable/nginx-ingress

printf "\n> Deploy ingress controller\n"
if ! helm install stable/nginx-ingress --namespace kube-system --name ingress --wait --timeout 900;
then
  printf "\nError: Problem deploying Helm chart: nginx-ingress\n"
  exit 1
fi