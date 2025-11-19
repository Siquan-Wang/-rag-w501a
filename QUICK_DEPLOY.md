# ⚡ 快速部署指令清单

复制粘贴即可快速完成部署！

## 🔧 前置准备

### 安装 AWS CLI（Windows）

```powershell
# 使用 Chocolatey
choco install awscli

# 或下载安装器
# https://awscli.amazonaws.com/AWSCLIV2.msi
```

### 安装 Terraform（Windows）

```powershell
# 使用 Chocolatey
choco install terraform

# 或下载 zip
# https://www.terraform.io/downloads
```

---

## 📝 第一步：配置 AWS

```bash
# 配置 AWS 凭证
aws configure
# 输入：
# AWS Access Key ID: 你的AccessKey
# AWS Secret Access Key: 你的SecretKey
# Default region name: us-east-1
# Default output format: json

# 验证
aws sts get-caller-identity
```

---

## 🗂️ 第二步：准备项目

```bash
# 进入项目目录
cd C:\Users\ephem\Desktop\RAG_w501a

# 初始化 Git
git init
git add .
git commit -m "Initial commit"
```

---

## 🌐 第三步：创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名：`rag-w501a`
3. 选择 Public 或 Private
4. ❌ 不要勾选任何初始化选项
5. 创建仓库

```bash
# 推送代码（替换你的用户名）
git remote add origin https://github.com/你的用户名/rag-w501a.git
git branch -M main
git push -u origin main
```

---

## ☁️ 第四步：部署到 AWS

### 创建 terraform.tfvars

```powershell
# Windows PowerShell - 一键创建配置文件
@"
openai_api_key           = "sk-你的OpenAI-Key"
github_org_or_user       = "你的GitHub用户名"
github_repo_name         = "rag-w501a"
aws_region               = "us-east-1"
manage_apprunner_via_terraform = true
"@ | Out-File -FilePath terraform.tfvars -Encoding utf8
```

### 运行 Terraform

```bash
# 初始化
terraform init

# 预览
terraform plan

# 部署（输入 yes 确认）
terraform apply

# 记录这些输出值！
terraform output ecr_repository_name
terraform output github_actions_role_arn
terraform output apprunner_service_arn
terraform output apprunner_service_url
```

---

## 🔑 第五步：配置 GitHub Secrets

前往：`https://github.com/你的用户名/rag-w501a/settings/secrets/actions`

点击 "New repository secret"，依次添加 4 个：

### Secret 1: AWS_REGION
```
Name: AWS_REGION
Secret: us-east-1
```

### Secret 2: ECR_REPOSITORY
```
Name: ECR_REPOSITORY
Secret: [从 terraform output 获取]
```

### Secret 3: APP_RUNNER_ARN
```
Name: APP_RUNNER_ARN
Secret: [从 terraform output 获取，格式：arn:aws:apprunner:...]
```

### Secret 4: AWS_IAM_ROLE_TO_ASSUME
```
Name: AWS_IAM_ROLE_TO_ASSUME
Secret: [从 terraform output 获取，格式：arn:aws:iam:...]
```

---

## 🚀 第六步：触发部署

```bash
# 触发部署
echo "" >> README.md
git add .
git commit -m "Trigger deployment"
git push origin main
```

---

## ✅ 第七步：验证部署

### 查看部署进度
访问：`https://github.com/你的用户名/rag-w501a/actions`

### 获取应用 URL
```bash
terraform output apprunner_service_url
```

### 测试 API
```bash
# 替换为你的实际 URL
curl https://你的apprunner-url/health

# 测试问答
curl -X POST https://你的apprunner-url/ask -H "Content-Type: application/json" -d "{\"question\": \"什么是 RAG？\"}"
```

---

## 📋 完整命令序列（复制粘贴版）

```bash
# 1. 配置 AWS
aws configure

# 2. 初始化项目
cd C:\Users\ephem\Desktop\RAG_w501a
git init
git add .
git commit -m "Initial commit"

# 3. 推送到 GitHub（先在 GitHub 创建仓库）
git remote add origin https://github.com/你的用户名/rag-w501a.git
git branch -M main
git push -u origin main

# 4. 创建 Terraform 配置（手动编辑 terraform.tfvars）
# 填入：openai_api_key, github_org_or_user, github_repo_name

# 5. 部署基础设施
terraform init
terraform plan
terraform apply

# 6. 记录输出
terraform output ecr_repository_name
terraform output github_actions_role_arn
terraform output apprunner_service_arn

# 7. 在 GitHub 添加 4 个 Secrets（手动操作）

# 8. 触发部署
git commit --allow-empty -m "Trigger deployment"
git push origin main

# 9. 获取应用 URL
terraform output apprunner_service_url
```

---

## 🎯 检查清单

- [ ] AWS CLI 已安装并配置
- [ ] Terraform 已安装
- [ ] GitHub 仓库已创建
- [ ] 代码已推送到 GitHub
- [ ] terraform.tfvars 已创建（包含 API Key）
- [ ] Terraform apply 成功
- [ ] 4 个 GitHub Secrets 已添加
- [ ] GitHub Actions 工作流运行成功
- [ ] 应用可以访问

---

## 💰 成本控制

### 查看预估成本
访问：https://console.aws.amazon.com/billing/

### 暂停服务
```bash
# 方法 1：从控制台暂停
# 访问 https://console.aws.amazon.com/apprunner/

# 方法 2：销毁所有资源
terraform destroy
```

---

## 🆘 常见错误快速修复

### 错误：Terraform authentication failed
```bash
aws configure
# 重新输入 Access Key
```

### 错误：GitHub Actions 权限错误
```
检查：
1. AWS_IAM_ROLE_TO_ASSUME 是否正确
2. GitHub 仓库名是否与 terraform.tfvars 中一致
```

### 错误：App Runner 启动失败
```bash
# 查看详细日志
aws apprunner describe-service --service-arn $(terraform output -raw apprunner_service_arn) --region us-east-1
```

---

**快速部署完成！🎉**

遇到问题？查看 `DEPLOYMENT_GUIDE.md` 获取详细说明。

