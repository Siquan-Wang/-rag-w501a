#!/bin/bash

# 本地开发环境设置脚本

set -e

echo "🚀 设置本地开发环境"
echo "===================="

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查 Python
check_python() {
    echo -e "\n${YELLOW}检查 Python 环境...${NC}"
    
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 未安装${NC}"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d ' ' -f 2)
    echo -e "${GREEN}✅ Python 版本: $PYTHON_VERSION${NC}"
}

# 创建虚拟环境
create_venv() {
    echo -e "\n${YELLOW}创建 Python 虚拟环境...${NC}"
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        echo -e "${GREEN}✅ 虚拟环境已创建${NC}"
    else
        echo -e "${YELLOW}⚠️  虚拟环境已存在${NC}"
    fi
}

# 激活虚拟环境提示
show_activation() {
    echo -e "\n${YELLOW}激活虚拟环境：${NC}"
    
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo -e "${GREEN}venv\\Scripts\\activate${NC}"
    else
        echo -e "${GREEN}source venv/bin/activate${NC}"
    fi
}

# 安装依赖
install_dependencies() {
    echo -e "\n${YELLOW}安装 Python 依赖...${NC}"
    
    # 检查是否在虚拟环境中
    if [ -z "$VIRTUAL_ENV" ]; then
        echo -e "${YELLOW}⚠️  未在虚拟环境中${NC}"
        echo "请先激活虚拟环境"
        show_activation
        return
    fi
    
    pip install --upgrade pip
    pip install -r requirements.txt
    echo -e "${GREEN}✅ 依赖安装完成${NC}"
}

# 创建 .env 文件
create_env_file() {
    echo -e "\n${YELLOW}配置环境变量...${NC}"
    
    if [ ! -f ".env" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ 已创建 .env 文件${NC}"
        echo -e "${YELLOW}⚠️  请编辑 .env 文件并填入你的 OpenAI API Key${NC}"
    else
        echo -e "${YELLOW}⚠️  .env 文件已存在${NC}"
    fi
}

# 测试环境
test_environment() {
    echo -e "\n${YELLOW}测试环境...${NC}"
    
    if [ -z "$VIRTUAL_ENV" ]; then
        echo -e "${RED}❌ 未在虚拟环境中${NC}"
        return
    fi
    
    python3 -c "import flask; import langchain; import openai" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 环境测试通过${NC}"
    else
        echo -e "${RED}❌ 环境测试失败${NC}"
        echo "请确保已安装所有依赖"
    fi
}

# 主函数
main() {
    check_python
    create_venv
    show_activation
    
    echo -e "\n${YELLOW}是否立即激活虚拟环境并安装依赖？ (y/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
            source venv/Scripts/activate
        else
            source venv/bin/activate
        fi
        install_dependencies
        create_env_file
        test_environment
    else
        create_env_file
    fi
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✨ 本地环境设置完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "\n${YELLOW}📝 接下来的步骤：${NC}"
    echo "1. 激活虚拟环境"
    show_activation
    echo -e "2. 配置 .env 文件中的 OPENAI_API_KEY"
    echo -e "3. 运行 ${GREEN}python ingest.py${NC} 创建向量索引"
    echo -e "4. 运行 ${GREEN}python app.py${NC} 启动应用"
    echo -e "5. 访问 ${GREEN}http://localhost:8080${NC}"
}

# 运行主函数
main

