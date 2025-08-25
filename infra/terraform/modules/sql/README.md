Cloud SQL (Postgres) Terraform module

Usage:

```hcl
module "sql" {
  source        = "../../modules/sql"
  enabled       = false
  project       = var.project
  region        = var.region
  instance_name = "my-postgres"
}
```

Notes:

- This module is disabled by default. Set `enabled = true` to create resources.
- For private IP, provide `private_network` (VPC self_link) and ensure private services access configured.
