Memorystore (Redis) Terraform module

Usage:

```hcl
module "redis" {
  source        = "../../modules/redis"
  enabled       = false
  project       = var.project
  region        = var.region
  instance_id   = "my-redis"
}
```

Notes:

- This module is disabled by default. Set `enabled = true` to create resources.
- For private connectivity, set `authorized_network` to VPC self_link and ensure private services access is configured.
