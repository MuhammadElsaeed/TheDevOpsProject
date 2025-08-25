# Security checklist (foundation)

- Terraform state stored in GCS with uniform bucket-level access and versioning.
- Consider enabling CMEK for the state bucket (bootstrap supports optional KMS creation).
- Use least-privilege service accounts. Prefer Workload Identity for CI/GKE.
- Avoid committing secrets; use Secret Manager and CI secret stores.
- Enable audit logging in GCP and monitor access to the state bucket.
- Apply Kubernetes CIS Benchmarks and enable Pod Security Admission policies.
