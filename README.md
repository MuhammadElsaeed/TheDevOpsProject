TheDevOpsProject
=================

Overview
--------
This repository is a monorepo scaffold for a complete DevOps project targeting Google Cloud Platform (GCP). It will contain infrastructure-as-code (Terraform), a sample microservices application (Node.js API + React front-end), CI/CD (GitHub Actions), GitOps deployment (Argo CD + Kubernetes manifests / Helm), monitoring (Prometheus/Grafana/OpenTelemetry), and logging (ELK) — all implemented as code with security and best practices in mind.

High-level goals
----------------
- Fully automated provisioning of cloud resources with Terraform.
- Containerized sample app (backend + frontend) using Docker.
- GitHub Actions pipelines to build, test, lint, and push images to Artifact Registry.
- GitOps deployments using Argo CD to sync manifests from this repo.
- Observability: Prometheus, Grafana, OpenTelemetry.
- Logging: ELK stack on GKE.
- Emphasis on security: IAM least privilege, Workload Identity, secrets management, encryption, CIS guidance.

Repository layout (initial empty folders)
-----------------------------------------
- `infra/terraform/` - Terraform code and modules. Separate `envs/dev` and `envs/prod`.
  - `modules/` - reusable Terraform modules (gke, network, sql, redis, argocd, monitoring, logging).
- `apps/` - sample application code
  - `backend/` - Node.js API service
  - `frontend/` - React frontend
- `cicd/` - GitHub Actions workflows, reusable actions, security scans
- `k8s/` - Kubernetes manifests and Helm charts
  - `manifests/` - plain YAML used by Argo CD
  - `helm-charts/` - local charts (if needed)
- `argocd/` - Argo CD application manifests
- `monitoring/` - helmfile / helm chart configs for Prometheus/Grafana/OpenTelemetry
- `logging/elk` - manifests/helm for Elasticsearch, Kibana, Fluentd
- `docs/` - design notes, security checklist, runbooks, dashboards definitions
- `README.md` - this file (you are here)

Five stages (high-level)
------------------------
We'll split implementation into 5 stages. Each stage will be implemented end-to-end before moving to the next.

Stage 1 — Foundation (completed)
- Goals:
  - Create Terraform scaffolding and remote state in a secured GCS bucket.
  - Create a VPC, subnets (private where possible), and firewall rules.
  - Create a minimal GKE cluster (cost-conscious: small machine types, spot/preemptible nodes for non-critical pools).
  - Create service accounts with minimal IAM roles for Terraform, GKE, and CI.
  - Enable required GCP APIs and set organization/folder-level policies where applicable.
- Deliverables (completed):
  - `infra/terraform/envs/{dev,prod}` containing backend config and environment variables.
  - `infra/terraform/modules` with initial skeletons for `network`, `gke`, `iam`, `backend-services`.
  - A secure GCS bucket for Terraform state (`thedevopsproject-terraform-state`) with uniform bucket-level access and versioning. Bootstrap applied successfully.
- Security & hardening:
  - Use Workload Identity for GKE service accounts.
  - Enforce private clusters and private nodes where possible.
  - Restrict public IPs; use Cloud NAT for egress if needed.
  - Ensure Terraform state is encrypted and access-limited.
- Acceptance criteria / quality gates:
  - Terraform plan/apply succeeds for `dev` with minimal resources. (Done)
  # TheDevOpsProject

  > Monorepo scaffold for a full DevOps demo on Google Cloud (Terraform, GKE, GitOps, CI/CD, observability, logging).

  ## Quick summary

  - Terraform-based IaC for GCP (remote state in GCS).
  - Minimal private GKE clusters for `dev` and `prod`.
  - GitHub Actions for CI (Terraform checks scaffolded).
  - GitOps (Argo CD) and monitoring/logging planned for later stages.

  ## Quick start
## Table of Contents

- [Quick summary](#quick-summary)
- [Quick start](#quick-start)
- [Project layout (high level)](#project-layout-high-level)
- [Stages (overview)](#stages-overview)
- [Status — Stage 1](#status--stage-1)
- [Contribution & branching](#contribution--branching)
- [Next steps](#next-steps)


  1. Ensure you have gcloud authenticated and the project set:

  ```bash
  gcloud auth login
  gcloud config set project thedevopsproject
  ```

  2. Bootstrap Terraform backend and providers:

  ```bash
  cd infra/terraform/bootstrap
  terraform init
  terraform plan -var 'project=thedevopsproject' -var 'region=europe-west4' -out=bootstrap-plan.tfplan
  terraform apply "bootstrap-plan.tfplan"
  ```

  3. Provision dev environment (example):

  ```bash
  cd ../envs/dev
  terraform init
  terraform apply -var-file=dev.tfvars
  ```

  ## Project layout (high level)

  - `infra/terraform/` — Terraform code and modules; `envs/dev` and `envs/prod` contain per-environment configs.
  - `apps/` — sample application source (backend + frontend).
  - `cicd/` — GitHub Actions and CI helpers.
  - `k8s/` — Kubernetes manifests and Helm charts for GitOps.
  - `docs/` — runbooks, security checklist, and stage runbooks.

  ## Stages (overview)

  We implement the project in five stages. Stage 1 (Foundation) is completed in this repo and includes:

  - Terraform bootstrap (GCS state bucket created).
  - `network`, `gke`, and `iam` module skeletons.
  - `envs/dev` and `envs/prod` configs.

  Later stages will add Cloud SQL/Redis, the sample app and CI/CD pipelines, Argo CD GitOps configuration, and observability/logging stacks.

  ## Status — Stage 1

  - Terraform state bucket: thedevopsproject-terraform-state — created
  - Dev GKE cluster: created (zonal, cost-conscious node pool)
  - Workload Identity: planned (bindings still to configure)

  ## Contribution & branching

  Recommended flow:

  - `main` — protected production branch.
  - `dev` — integration branch where feature branches are merged and applied to `envs/dev`.
  - `feature/*` — short lived feature branches.

  Terraform environments are separated by backend (env dirs) rather than by git branches.

  ## Next steps

  - Configure Workload Identity bindings for GKE.
  - Implement Stage 2: Cloud SQL and Memorystore modules.
  - Add CI workflows to run `terraform plan` on PRs and `apply` on merges with appropriate approvals.

  ---

  For details, see `docs/stage-1.md` and `docs/security-checklist.md`.
