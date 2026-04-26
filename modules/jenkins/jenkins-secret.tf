resource "kubernetes_secret" "jenkins_credentials" {
  metadata {
    name      = "jenkins-github-secret"
    namespace = "jenkins"
  }

  data = {
    github_user     = base64encode(var.github_user)
    github_pat      = base64encode(var.github_pat)
    github_repo_url = base64encode(var.github_repo_url)
  }

  type = "Opaque"
}
