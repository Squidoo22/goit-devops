variable "name" {
  description = "Назва Helm-релізу"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія Argo CD чарта"
  type        = string
  default     = "5.46.4"
}

variable "github_user" {
  description = "GitHub username для доступу до репозиторію"
  type        = string
  sensitive   = true
}

variable "github_pat" {
  description = "GitHub Personal Access Token для доступу до репозиторію"
  type        = string
  sensitive   = true
}
