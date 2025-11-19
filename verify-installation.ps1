# 验证工具安装脚本

Write-Host "=== 验证工具安装 ===" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# 检查 Git
Write-Host "检查 Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "✅ Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git 未正确安装或未在 PATH 中" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# 检查 AWS CLI
Write-Host "检查 AWS CLI..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version 2>&1
    Write-Host "✅ AWS CLI: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI 未正确安装或未在 PATH 中" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# 检查 Terraform
Write-Host "检查 Terraform..." -ForegroundColor Yellow
try {
    $tfVersion = terraform --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Terraform: $tfVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform 未正确安装或未在 PATH 中" -ForegroundColor Red
    Write-Host "   请确保:" -ForegroundColor Yellow
    Write-Host "   1. terraform.exe 在 C:\terraform 目录" -ForegroundColor Yellow
    Write-Host "   2. C:\terraform 已添加到环境变量 Path" -ForegroundColor Yellow
    Write-Host "   3. 已关闭并重新打开 PowerShell" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# 检查 Python
Write-Host "检查 Python..." -ForegroundColor Yellow
try {
    $pyVersion = python --version 2>&1
    Write-Host "✅ Python: $pyVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Python 未安装 (可选，仅用于本地测试)" -ForegroundColor Yellow
}
Write-Host ""

# 总结
Write-Host "========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "🎉 所有必需工具已正确安装！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步：配置 AWS 凭证" -ForegroundColor Cyan
    Write-Host "运行命令: aws configure" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  有些工具未正确安装，请检查上述错误" -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan

