terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Підключаємо модуль S3 та DynamoDB
#module "s3_backend" {
#  source      = "./modules/s3-backend"
#  bucket_name = "filimonov-serghei-terraform-state-bucket-afc2a520"
#  table_name  = "terraform-locks"
#}

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name           = "lesson-9-vpc"
}

# Підключаємо модуль ECR
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "l9-ecr"
  scan_on_push = true
}

# Підключаємо модуль EKS
module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"
  subnet_ids      = module.vpc.public_subnets
  instance_type   = "t3.medium"
  desired_size    = 2
  max_size        = 4
  min_size        = 1
}

locals {
  eks_cluster_name = module.eks.eks_cluster_name
}

data "aws_eks_cluster" "eks" {
  name       = local.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = local.eks_cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

# Підключаємо модуль Jenkins
module "jenkins" {
  source        = "./modules/jenkins"
  cluster_name = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  github_user     = var.github_user
  github_pat      = var.github_pat
  github_repo_url = var.github_repo_url

  providers    = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on    = [module.eks]
}

# Підключаємо модуль Argo CD
module "argo_cd" {
  source       = "./modules/argo_cd"
  namespace    = "argocd"
  chart_version = "5.46.4"
}
