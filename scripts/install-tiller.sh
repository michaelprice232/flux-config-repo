#!/bin/bash

# Script to install tiller, the server side component of helm

set -e

# Create service account for tiller
printf "\n> Create service account for tiller\n"
kubectl -n kube-system create serviceaccount tiller || true

# Assign service account to default cluster-admin ClusterRole. Grants access to the RBAC enabled cluster
printf "\n> Assign service account to default cluster-admin ClusterRole. Grants access to the RBAC enabled cluster\n"
kubectl create clusterrolebinding tiller-cluster-rule \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller || true

# Initialise the tiller deployment
printf "\n> Initialise the tiller deployment\n"
if ! helm init --service-account tiller --history-max 10 --wait;
then
  printf "\nError: Unable to initialise Tiller\n"
  exit 1
fi