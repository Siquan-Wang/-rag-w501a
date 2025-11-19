# Windows 工具安装脚本
# 请以管理员身份运行 PowerShell 后执行此脚本

Write-Host "=== RAG 项目部署工具安装脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ 请以管理员身份运行 PowerShell！" -ForegroundColor Red
    Write-Host ""
    Write-Host "操作步骤：" -ForegroundColor Yellow
    Write-Host "1. 按 Win + X"
    Write-Host "2. 选择 'Windows PowerShell (管理员)' 或 'Windows Terminal (管理员)'"
    Write-Host "3. 在新窗口中重新运行此脚本"
    exit 1
}

Write-Host "✅ 正在以管理员身份运行" -ForegroundColor Green
Write-Host ""

# 检查并安装 Chocolatey
Write-Host "步骤 1/4: 检查 Chocolatey..." -ForegroundColor Yellow
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "正在安装 Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Chocolatey 安装成功" -ForegroundColor Green
    } else {
        Write-Host "❌ Chocolatey 安装失败" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Chocolatey 已安装" -ForegroundColor Green
}
Write-Host ""

# 安装 Git
Write-Host "步骤 2/4: 安装 Git..." -ForegroundColor Yellow
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    choco install git -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "✅ Git 安装成功" -ForegroundColor Green
} else {
    Write-Host "✅ Git 已安装" -ForegroundColor Green
}
Write-Host ""

# 安装 AWS CLI
Write-Host "步骤 3/4: 安装 AWS CLI..." -ForegroundColor Yellow
if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    choco install awscli -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "✅ AWS CLI 安装成功" -ForegroundColor Green
} else {
    Write-Host "✅ AWS CLI 已安装" -ForegroundColor Green
}
Write-Host ""

# 安装 Terraform
Write-Host "步骤 4/4: 安装 Terraform..." -ForegroundColor Yellow
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    choco install terraform -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "✅ Terraform 安装成功" -ForegroundColor Green
} else {
    Write-Host "✅ Terraform 已安装" -ForegroundColor Green
}
Write-Host ""

# 验证安装
Write-Host "=== 验证安装 ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Git 版本："
git --version

Write-Host "`nAWS CLI 版本："
aws --version

Write-Host "`nTerraform 版本："
terraform --version

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✨ 所有工具安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  重要：请关闭并重新打开 PowerShell 窗口以使环境变量生效" -ForegroundColor Yellow
Write-Host ""
Write-Host "下一步：运行 'aws configure' 配置 AWS 凭证" -ForegroundColor Cyan

