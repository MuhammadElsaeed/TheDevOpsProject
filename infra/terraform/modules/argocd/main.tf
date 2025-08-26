data "external" "gcloud_token" {
  program = ["${path.module}/get_gcloud_token.sh"]
}

locals {
  effective_token = var.kube_token != "" ? var.kube_token : data.external.gcloud_token.result.token
}

provider "kubernetes" {
  host = var.cluster_endpoint
  token = local.effective_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
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
  version    = "5.39.7" # pinned example

  values = [file("${path.module}/values.yaml")]

  depends_on = [kubernetes_namespace.argocd]
}

# Deploy ArgoCD Application CRs for backend and frontend (dev)
resource "kubernetes_manifest" "argocd_app_backend" {
  manifest = yamldecode(file("${path.module}/../../../../apps/backend/argocd/application-dev.yaml"))
  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "argocd_app_frontend" {
  manifest = yamldecode(file("${path.module}/../../../../apps/frontend/argocd/application-dev.yaml"))
  depends_on = [helm_release.argocd]
}
