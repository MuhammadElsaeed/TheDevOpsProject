data "external" "gcloud_token" {
  program = ["${path.module}/get_gcloud_token.sh"]
}

locals {
  effective_token = var.kube_token != "" ? var.kube_token : data.external.gcloud_token.result.token
}

provider "kubernetes" {
  # GKE cluster endpoint sometimes comes back without a scheme (just an IP).
  # Ensure the host is a valid URL by prefixing with https:// when missing.
  host = startswith(var.cluster_endpoint, "https://") ? var.cluster_endpoint : "https://${var.cluster_endpoint}"
  token = local.effective_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = startswith(var.cluster_endpoint, "https://") ? var.cluster_endpoint : "https://${var.cluster_endpoint}"
    token                  = local.effective_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  # version intentionally left unset so the provider can resolve a compatible chart

  values = [file("${path.module}/values.yaml")]

  depends_on = [kubernetes_namespace.argocd]
}

# Deploy ArgoCD Application CRs for backend and frontend (dev)
resource "kubernetes_manifest" "argocd_app_backend" {
  count = var.create_applications ? 1 : 0
  manifest = yamldecode(file("${path.module}/../../../../apps/backend/argocd/application-dev.yaml"))
  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "argocd_app_frontend" {
  count = var.create_applications ? 1 : 0
  manifest = yamldecode(file("${path.module}/../../../../apps/frontend/argocd/application-dev.yaml"))
  depends_on = [helm_release.argocd]
}
