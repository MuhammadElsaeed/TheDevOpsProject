apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-backend-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "${repo}"
    targetRevision: "${revision}"
    path: "${path}"
    helm:
      valueFiles:
        - values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
