#!/bin/bash

# API 测试脚本

# 设置 API URL（默认本地，可以通过参数指定）
API_URL=${1:-"http://localhost:8080"}

echo "🧪 测试 RAG API"
echo "API URL: $API_URL"
echo "===================="

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 测试健康检查
test_health() {
    echo -e "\n${YELLOW}1. 测试健康检查 (GET /)${NC}"
    response=$(curl -s "$API_URL/")
    echo "$response" | jq .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 健康检查通过${NC}"
    else
        echo -e "${RED}❌ 健康检查失败${NC}"
    fi
}

# 测试系统信息
test_info() {
    echo -e "\n${YELLOW}2. 测试系统信息 (GET /info)${NC}"
    response=$(curl -s "$API_URL/info")
    echo "$response" | jq .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 系统信息获取成功${NC}"
    else
        echo -e "${RED}❌ 系统信息获取失败${NC}"
    fi
}

# 测试问答
test_ask() {
    echo -e "\n${YELLOW}3. 测试问答 (POST /ask)${NC}"
    
    questions=(
        "什么是 RAG？"
        "这个项目使用了哪些技术？"
        "如何部署这个应用？"
        "什么是 OIDC？"
    )
    
    for question in "${questions[@]}"; do
        echo -e "\n${YELLOW}问题: $question${NC}"
        
        response=$(curl -s -X POST "$API_URL/ask" \
            -H "Content-Type: application/json" \
            -d "{\"question\": \"$question\"}")
        
        echo "$response" | jq .
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 问答测试通过${NC}"
        else
            echo -e "${RED}❌ 问答测试失败${NC}"
        fi
        
        echo "---"
        sleep 2  # 避免请求过快
    done
}

# 测试错误处理
test_error_handling() {
    echo -e "\n${YELLOW}4. 测试错误处理${NC}"
    
    # 测试空问题
    echo -e "\n${YELLOW}4.1 测试空问题${NC}"
    response=$(curl -s -X POST "$API_URL/ask" \
        -H "Content-Type: application/json" \
        -d '{"question": ""}')
    echo "$response" | jq .
    
    # 测试缺少问题字段
    echo -e "\n${YELLOW}4.2 测试缺少问题字段${NC}"
    response=$(curl -s -X POST "$API_URL/ask" \
        -H "Content-Type: application/json" \
        -d '{}')
    echo "$response" | jq .
}

# 性能测试
test_performance() {
    echo -e "\n${YELLOW}5. 性能测试（10 次请求）${NC}"
    
    total_time=0
    count=10
    
    for i in $(seq 1 $count); do
        start=$(date +%s.%N)
        curl -s -X POST "$API_URL/ask" \
            -H "Content-Type: application/json" \
            -d '{"question": "什么是 RAG？"}' > /dev/null
        end=$(date +%s.%N)
        
        duration=$(echo "$end - $start" | bc)
        total_time=$(echo "$total_time + $duration" | bc)
        
        echo "请求 $i: ${duration}s"
    done
    
    avg_time=$(echo "scale=2; $total_time / $count" | bc)
    echo -e "\n${GREEN}平均响应时间: ${avg_time}s${NC}"
}

# 主函数
main() {
    # 检查 jq 是否安装
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq 未安装，输出可能不美观${NC}"
        echo "安装 jq: https://stedolan.github.io/jq/download/"
    fi
    
    # 运行所有测试
    test_health
    test_info
    test_ask
    test_error_handling
    
    # 询问是否运行性能测试
    echo -e "\n${YELLOW}是否运行性能测试？ (y/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        test_performance
    fi
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✨ 测试完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# 运行主函数
main

