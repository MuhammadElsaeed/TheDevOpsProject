# Infra bootstrap and how-to

This folder contains Terraform scripts to bootstrap the project and environment stacks.

Quick bootstrap steps

1. Ensure you are authenticated with gcloud and set the project:

   gcloud auth login
   gcloud config set project thedevopsproject

2. Create the Terraform state bucket (optional: let bootstrap create it). We use `thedevopsproject-terraform-state` in examples.

3. Bootstrap (this will enable required APIs and create the state bucket if configured):

   cd infra/terraform/bootstrap
   terraform init
   terraform plan -var="project=thedevopsproject" -var="bucket_name=thedevopsproject-terraform-state" -var="region=europe-west4" -out=plan.tfplan
   terraform apply plan.tfplan

4. Initialize and plan the dev environment:

   cd ../envs/dev
   terraform init
   terraform plan -var-file=dev.tfvars -out=dev-plan.tfplan

Notes & security
- The bootstrap supports optional KMS (CMEK) to encrypt state. Default is disabled; enable by setting `create_kms = true`.
- Do not commit service account keys or secrets. Use Workload Identity or short-lived credentials.
- Review IAM bindings before applying to prod.
