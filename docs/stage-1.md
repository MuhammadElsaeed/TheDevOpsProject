# Stage 1 — Foundation Runbook

This document describes the steps, security considerations, and commands to provision the initial foundation for the project.

Prerequisites
- gcloud authenticated and set to project `thedevopsproject`:

  gcloud config set project thedevopsproject

- Terraform 1.0+

High-level steps
1. Configure the backend GCS bucket and optionally a KMS key. The bootstrap Terraform in `infra/terraform/bootstrap` can create a bucket for you or you can create it manually and provide the name.
2. Run `terraform init` in `infra/terraform/bootstrap` to initialize backend and providers.
3. Plan and apply the bootstrap (creates the Terraform state bucket and enables required APIs):

  cd infra/terraform/bootstrap
  terraform plan -var 'project=thedevopsproject' -var 'region=europe-west4' -var 'bucket_name=thedevopsproject-terraform-state' -out=bootstrap-plan.tfplan
  terraform apply "bootstrap-plan.tfplan"

4. Initialize and plan the dev environment (after bootstrap completes):

  cd ../envs/dev
  terraform init
  terraform plan -var-file=dev.tfvars -out=dev-plan.tfplan

Verification after apply
------------------------

After a successful apply for `dev` the following checks help confirm the environment:

- Confirm Terraform state bucket exists and is versioned:

  gsutil ls -L gs://thedevopsproject-terraform-state

- Get kubeconfig for the cluster (zonal example):

  gcloud container clusters get-credentials thedevops-dev-gke --zone europe-west4-a --project thedevopsproject
  kubectl get nodes

- Workload Identity: configure IAM binding between Kubernetes service account and GCP service account (to be implemented in Stage 2). 

Security & hardening notes
- Use least-privilege service accounts for CI and Terraform. Prefer Workload Identity for GKE workloads.
- Enable uniform bucket-level access and versioning for the Terraform state bucket.
- Mark databases and Redis to use private IPs (to be implemented in Stage 2).
- Consider enabling CMEK for Terraform state via KMS (optional, configured in bootstrap variables).

CI notes
- GitHub Actions runners should use short-lived credentials or Workload Identity federation instead of long-lived service account keys.

Rollback
- To destroy dev resources: run `terraform destroy -var 'project=thedevopsproject'` in `infra/terraform/envs/dev`.
