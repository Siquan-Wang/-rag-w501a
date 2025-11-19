# AWS CLI 配置脚本

Write-Host "=== AWS CLI 配置 ===" -ForegroundColor Cyan
Write-Host ""

# 你的 Access Key ID
$accessKeyId = "AKIAXJJGYTOJXV4YS43A"

# 请在这里填入你的 Secret Access Key（从 CSV 文件中获取）
$secretAccessKey = "YOUR_SECRET_ACCESS_KEY_HERE"

# 默认区域
$region = "us-east-1"

# 默认输出格式
$outputFormat = "json"

Write-Host "检查 Secret Access Key..." -ForegroundColor Yellow

if ($secretAccessKey -eq "YOUR_SECRET_ACCESS_KEY_HERE") {
    Write-Host ""
    Write-Host "❌ 错误：请先编辑此脚本，填入你的 Secret Access Key！" -ForegroundColor Red
    Write-Host ""
    Write-Host "步骤：" -ForegroundColor Yellow
    Write-Host "1. 打开下载的 CSV 文件" -ForegroundColor Yellow
    Write-Host "2. 复制 Secret Access Key" -ForegroundColor Yellow
    Write-Host "3. 编辑此脚本，替换 YOUR_SECRET_ACCESS_KEY_HERE" -ForegroundColor Yellow
    Write-Host "4. 保存并重新运行此脚本" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "配置 AWS CLI..." -ForegroundColor Yellow

# 创建 .aws 目录
$awsDir = "$env:USERPROFILE\.aws"
if (!(Test-Path $awsDir)) {
    New-Item -ItemType Directory -Path $awsDir -Force | Out-Null
}

# 写入 credentials 文件
$credentialsPath = "$awsDir\credentials"
@"
[default]
aws_access_key_id = $accessKeyId
aws_secret_access_key = $secretAccessKey
"@ | Out-File -FilePath $credentialsPath -Encoding utf8 -Force

# 写入 config 文件
$configPath = "$awsDir\config"
@"
[default]
region = $region
output = $outputFormat
"@ | Out-File -FilePath $configPath -Encoding utf8 -Force

Write-Host ""
Write-Host "✅ AWS CLI 配置成功！" -ForegroundColor Green
Write-Host ""
Write-Host "验证配置..." -ForegroundColor Yellow
aws sts get-caller-identity

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 AWS 凭证验证成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "配置信息：" -ForegroundColor Cyan
    Write-Host "  Access Key ID: $accessKeyId" -ForegroundColor Green
    Write-Host "  Region: $region" -ForegroundColor Green
    Write-Host "  Output: $outputFormat" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ AWS 凭证验证失败，请检查密钥是否正确" -ForegroundColor Red
}

