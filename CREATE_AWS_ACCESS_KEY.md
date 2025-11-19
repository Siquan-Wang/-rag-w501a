# 创建 AWS 访问密钥 - 详细步骤

## 🎯 目标

创建一个 IAM 用户并获取访问密钥，用于 Terraform 部署。

---

## 📝 步骤 1：登录 AWS 控制台

1. 访问：https://console.aws.amazon.com/
2. 使用你刚注册的账号登录
3. 如果需要，完成 MFA 验证

---

## 👤 步骤 2：创建 IAM 用户

### 2.1 进入 IAM 服务

1. 登录后，在顶部搜索栏输入 **"IAM"**
2. 点击 **"IAM"** 进入 IAM 控制台
3. 或直接访问：https://console.aws.amazon.com/iam/

### 2.2 创建用户

1. 在左侧菜单点击 **"用户"** (Users)
2. 点击右上角的 **"创建用户"** (Create user) 按钮
3. 填写用户详细信息：
   - **用户名**：`terraform-admin`
   - **勾选**：☑️ "提供对 AWS 管理控制台的用户访问权限"（可选）
4. 点击 **"下一步"** (Next)

### 2.3 设置权限

1. 选择 **"直接附加策略"** (Attach policies directly)
2. 在搜索框中输入 **"AdministratorAccess"**
3. **勾选** ☑️ `AdministratorAccess` 策略
   - ⚠️ 这是管理员权限，仅用于学习
   - 生产环境应使用更细粒度的权限
4. 点击 **"下一步"** (Next)

### 2.4 审核并创建

1. 查看用户信息
2. 点击 **"创建用户"** (Create user)
3. 用户创建成功！

---

## 🔑 步骤 3：创建访问密钥

### 3.1 进入用户详情

1. 在用户列表中，点击刚创建的 **`terraform-admin`** 用户
2. 进入用户详情页面

### 3.2 创建访问密钥

1. 点击 **"安全凭证"** (Security credentials) 标签
2. 向下滚动到 **"访问密钥"** (Access keys) 部分
3. 点击 **"创建访问密钥"** (Create access key) 按钮

### 3.3 选择用例

1. 选择用例：**"命令行界面 (CLI)"** (Command Line Interface)
2. **勾选** ☑️ "我了解上述建议，并希望继续创建访问密钥"
3. 点击 **"下一步"** (Next)

### 3.4 设置描述标签（可选）

1. 描述标签（可选）：`Terraform deployment for RAG project`
2. 点击 **"创建访问密钥"** (Create access key)

### 3.5 保存访问密钥

✨ **重要时刻！**

页面会显示：
- **访问密钥 ID** (Access Key ID)：`AKIA...` 开头
- **私有访问密钥** (Secret Access Key)：只显示这一次！

**⚠️ 务必保存这两个密钥！**

**方法 1：下载 CSV 文件（推荐）**
1. 点击 **"下载 .csv 文件"** 按钮
2. 保存到安全的位置
3. 不要分享这个文件！

**方法 2：手动复制**
1. 复制 **Access Key ID**
2. 复制 **Secret Access Key**
3. 保存到记事本或密码管理器

**完成后点击 "完成" (Done)**

---

## ✅ 检查清单

- [ ] 创建了 IAM 用户 `terraform-admin`
- [ ] 附加了 `AdministratorAccess` 策略
- [ ] 创建了访问密钥
- [ ] 保存了 Access Key ID（AKIA... 开头）
- [ ] 保存了 Secret Access Key（只显示一次）
- [ ] 下载了 CSV 文件

---

## ⏭️ 下一步

保存好访问密钥后，我们需要配置 AWS CLI：

```bash
aws configure
```

然后输入：
- AWS Access Key ID: [你的 Access Key ID]
- AWS Secret Access Key: [你的 Secret Access Key]
- Default region name: us-east-1
- Default output format: json

---

## 🔒 安全提醒

1. **不要分享访问密钥**
2. **不要提交到 Git**
3. **不要截图包含密钥的页面**
4. **如果泄露，立即删除并重新创建**

删除访问密钥方法：
1. 进入 IAM → 用户 → terraform-admin
2. 安全凭证标签
3. 找到对应的访问密钥
4. 点击 "操作" → "停用" 或 "删除"

---

**预计时间：5-10 分钟**

