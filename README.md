# RAG 问答系统 - 从开发到云端部署

[![Deploy to AWS App Runner](https://github.com/yourusername/yourrepo/actions/workflows/main.yml/badge.svg)](https://github.com/yourusername/yourrepo/actions/workflows/main.yml)

这是一个完整的 RAG（Retrieval-Augmented Generation）问答系统项目，展示了从代码开发到云端自动化部署的完整流程。

## 📋 项目概述

本项目实现了：
- ✅ 基于 **LangChain** 的 RAG 问答应用
- ✅ 使用 **FAISS** 向量数据库进行高效检索
- ✅ 集成 **OpenAI GPT-3.5-turbo** 生成回答
- ✅ **Docker** 容器化部署
- ✅ **Terraform** 管理 AWS 基础设施
- ✅ **GitHub Actions** CI/CD 自动化流水线
- ✅ 部署到 **AWS App Runner**
- ✅ **Cloudflare** 域名配置

## 🏗️ 项目架构

```
用户请求 → Cloudflare → AWS App Runner → Flask API
                                           ↓
                                    LangChain RAG
                                           ↓
                                    FAISS 向量检索
                                           ↓
                                    OpenAI GPT-3.5
```

## 🚀 快速开始

### 前置要求

1. **安装必要工具**：
   - [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   - [AWS CLI](https://aws.amazon.com/cli/)
   - [Git](https://git-scm.com/)

2. **账号注册**：
   - AWS 账号（需要升级到付费账户）
   - OpenAI API 账号
   - GitHub 账号
   - Cloudflare 账号（可选）

### 本地开发

#### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo
```

#### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，填入你的 OpenAI API Key
```

#### 3. 安装依赖

```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### 4. 创建向量索引

```bash
python ingest.py
```

#### 5. 启动应用

```bash
python app.py
```

访问 http://localhost:8080

#### 6. 测试 API

```bash
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -d '{"question": "什么是 RAG？"}'
```

### Docker 本地测试

```bash
# 构建镜像
docker build -t rag-app .

# 运行容器
docker run -p 8080:8080 -e OPENAI_API_KEY=your-key rag-app
```

## ☁️ 云端部署

### 第一步：配置 AWS 基础设施

#### 1. 配置 AWS 凭证

```bash
aws configure
```

#### 2. 设置 Terraform 变量

创建 `terraform.tfvars` 文件：

```hcl
openai_api_key           = "sk-your-openai-api-key"
github_org_or_user       = "your-github-username"
github_repo_name         = "your-repo-name"
aws_region               = "us-east-1"
manage_apprunner_via_terraform = true
```

⚠️ **注意**：不要将 `terraform.tfvars` 提交到 Git！

#### 3. 初始化并应用 Terraform

```bash
# 初始化 Terraform
terraform init

# 查看将要创建的资源
terraform plan

# 创建资源
terraform apply
```

Terraform 将创建：
- ✅ ECR 仓库（存储 Docker 镜像）
- ✅ Secrets Manager（存储 OpenAI API Key）
- ✅ IAM 角色（App Runner 访问角色、实例角色、GitHub Actions 角色）
- ✅ OIDC Provider（GitHub Actions 认证）
- ✅ App Runner 服务（可选）

#### 4. 记录输出信息

```bash
terraform output
```

保存以下信息，后续配置 GitHub Secrets 时需要：
- `ecr_repository_name`
- `github_actions_role_arn`
- `apprunner_service_arn`

### 第二步：配置 GitHub Secrets

在 GitHub 仓库设置中添加以下 Secrets：

1. 进入仓库 → **Settings** → **Secrets and variables** → **Actions**
2. 点击 **New repository secret** 添加：

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `AWS_REGION` | `us-east-1` | AWS 区域 |
| `ECR_REPOSITORY` | `bee-edu-rag-app` | ECR 仓库名称 |
| `APP_RUNNER_ARN` | `arn:aws:apprunner:...` | App Runner 服务 ARN |
| `AWS_IAM_ROLE_TO_ASSUME` | `arn:aws:iam::...` | GitHub Actions IAM 角色 ARN |

### 第三步：推送代码触发部署

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

GitHub Actions 将自动：
1. ✅ 构建 Docker 镜像
2. ✅ 推送到 ECR
3. ✅ 部署到 App Runner
4. ✅ 等待服务稳定

查看部署进度：https://github.com/yourusername/yourrepo/actions

### 第四步：访问应用

部署完成后，访问 App Runner 提供的 URL：
```
https://xxxxxxxxxx.us-east-1.awsapprunner.com
```

## 🧪 API 使用说明

### 端点列表

| 端点 | 方法 | 说明 |
|------|------|------|
| `/` | GET | 健康检查 |
| `/health` | GET | 系统状态 |
| `/info` | GET | 系统信息 |
| `/ask` | POST | 提交问题 |

### 示例：提问

**请求**：
```bash
curl -X POST https://your-app-url/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "什么是 RAG？"
  }'
```

**响应**：
```json
{
  "question": "什么是 RAG？",
  "answer": "RAG 是一种结合了检索和生成的AI技术...",
  "sources": [
    {
      "content": "RAG (Retrieval-Augmented Generation) 问答系统...",
      "metadata": {}
    }
  ]
}
```

## 📁 项目结构

```
RAG_w501a/
├── .github/
│   └── workflows/
│       └── main.yml          # GitHub Actions CI/CD 工作流
├── app.py                    # Flask 应用主文件
├── ingest.py                 # 数据摄入脚本
├── data.txt                  # 知识库数据
├── requirements.txt          # Python 依赖
├── Dockerfile                # Docker 配置
├── .dockerignore            # Docker 忽略文件
├── .gitignore               # Git 忽略文件
├── main.tf                  # Terraform 基础设施配置
└── README.md                # 项目文档
```

## 🔧 配置说明

### 环境变量

| 变量名 | 说明 | 必需 |
|--------|------|------|
| `OPENAI_API_KEY` | OpenAI API 密钥 | ✅ |
| `PORT` | 应用端口（默认 8080） | ❌ |

### Terraform 变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `aws_region` | AWS 区域 | `us-east-1` |
| `project_name` | 项目名称 | `bee-edu-rag-app` |
| `openai_api_key` | OpenAI API 密钥 | - |
| `github_org_or_user` | GitHub 用户名 | - |
| `github_repo_name` | GitHub 仓库名 | - |
| `manage_apprunner_via_terraform` | 是否用 Terraform 管理 App Runner | `false` |

## 💰 成本估算

### AWS 服务成本

- **App Runner**：约 $2-4/天（运行时）
  - 1 vCPU + 2GB 内存
  - 建议不使用时销毁服务
- **ECR**：前 10GB 免费，之后 $0.10/GB/月
- **Secrets Manager**：$0.40/密钥/月
- **数据传输**：出站流量 $0.09/GB（前 100GB 免费）

### 节省成本的建议

1. **不使用时删除 App Runner 服务**：
   ```bash
   terraform destroy
   ```

2. **使用 Terraform 按需创建/销毁**：
   ```bash
   # 创建
   terraform apply -var="manage_apprunner_via_terraform=true"
   
   # 销毁
   terraform destroy
   ```

3. **减少 ECR 镜像数量**：设置了自动清理策略，保留最近 10 个镜像

## 🔒 安全最佳实践

1. ✅ **使用 OIDC 认证**：避免在 GitHub 中存储 AWS 密钥
2. ✅ **Secrets Manager**：安全存储 API 密钥
3. ✅ **IAM 最小权限**：仅授予必需的权限
4. ✅ **ECR 镜像扫描**：自动扫描安全漏洞
5. ✅ **环境变量隔离**：不在代码中硬编码密钥

## 🐛 故障排查

### 常见问题

**Q: GitHub Actions 部署失败，提示权限错误**

A: 检查以下内容：
- GitHub Secrets 是否正确配置
- IAM 角色是否有足够权限
- App Runner ARN 格式是否正确（必须是 ARN，不是 URL）

**Q: App Runner 启动失败**

A: 查看 App Runner 日志：
```bash
aws apprunner list-operations --service-arn YOUR_SERVICE_ARN
```

常见原因：
- OpenAI API Key 未配置或无效
- FAISS 索引未创建
- 健康检查失败

**Q: 向量索引创建失败**

A: 确保：
- OpenAI API Key 有效
- data.txt 文件存在且格式正确
- 网络可以访问 OpenAI API

**Q: Docker 构建失败**

A: 常见原因：
- requirements.txt 中的包版本不兼容
- 系统依赖缺失
- 网络问题导致包下载失败

## 📚 学习资源

- [LangChain 文档](https://python.langchain.com/)
- [AWS App Runner 文档](https://docs.aws.amazon.com/apprunner/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [FAISS 文档](https://faiss.ai/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📝 许可证

MIT License

## 👨‍💻 作者

这是一个教学项目，用于演示完整的 RAG 应用开发和 DevOps 流程。

## 🙏 致谢

感谢以下开源项目：
- LangChain
- OpenAI
- FAISS
- Flask
- Terraform
- GitHub Actions

---

**祝你学习愉快！如有问题，欢迎提 Issue 讨论。** 🚀

