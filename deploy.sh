#!/bin/bash

# RAG 应用部署脚本
# 用于快速部署到 AWS

set -e

echo "🚀 RAG 应用部署脚本"
echo "===================="

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查必需的工具
check_requirements() {
    echo -e "\n${YELLOW}检查必需工具...${NC}"
    
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform 未安装${NC}"
        echo "请访问: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI 未安装${NC}"
        echo "请访问: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安装${NC}"
        echo "请访问: https://www.docker.com/products/docker-desktop/"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 所有必需工具已安装${NC}"
}

# 检查环境变量
check_env_vars() {
    echo -e "\n${YELLOW}检查环境变量...${NC}"
    
    if [ -z "$TF_VAR_openai_api_key" ]; then
        echo -e "${RED}❌ 未设置 TF_VAR_openai_api_key${NC}"
        echo "请运行: export TF_VAR_openai_api_key=\"your-key\""
        exit 1
    fi
    
    if [ -z "$TF_VAR_github_org_or_user" ]; then
        echo -e "${RED}❌ 未设置 TF_VAR_github_org_or_user${NC}"
        echo "请运行: export TF_VAR_github_org_or_user=\"your-username\""
        exit 1
    fi
    
    if [ -z "$TF_VAR_github_repo_name" ]; then
        echo -e "${RED}❌ 未设置 TF_VAR_github_repo_name${NC}"
        echo "请运行: export TF_VAR_github_repo_name=\"your-repo\""
        exit 1
    fi
    
    echo -e "${GREEN}✅ 环境变量已设置${NC}"
}

# 初始化 Terraform
init_terraform() {
    echo -e "\n${YELLOW}初始化 Terraform...${NC}"
    terraform init
    echo -e "${GREEN}✅ Terraform 初始化完成${NC}"
}

# 创建基础设施（不包括 App Runner）
create_infrastructure() {
    echo -e "\n${YELLOW}创建 AWS 基础设施（ECR、IAM、Secrets）...${NC}"
    terraform apply -auto-approve -var="manage_apprunner_via_terraform=false"
    echo -e "${GREEN}✅ 基础设施创建完成${NC}"
}

# 构建并推送 Docker 镜像
build_and_push_image() {
    echo -e "\n${YELLOW}构建并推送 Docker 镜像...${NC}"
    
    # 获取 ECR 信息
    ECR_URL=$(terraform output -raw ecr_repository_url)
    AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
    
    echo "ECR URL: $ECR_URL"
    
    # 登录 ECR
    echo "登录到 ECR..."
    aws ecr get-login-password --region $AWS_REGION | \
        docker login --username AWS --password-stdin $ECR_URL
    
    # 构建镜像
    echo "构建 Docker 镜像..."
    docker build --platform linux/amd64 -t $ECR_URL:latest .
    
    # 推送镜像
    echo "推送镜像到 ECR..."
    docker push $ECR_URL:latest
    
    echo -e "${GREEN}✅ Docker 镜像已推送${NC}"
}

# 创建 App Runner 服务
create_apprunner() {
    echo -e "\n${YELLOW}创建 App Runner 服务...${NC}"
    terraform apply -auto-approve -var="manage_apprunner_via_terraform=true"
    echo -e "${GREEN}✅ App Runner 服务创建完成${NC}"
}

# 显示部署信息
show_deployment_info() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}🎉 部署完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "\n${YELLOW}📝 重要信息（请保存用于配置 GitHub Secrets）：${NC}\n"
    
    echo "AWS_REGION:"
    terraform output -raw aws_region 2>/dev/null || echo "us-east-1"
    
    echo -e "\nECR_REPOSITORY:"
    terraform output -raw ecr_repository_name
    
    echo -e "\nAWS_IAM_ROLE_TO_ASSUME:"
    terraform output -raw github_actions_role_arn
    
    echo -e "\nAPP_RUNNER_ARN:"
    terraform output -raw apprunner_service_arn
    
    echo -e "\n${YELLOW}🌐 应用 URL:${NC}"
    terraform output -raw apprunner_service_url
    
    echo -e "\n\n${YELLOW}📋 接下来的步骤：${NC}"
    echo "1. 在 GitHub 仓库设置中添加上述 Secrets"
    echo "2. 推送代码到 main 分支触发自动部署"
    echo "3. 访问应用 URL 测试功能"
}

# 主函数
main() {
    check_requirements
    check_env_vars
    init_terraform
    create_infrastructure
    build_and_push_image
    create_apprunner
    show_deployment_info
}

# 运行主函数
main

