# 📋 作业要求对照检查清单

请对照课件和作业要求，检查本项目是否满足所有要求。

## ✅ 核心功能要求

### 1. RAG 应用开发
- [ ] 使用 LangChain 框架
- [ ] 集成 FAISS 向量数据库
- [ ] 使用 OpenAI API（GPT-3.5-turbo）
- [ ] 实现文档检索功能
- [ ] 实现问答生成功能
- [ ] 提供 REST API 接口

**文件位置**：
- `app.py` - Flask 应用
- `ingest.py` - 向量化脚本
- `data.txt` - 知识库
- `requirements.txt` - 依赖包

### 2. Docker 容器化
- [ ] 创建 Dockerfile
- [ ] 配置 .dockerignore
- [ ] 使用生产级 web 服务器（Gunicorn）
- [ ] 配置健康检查
- [ ] 镜像可以成功构建和运行

**文件位置**：
- `Dockerfile`
- `.dockerignore`

### 3. Terraform 基础设施即代码
- [ ] 创建 ECR 仓库
- [ ] 创建 Secrets Manager（存储 OpenAI API Key）
- [ ] 创建 IAM 角色（App Runner 访问角色）
- [ ] 创建 IAM 角色（App Runner 实例角色）
- [ ] 创建 IAM 角色（GitHub Actions 部署角色）
- [ ] 配置 GitHub OIDC Provider
- [ ] 创建 App Runner 服务（可选）

**文件位置**：
- `main.tf`

### 4. GitHub Actions CI/CD
- [ ] 配置工作流触发条件（push to main）
- [ ] 使用 OIDC 认证（无密钥）
- [ ] 自动构建 Docker 镜像
- [ ] 推送镜像到 ECR
- [ ] 自动部署到 App Runner
- [ ] 等待服务稳定

**文件位置**：
- `.github/workflows/main.yml`

### 5. AWS 部署
- [ ] 应用运行在 AWS App Runner
- [ ] 使用 ECR 存储镜像
- [ ] 使用 Secrets Manager 管理密钥
- [ ] 配置健康检查
- [ ] 服务可以正常访问

### 6. Cloudflare 配置（可选）
- [ ] 配置自定义域名
- [ ] 启用 CDN
- [ ] 配置 DNS 记录

**说明**：
- `DEPLOYMENT_GUIDE.md` 第八步有详细说明

## 📚 文档要求

### 1. README.md
- [ ] 项目概述
- [ ] 技术栈说明
- [ ] 本地开发指南
- [ ] 云端部署指南
- [ ] API 使用说明
- [ ] 故障排查

**文件位置**：
- `README.md`

### 2. 部署文档
- [ ] 详细的部署步骤
- [ ] 配置说明
- [ ] 环境变量说明

**文件位置**：
- `DEPLOYMENT_GUIDE.md`
- `QUICK_DEPLOY.md`

## 🔒 安全最佳实践

- [ ] 使用 OIDC 而非长期密钥
- [ ] 密钥存储在 Secrets Manager
- [ ] IAM 角色遵循最小权限原则
- [ ] 不在代码中硬编码密钥
- [ ] .gitignore 排除敏感文件
- [ ] ECR 镜像扫描启用

## 🧪 测试要求

- [ ] 本地可以运行
- [ ] Docker 容器可以运行
- [ ] API 接口可以正常工作
- [ ] 云端部署成功
- [ ] 可以通过公网访问

## 📦 交付物清单

### 代码文件
- [ ] `app.py` - 主应用
- [ ] `ingest.py` - 数据处理
- [ ] `data.txt` - 知识库
- [ ] `requirements.txt` - Python 依赖
- [ ] `Dockerfile` - 容器配置
- [ ] `.dockerignore` - Docker 忽略文件
- [ ] `.gitignore` - Git 忽略文件

### 基础设施代码
- [ ] `main.tf` - Terraform 配置
- [ ] `terraform.tfvars` - Terraform 变量（不提交）

### CI/CD
- [ ] `.github/workflows/main.yml` - GitHub Actions

### 文档
- [ ] `README.md` - 主文档
- [ ] `DEPLOYMENT_GUIDE.md` - 部署指南
- [ ] `QUICK_DEPLOY.md` - 快速部署

### 辅助脚本
- [ ] `deploy.sh` - 部署脚本
- [ ] `setup-local.sh` - 本地环境设置
- [ ] `test-api.sh` - API 测试脚本

## ❓ 需要确认的课件要求

请对照课件检查以下内容：

### 1. Firebase 集成（W501 c）
**课件中是否要求？**
- [ ] 是 - 需要添加 Firebase 登录
- [ ] 否 - 不需要

**如果需要**：
- 参考：https://github.com/chifn/firebase-demo
- 需要添加用户认证功能
- 需要集成 Firestore 数据库

### 2. 特定的技术版本要求
检查课件是否指定：
- [ ] Python 版本
- [ ] LangChain 版本
- [ ] OpenAI API 版本
- [ ] Terraform 版本

### 3. 特定的 AWS 配置
检查课件是否要求：
- [ ] 特定的 AWS 区域
- [ ] 特定的实例配置（CPU/内存）
- [ ] 特定的网络配置

### 4. 评分标准
检查课件中的评分标准：
- [ ] 代码质量
- [ ] 文档完整性
- [ ] 部署成功
- [ ] 功能完整性
- [ ] 安全性
- [ ] 其他：_____________

## 🔍 对比示例代码

**示例代码仓库**：https://github.com/jerrysf/course-devops-ai

请对比：
- [ ] 项目结构是否一致
- [ ] 核心功能是否一致
- [ ] 配置文件是否一致
- [ ] 是否有我遗漏的文件

## 📝 额外的作业要求

请从课件中提取以下信息：

### 1. 提交方式
- [ ] GitHub 仓库链接
- [ ] 部署的应用 URL
- [ ] 演示视频
- [ ] 报告文档
- [ ] 其他：_____________

### 2. 截图要求
- [ ] GitHub Actions 运行成功
- [ ] Terraform 输出
- [ ] AWS 控制台截图
- [ ] 应用运行截图
- [ ] API 测试截图
- [ ] 其他：_____________

### 3. 演示内容
- [ ] 本地运行演示
- [ ] 云端部署演示
- [ ] API 调用演示
- [ ] CI/CD 流程演示
- [ ] 其他：_____________

## ✅ 最终检查

在提交前：
- [ ] 所有代码已推送到 GitHub
- [ ] GitHub Actions 工作流运行成功
- [ ] 应用在云端可以访问
- [ ] API 测试通过
- [ ] 文档完整且准确
- [ ] 所有敏感信息已移除
- [ ] 符合课件的所有要求

## 📞 需要帮助？

如果发现任何课件要求与当前项目不符：
1. 查看 PPT 课件中的具体要求
2. 对比示例代码仓库
3. 告诉我需要调整的内容，我可以帮你修改

---

**建议**：打开课件 PPT，逐条对照此清单检查！

