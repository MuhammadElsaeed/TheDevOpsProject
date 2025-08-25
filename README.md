# TheDevOpsProject

[![LICENSE](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Monorepo scaffold for a full DevOps demo on Google Cloud: Terraform, GKE, GitOps, CI/CD, observability, and logging.

## Table of Contents

- [Quick start](#quick-start)
- [Project layout](#project-layout)
- [Stage 1 — Foundation (status)](#stage-1---foundation-status)
- [Branching & workflow](#branching--workflow)
- [Next steps](#next-steps)

## Quick start

1. Authenticate and select your GCP project:

```bash
gcloud auth login
gcloud config set project thedevopsproject
```

2. Bootstrap Terraform backend and enable APIs:

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

## Project layout

- `infra/terraform/` — Terraform code and modules; `envs/dev` and `envs/prod` contain per-environment configs.
- `apps/` — sample application source (backend + frontend).
- `cicd/` — GitHub Actions and CI helpers.
- `k8s/` — Kubernetes manifests and Helm charts for GitOps.
- `docs/` — runbooks, security checklist, and stage runbooks.

## Stage 1 — Foundation (status)

- Terraform state bucket: `thedevopsproject-terraform-state` — created
- Dev GKE cluster: created (zonal, cost-conscious node pool)
- Workload Identity: planned (bindings still to configure)

## Branching & workflow

Recommended flow:

- `main` — protected production branch.
- `dev` — integration branch for day-to-day work (we commit here first).
- `feature/*` — short-lived feature branches merged into `dev`.

Notes:

- Terraform environments are separated by backend (env dirs) not branches. CI should run `terraform plan` on PRs and `apply` on merges to `dev`/`main` with approvals.

## Next steps

- Configure Workload Identity bindings for GKE.
- Implement Stage 2: Cloud SQL (Postgres) and Memorystore (Redis) modules.
- Add CI workflows to run `terraform plan` on PRs and gated `apply` for `dev` and `main`.

---

See `docs/stage-1.md` and `docs/security-checklist.md` for more details.
- [Contribution & branching](#contribution--branching)
