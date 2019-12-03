#!/bin/bash

set -e

# Simple wrapper script to call eksctl to provision an EKS cluster in AWS
# Creates the underlying VPC and then provisions EKS control plane and k8s workers via two Cloudformation stacks

REGION=${1:-eu-west-2}
OWNER=${2:?'Who is the owner of these resources, for AWS tagging purposes'}

printf "\nAWS Region selected: ${REGION}"

# Pre-requisites
# https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html

printf "\n> Deploying EKS cluster using eksctl...\n"
if ! eksctl create cluster \
--name demo \
--nodegroup-name workers \
--node-type t3.medium \
--nodes 2 \
--nodes-min 2 \
--nodes-max 2 \
--region "${REGION}" \
--node-volume-size 50 \
--node-labels "Environment=sandbox,Capability=k8s-cluster,Owner=${OWNER}" \
--tags "Name=sandbox-k8s,Environment=sandbox,Capability=k8s-cluster,Owner=${OWNER}";
then
  printf "\nError: Failed to deploy EKS cluster successfully\n"
  exit 1
fi