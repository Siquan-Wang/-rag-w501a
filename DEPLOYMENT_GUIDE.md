# 🚀 云端部署完整指南

本指南将带你一步步完成 RAG 应用的云端部署。

## 📋 部署前检查清单

在开始之前，请确保你已经：

- [ ] 注册了 AWS 账号（并升级到付费账户）
- [ ] 获得了 OpenAI API Key
- [ ] 有 GitHub 账号
- [ ] 在本机安装了以下工具：
  - [ ] AWS CLI
  - [ ] Terraform
  - [ ] Git
  - [ ] Docker Desktop（可选，用于本地测试）

---

## 第一步：AWS 账号配置

### 1.1 注册并升级 AWS 账号

1. 访问 [AWS 官网](https://aws.amazon.com/) 注册账号
2. 完成邮箱验证和信用卡绑定
3. 升级到付费账户：
   - 登录 [AWS 管理控制台](https://console.aws.amazon.com/)
   - 访问 [升级页面](https://console.aws.amazon.com/billing/home?#/freetier/upgrade)
   - 点击 "Upgrade account"

⚠️ **费用提醒**：App Runner 预计每天 $2-4，不用时记得销毁！

### 1.2 创建 IAM 用户（用于 Terraform）

1. 进入 IAM 控制台：https://console.aws.amazon.com/iam/
2. 点击 "Users" → "Create user"
3. 用户名：`terraform-admin`
4. 勾选 "Provide user access to the AWS Management Console"（可选）
5. 权限设置：
   - 选择 "Attach policies directly"
   - 搜索并勾选：`AdministratorAccess`（仅用于学习，生产环境应使用最小权限）
6. 创建用户后，记录 Access Key

### 1.3 配置 AWS CLI

```bash
# 配置 AWS 凭证
aws configure

# 输入以下信息：
# AWS Access Key ID: [你的 Access Key]
# AWS Secret Access Key: [你的 Secret Key]
# Default region name: us-east-1
# Default output format: json

# 验证配置
aws sts get-caller-identity
```

---

## 第二步：获取 OpenAI API Key

1. 访问 [OpenAI 平台](https://platform.openai.com/)
2. 登录或注册账号
3. 进入 [API Keys 页面](https://platform.openai.com/api-keys)
4. 点击 "Create new secret key"
5. 复制并保存 API Key（格式：`sk-...`）

⚠️ **重要**：保管好你的 API Key，不要分享或提交到 Git！

---

## 第三步：创建 GitHub 仓库

### 3.1 初始化本地 Git 仓库

```bash
# 进入项目目录
cd C:\Users\ephem\Desktop\RAG_w501a

# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: RAG application"
```

### 3.2 在 GitHub 创建远程仓库

1. 访问 [GitHub](https://github.com/)
2. 点击右上角 "+" → "New repository"
3. 仓库设置：
   - Repository name: `rag-w501a`（或你喜欢的名字）
   - 可见性：Public 或 Private
   - ⚠️ **不要**勾选 "Initialize this repository with README"
4. 创建仓库

### 3.3 推送到 GitHub

```bash
# 添加远程仓库（替换为你的用户名和仓库名）
git remote add origin https://github.com/你的用户名/rag-w501a.git

# 推送代码
git branch -M main
git push -u origin main
```

---

## 第四步：使用 Terraform 部署 AWS 基础设施

### 4.1 配置 Terraform 变量

创建 `terraform.tfvars` 文件（不要提交到 Git）：

```bash
# Windows PowerShell
@"
openai_api_key           = "sk-你的OpenAI-API-Key"
github_org_or_user       = "你的GitHub用户名"
github_repo_name         = "rag-w501a"
aws_region               = "us-east-1"
manage_apprunner_via_terraform = true
"@ | Out-File -FilePath terraform.tfvars -Encoding utf8
```

或者手动创建文件 `terraform.tfvars`：
```hcl
openai_api_key           = "sk-你的OpenAI-API-Key"
github_org_or_user       = "你的GitHub用户名"
github_repo_name         = "rag-w501a"
aws_region               = "us-east-1"
manage_apprunner_via_terraform = true
```

### 4.2 运行 Terraform

```bash
# 初始化 Terraform
terraform init

# 预览将要创建的资源
terraform plan

# 应用配置（创建资源）
terraform apply

# 输入 yes 确认
```

⏱️ 这个过程大约需要 3-5 分钟。

### 4.3 记录输出信息

部署完成后，Terraform 会输出重要信息：

```bash
# 查看所有输出
terraform output

# 复制以下值，稍后需要用于配置 GitHub Secrets：
terraform output -raw ecr_repository_name
terraform output -raw github_actions_role_arn
terraform output -raw apprunner_service_arn
```

**保存这些值！** 📝

---

## 第五步：配置 GitHub Secrets

### 5.1 进入仓库设置

1. 打开你的 GitHub 仓库
2. 点击 "Settings" 标签
3. 左侧菜单选择 "Secrets and variables" → "Actions"
4. 点击 "New repository secret"

### 5.2 添加以下 Secrets

依次添加 4 个 Secrets：

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `AWS_REGION` | `us-east-1` | AWS 区域 |
| `ECR_REPOSITORY` | 从 `terraform output` 获取 | ECR 仓库名称 |
| `APP_RUNNER_ARN` | 从 `terraform output` 获取 | App Runner 服务 ARN |
| `AWS_IAM_ROLE_TO_ASSUME` | 从 `terraform output` 获取 | GitHub Actions IAM 角色 ARN |

示例截图步骤：
```
1. 点击 "New repository secret"
2. Name: AWS_REGION
3. Secret: us-east-1
4. 点击 "Add secret"
5. 重复以上步骤添加其他 3 个 secrets
```

---

## 第六步：触发自动部署

### 6.1 推送代码触发 CI/CD

由于你之前已经推送了代码，现在可以进行一次小的修改来触发部署：

```bash
# 修改 README（或任意文件）
echo "" >> README.md

# 提交并推送
git add .
git commit -m "Trigger deployment"
git push origin main
```

### 6.2 查看部署进度

1. 打开 GitHub 仓库
2. 点击 "Actions" 标签
3. 查看最新的工作流运行
4. 点击进去查看详细日志

⏱️ 部署过程大约需要 5-10 分钟。

### 6.3 部署步骤说明

GitHub Actions 会自动执行：

1. ✅ Checkout 代码
2. ✅ 使用 OIDC 认证 AWS
3. ✅ 登录 ECR
4. ✅ 构建 Docker 镜像
5. ✅ 推送镜像到 ECR
6. ✅ 部署到 App Runner
7. ✅ 等待服务稳定

---

## 第七步：验证部署

### 7.1 获取应用 URL

```bash
# 方法 1：从 Terraform 获取
terraform output apprunner_service_url

# 方法 2：从 AWS 控制台获取
# 访问: https://console.aws.amazon.com/apprunner/
```

### 7.2 测试应用

```bash
# 替换为你的实际 URL
export APP_URL="https://xxxxxxxxxx.us-east-1.awsapprunner.com"

# 测试健康检查
curl $APP_URL/health

# 测试问答
curl -X POST $APP_URL/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "什么是 RAG？"}'
```

### 7.3 在浏览器测试

访问你的应用 URL，你应该看到：

```json
{
  "status": "healthy",
  "message": "RAG 问答系统正在运行",
  "version": "1.0.0"
}
```

---

## 第八步：配置 Cloudflare（可选）

### 8.1 添加域名

1. 登录 [Cloudflare](https://dash.cloudflare.com/)
2. 点击 "Add a site"
3. 输入你的域名
4. 选择免费计划
5. 更新域名的 DNS 服务器到 Cloudflare 提供的地址

### 8.2 配置 DNS 记录

1. 进入 DNS 设置
2. 添加 CNAME 记录：
   - Type: `CNAME`
   - Name: `rag`（或其他子域名）
   - Target: 你的 App Runner URL（不含 https://）
   - Proxy status: Proxied（橙色云朵）
3. 保存

现在可以通过 `https://rag.yourdomain.com` 访问你的应用！

---

## 🎉 部署完成！

恭喜！你已经成功部署了一个完整的 RAG 应用到云端。

### 验证清单

- [ ] Terraform 成功创建了所有 AWS 资源
- [ ] GitHub Actions 工作流运行成功
- [ ] 可以通过 App Runner URL 访问应用
- [ ] API 测试通过
- [ ] （可选）Cloudflare 域名配置成功

---

## 📊 监控和管理

### 查看日志

```bash
# 获取服务 ARN
SERVICE_ARN=$(terraform output -raw apprunner_service_arn)

# 查看最近的操作
aws apprunner list-operations --service-arn $SERVICE_ARN --region us-east-1
```

### 暂停服务（节省成本）

```bash
# 方法 1：通过 AWS 控制台
# 访问 App Runner 控制台，点击服务，选择 "Pause service"

# 方法 2：删除 App Runner 服务但保留其他资源
terraform apply -var="manage_apprunner_via_terraform=false"
```

### 完全销毁环境

```bash
# 销毁所有资源
terraform destroy

# 输入 yes 确认
```

---

## 🐛 常见问题排查

### 问题 1：Terraform apply 失败

**错误**：`Error: error configuring Terraform AWS Provider`

**解决**：
```bash
# 检查 AWS 凭证
aws sts get-caller-identity

# 重新配置
aws configure
```

### 问题 2：GitHub Actions 失败 - 权限错误

**错误**：`Error: Could not assume role`

**解决**：
- 检查 `AWS_IAM_ROLE_TO_ASSUME` secret 是否正确
- 确认 GitHub 仓库名称与 Terraform 配置中的一致

### 问题 3：App Runner 启动失败

**错误**：容器健康检查失败

**解决**：
```bash
# 查看日志
aws apprunner describe-service --service-arn YOUR_ARN --region us-east-1

# 常见原因：
# 1. OpenAI API Key 未配置或无效
# 2. FAISS 索引未创建（需要在 Dockerfile 中运行 ingest.py）
```

### 问题 4：成本过高

**解决**：
- 不使用时暂停或删除 App Runner 服务
- 减少 CPU 和内存配置（在 main.tf 中修改）
- 设置预算警报

---

## 📞 获取帮助

如果遇到问题：

1. 查看项目 README.md 的故障排查部分
2. 查看 GitHub Actions 日志
3. 查看 AWS CloudWatch 日志
4. 查看 Terraform 错误信息

---

## 🔄 后续更新

每次更新代码后：

```bash
git add .
git commit -m "Update: 描述你的修改"
git push origin main
```

GitHub Actions 会自动构建和部署新版本！

---

**祝你部署成功！** 🚀

