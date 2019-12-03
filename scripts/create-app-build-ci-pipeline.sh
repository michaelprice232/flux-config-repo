#!/bin/bash

# Script to apply terraform to create the AWS CodePipeline/CodeBuild resources for the application CI

set -e

cd ./terraform

if terraform init; then
  if ! terraform apply -auto-approve; then
    printf "\nError: Did not apply terrform succesfully\n"
    exit 1
  else
    printf "\nTerraform applied succesfully\n"
  fi
else
  printf "\nError: Failed to initialise terraform\n"
  exit 1
fi