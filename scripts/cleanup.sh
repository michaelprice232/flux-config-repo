#!/bin/bash
# Script to cleanup resources when finished

# Flux
helm delete --purge fluxcd
kubectl delete -f https://raw.githubusercontent.com/fluxcd/flux/helm-0.10.1/deploy-helm/flux-helm-release-crd.yaml
kubectl -n flux delete secret flux-git-deploy

# OpenSSH keys (deploy key)
rm ./keys/flux*

# Nginx Ingress
helm delete --purge ingress
sleep 60    # give time to delete load balancer as we cannot use --wait like with install

# Terraform / App build CI resources
aws s3 rm --recursive s3://flux-demo-app1-artifacts/flux-demo-app1-pipel    # as we cannot terraform destroy an empty bucket
cd terraform
terraform destroy -auto-approve

# Delete codebuild builds (terraform destroy does not remove CodeBuild build history)
aws --output json codebuild list-builds | jq -r .ids[] | xargs aws codebuild batch-delete-builds --ids

# EKS / k8s
# If there are any issues removing these components check Cloudformation for the two stacks
eksctl delete cluster --name demo