variable "github_user" {
  description = "GitHub username for Jenkins integration"
  type        = string
  sensitive   = true
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL for Jenkins integration"
  type        = string
  sensitive   = true
}