# FluxCD Demo

FluxCD demo repo which contains the following:
* Scripts for building a FluxCD lab in an AWS environment
* Sample configuration (HelmRelease, Helm Chart) to be used in a Flux configuration git repo

## Lab Build

Provisions a new VPC & EKS based k8s cluster (EKS control plane & 2 EC2 worker nodes). Deploys Helm/tiller and then FluxCD and Nginx ingress controller (as Helm charts). Provisions AWS CodePipeline & CodeBuild resources via terraform as a sample CI Docker build pipeline.

### Pre-reqs

Running a MacOS or Linux client (you can use a virtual machine if not). Ensure the following CLI's are installed:
* Flux CLI: [fluxctl](https://docs.fluxcd.io/en/stable/references/fluxctl.html) 
* Helm CLI (v2.x): [helm](https://github.com/helm/helm/releases/tag/v2.15.2)
* Kubernetes CLI: [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* EKS CLI: [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
* Terraform CLI: [terraform](https://www.terraform.io/downloads.html)
* AWS CLI: [aws](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html)
* Git CLI: [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Make your AWS credentials available to the shell session, either via named profiles or environment variables: [more info](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)

### Build Steps
1) Ensure the pre-req's above have been met
2) Fork the following two Github repo's into your own account: Flux config repo: [here](https://github.com/michaelprice232/flux-config-repo) & sample app repo [here](https://github.com/michaelprice232/flux-app-repo)
3) Generate a personal access token in your Github account with only `public_repo` permissions. This will be used by AWS CodePipeline to clone the sample app repo in order to build the Docker images as part of the sample CI pipeline: [here](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line)
4) Clone the forked flux config repo from above into a local directory 
5) Rename `./terraform/terraform.tfvars.sample` to `./terraform/terraform.tfvars`. Update all the values in the file with your respective Github details. See `./terraform/variables.tf` for more info
6) Update `deploy-cluster.sh` with your details (under 'Update variables here')
7) Whilst in the root of the flux repo cloned directory, open a bash shell and run `./deploy-cluster.sh`. Wait for all the resoures to be provisioned
8) Push a new commit to the flux config repo to update the Docker image tag to the one which should have been created by CodePipeline and pushed to ECR. Value [here](https://github.com/michaelprice232/flux-config-repo/blob/master/helm-releases/myapp-sandbox.yaml#L23). Also update the DNS name of the ingress controller to the one created by the k8s ingress controller. Update the line [here](https://github.com/michaelprice232/flux-config-repo/blob/master/helm-releases/myapp-sandbox.yaml#L28). You can use `kubectl -n kube-system get svc` to find the DNS name
9) Add the public OpenSSH key `./keys/flux.pub` as a deploy key in the forked flux config repo. Ensure it has `read and write` permissions. This is so Flux has query as well as push commits/tags to it

### Cleanup
Whilst in the root of the directory in a bash shell run: `./scripts/cleanup.sh` to delete all the AWS resources and save money!


### Suggested Actions
Once the above setup is running you can run various commands:
`helm ls` - see what helm charts are running.
`fluxctl list-workloads` - list any running flux workloads.
`kubectl -n flux get pods` - list all the flux related pods.

See official walk-through: [here](https://github.com/fluxcd/flux/blob/master/docs/tutorials/get-started-helm.md)


## Issues
Known issue with version `0.10.1` of `eksctl` in relation to provisioning load balancers via k8 services. Upgrade to `0.10.2` or above
https://github.com/weaveworks/eksctl/pull/1585