terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================
# 变量定义
# ============================================

variable "aws_region" {
  description = "AWS 区域"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "项目名称"
  type        = string
  default     = "bee-edu-rag-app"
}

variable "openai_api_key" {
  description = "OpenAI API 密钥"
  type        = string
  sensitive   = true
}

variable "github_org_or_user" {
  description = "GitHub 组织或用户名"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub 仓库名称"
  type        = string
}

variable "manage_apprunner_via_terraform" {
  description = "是否通过 Terraform 管理 App Runner 服务"
  type        = bool
  default     = false
}

# ============================================
# ECR 仓库 - 存储 Docker 镜像
# ============================================

resource "aws_ecr_repository" "app" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.project_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ECR 生命周期策略 - 自动清理旧镜像
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "保留最近 10 个镜像"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================
# Secrets Manager - 存储敏感信息
# ============================================

resource "aws_secretsmanager_secret" "openai_api_key" {
  name                    = "${var.project_name}-openai-api-key"
  description             = "OpenAI API 密钥"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-openai-api-key"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "openai_api_key" {
  secret_id     = aws_secretsmanager_secret.openai_api_key.id
  secret_string = var.openai_api_key
}

# ============================================
# IAM 角色 - App Runner 访问角色
# ============================================

# App Runner 访问角色（用于拉取 ECR 镜像）
resource "aws_iam_role" "apprunner_access_role" {
  name = "${var.project_name}-apprunner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-apprunner-access-role"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 附加 ECR 只读策略
resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# ============================================
# IAM 角色 - App Runner 实例角色
# ============================================

# App Runner 实例角色（应用运行时使用）
resource "aws_iam_role" "apprunner_instance_role" {
  name = "${var.project_name}-apprunner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-apprunner-instance-role"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 允许读取 Secrets Manager
resource "aws_iam_role_policy" "apprunner_secrets_access" {
  name = "secrets-access"
  role = aws_iam_role.apprunner_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.openai_api_key.arn
      }
    ]
  })
}

# ============================================
# IAM 角色 - GitHub Actions 部署角色
# ============================================

# 获取当前 AWS 账户 ID
data "aws_caller_identity" "current" {}

# GitHub OIDC Provider（如果不存在则创建）
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "github-actions-oidc"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# GitHub Actions 部署角色
resource "aws_iam_role" "github_actions_role" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org_or_user}/${var.github_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-role"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# GitHub Actions 部署权限
resource "aws_iam_role_policy" "github_actions_policy" {
  name = "deployment-permissions"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR 权限
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      # App Runner 权限
      {
        Effect = "Allow"
        Action = [
          "apprunner:DescribeService",
          "apprunner:UpdateService",
          "apprunner:ListServices"
        ]
        Resource = "*"
      },
      # IAM PassRole 权限
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.apprunner_access_role.arn,
          aws_iam_role.apprunner_instance_role.arn
        ]
      }
    ]
  })
}

# ============================================
# App Runner 服务（可选）
# ============================================

resource "aws_apprunner_service" "app" {
  count        = var.manage_apprunner_via_terraform ? 1 : 0
  service_name = "${var.project_name}-service"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8080"
        runtime_environment_secrets = {
          OPENAI_API_KEY = aws_secretsmanager_secret.openai_api_key.arn
        }
      }
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access_role.arn
    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = "1024"  # 1 vCPU
    memory            = "2048"  # 2 GB
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  tags = {
    Name        = "${var.project_name}-service"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ============================================
# 输出信息
# ============================================

output "ecr_repository_url" {
  description = "ECR 仓库 URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR 仓库名称"
  value       = aws_ecr_repository.app.name
}

output "apprunner_access_role_arn" {
  description = "App Runner 访问角色 ARN"
  value       = aws_iam_role.apprunner_access_role.arn
}

output "apprunner_instance_role_arn" {
  description = "App Runner 实例角色 ARN"
  value       = aws_iam_role.apprunner_instance_role.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions 部署角色 ARN"
  value       = aws_iam_role.github_actions_role.arn
}

output "apprunner_service_arn" {
  description = "App Runner 服务 ARN"
  value       = var.manage_apprunner_via_terraform ? aws_apprunner_service.app[0].arn : "未创建（需要设置 manage_apprunner_via_terraform=true）"
}

output "apprunner_service_url" {
  description = "App Runner 服务 URL"
  value       = var.manage_apprunner_via_terraform ? "https://${aws_apprunner_service.app[0].service_url}" : "未创建"
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager 密钥 ARN"
  value       = aws_secretsmanager_secret.openai_api_key.arn
}

output "deployment_instructions" {
  description = "部署说明"
  value       = <<-EOT
    ✅ Terraform 配置已应用！

    📝 接下来的步骤：

    1. 配置 GitHub Secrets（在仓库设置中添加）：
       - AWS_REGION: ${var.aws_region}
       - ECR_REPOSITORY: ${aws_ecr_repository.app.name}
       - APP_RUNNER_ARN: ${var.manage_apprunner_via_terraform ? aws_apprunner_service.app[0].arn : "需要手动创建 App Runner 服务"}
       - AWS_IAM_ROLE_TO_ASSUME: ${aws_iam_role.github_actions_role.arn}

    2. 推送代码到 main 分支触发 CI/CD：
       git add .
       git commit -m "Initial commit"
       git push origin main

    3. 查看部署状态：
       - GitHub Actions: https://github.com/${var.github_org_or_user}/${var.github_repo_name}/actions
       - AWS App Runner: https://console.aws.amazon.com/apprunner/

    4. 访问应用：
       ${var.manage_apprunner_via_terraform ? "https://${aws_apprunner_service.app[0].service_url}" : "等待 CI/CD 完成后查看 App Runner 控制台"}
  EOT
}

