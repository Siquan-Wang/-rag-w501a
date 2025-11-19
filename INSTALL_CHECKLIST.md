# 🔧 工具安装检查清单

## 当前状态

- ✅ **Python 3.12.7** - 已安装
- ❌ **Git** - 需要安装
- ❌ **AWS CLI** - 需要安装
- ❌ **Terraform** - 需要安装

---

## 安装步骤

### ✅ 步骤 1：安装 Git

**下载地址**：https://git-scm.com/download/win

**安装方法**：
1. [ ] 下载安装程序
2. [ ] 运行安装程序，一路 Next
3. [ ] 验证：打开新的 PowerShell，运行 `git --version`

---

### ✅ 步骤 2：安装 AWS CLI

**下载地址**：https://awscli.amazonaws.com/AWSCLIV2.msi

**安装方法**：
1. [ ] 下载 MSI 安装包
2. [ ] 运行安装程序，一路 Next
3. [ ] 验证：打开新的 PowerShell，运行 `aws --version`

---

### ✅ 步骤 3：安装 Terraform

**下载地址**：https://www.terraform.io/downloads

**安装方法**：
1. [ ] 下载 Windows AMD64 ZIP 文件
2. [ ] 解压得到 `terraform.exe`
3. [ ] 创建文件夹 `C:\terraform`
4. [ ] 将 `terraform.exe` 复制到 `C:\terraform`
5. [ ] 添加环境变量：
   - [ ] Win+R → 输入 `sysdm.cpl` → 回车
   - [ ] 高级 → 环境变量
   - [ ] 系统变量 → Path → 编辑
   - [ ] 新建 → 输入 `C:\terraform`
   - [ ] 确定 → 确定 → 确定
6. [ ] 验证：**关闭并重新打开** PowerShell，运行 `terraform --version`

---

## 验证安装

**关闭所有 PowerShell 窗口，重新打开一个新窗口**，运行：

```powershell
git --version
aws --version
terraform --version
python --version
```

如果都能看到版本号，说明安装成功！✨

---

## 下一步

安装完成后，告诉我，我会继续指导你：
1. 配置 AWS 凭证
2. 创建 GitHub 仓库
3. 部署到云端

---

**预计总安装时间：10-15 分钟**

