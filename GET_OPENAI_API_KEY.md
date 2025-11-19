# 获取 OpenAI API Key 指南

## 🔐 查找或创建 OpenAI API Key

### 方法 1：访问 API Keys 页面

1. **登录 OpenAI 平台**
   - 访问：https://platform.openai.com/
   - 使用你的邮箱和密码登录

2. **进入 API Keys 页面**
   - 直接访问：https://platform.openai.com/api-keys
   - 或点击左侧菜单 → "API keys"

3. **查看现有的 Keys**
   - 如果有之前创建的 Key，会显示在列表中
   - ⚠️ 注意：无法查看完整的 Key（只显示部分）
   - 如果你找不到完整的 Key，需要创建新的

---

## ✨ 创建新的 API Key（推荐）

### 步骤 1：点击创建按钮

在 API Keys 页面，点击：
- **"+ Create new secret key"** 按钮
- 或 **"Create new secret key"** 按钮

### 步骤 2：设置 Key 信息

1. **Name**（名称）：输入一个好记的名字
   - 例如：`RAG Project`
   - 例如：`W501 Homework`

2. **Permissions**（权限，如果有此选项）：
   - 选择 **"All"**（全部）
   - 或保持默认设置

3. 点击 **"Create secret key"** 按钮

### 步骤 3：保存 API Key

✨ **关键时刻！**

创建后会显示完整的 API Key：
```
sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**⚠️ 这个 Key 只显示一次！**

**立即保存：**

**方法 1：复制到文本文件**
1. 点击复制图标或手动选择复制
2. 打开记事本
3. 粘贴并保存到：`C:\Users\ephem\Documents\openai-api-key.txt`

**方法 2：截图保存**
1. 截图保存完整的 Key
2. 保存到安全位置

**完成后点击 "Done" 或关闭对话框**

---

## ✅ 验证 API Key

创建后，在列表中会看到新的 Key：
- 名称：RAG Project
- 创建时间：刚刚
- 最后使用：Never（或从未）

---

## 💰 检查账户余额

在使用 API Key 之前，确保账户有余额：

1. 点击左侧菜单 **"Usage"** 或 **"使用情况"**
2. 或访问：https://platform.openai.com/usage
3. 查看：
   - **Current balance**（当前余额）
   - **Usage this month**（本月使用量）

**如果余额不足：**
1. 点击 **"Add payment method"** 或 **"添加支付方式"**
2. 绑定信用卡
3. 充值（建议最少 $5）

---

## 🔒 安全提醒

1. **不要分享 API Key**
2. **不要提交到 Git**
3. **不要公开发布**
4. **如果泄露，立即删除并重新创建**

删除 API Key：
1. 进入 API Keys 页面
2. 找到对应的 Key
3. 点击删除按钮

---

## 📋 API Key 格式

OpenAI API Key 的格式：
- 旧格式：`sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`（以 `sk-` 开头）
- 新格式：`sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`（以 `sk-proj-` 开头）

两种格式都可以使用。

---

## ⏭️ 下一步

获得 API Key 后：
1. 保存到安全位置
2. 准备用于 Terraform 配置
3. 继续云端部署流程

---

**预计时间：5 分钟**

