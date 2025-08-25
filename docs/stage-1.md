# Stage 1 — Foundation Runbook

This runbook documents how we provision the foundational infrastructure for the project and how to verify it.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Bootstrap: backend bucket & APIs](#bootstrap-backend-bucket--apis)
- [Provision dev environment](#provision-dev-environment)
- [Verification](#verification)
- [Security & hardening notes](#security--hardening-notes)
- [CI notes](#ci-notes)
- [Rollback](#rollback)

## Prerequisites

- gcloud authenticated and set to project `thedevopsproject`:

```bash
gcloud auth login
gcloud config set project thedevopsproject
```

- Terraform 1.0+

## Bootstrap: backend bucket & APIs

1. Configure the backend GCS bucket (bootstrap can create it for you) and optionally a KMS key.
2. Initialize and apply bootstrap:

```bash
cd infra/terraform/bootstrap
terraform init
terraform plan -var 'project=thedevopsproject' -var 'region=europe-west4' -var 'bucket_name=thedevopsproject-terraform-state' -out=bootstrap-plan.tfplan
terraform apply "bootstrap-plan.tfplan"
```

## Provision dev environment

After bootstrap completes, run:

```bash
cd ../envs/dev
terraform init
terraform apply -var-file=dev.tfvars
```

### Verification

- Check the Terraform state bucket and its metadata:

```bash
gsutil ls -L gs://thedevopsproject-terraform-state
```

- Get kubeconfig and check nodes (zonal example):

```bash
gcloud container clusters get-credentials thedevops-dev-gke --zone europe-west4-a --project thedevopsproject
kubectl get nodes
```

## Security & hardening notes

- Use least-privilege service accounts and prefer Workload Identity for GKE workloads.
- Enable uniform bucket-level access and versioning for the Terraform state bucket.
- Databases and Redis should use private IPs (Stage 2).
- Consider CMEK for Terraform state via Cloud KMS (bootstrap supports optional KMS creation).

## CI notes

- GitHub Actions runners should use short-lived credentials or Workload Identity federation instead of long-lived service account keys.

## Rollback

- To destroy dev resources:

```bash
cd infra/terraform/envs/dev
terraform destroy -var 'project=thedevopsproject'
```
