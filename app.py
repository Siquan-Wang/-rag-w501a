"""
RAG (Retrieval-Augmented Generation) Flask 应用
使用 LangChain + FAISS + OpenAI 实现问答系统
简化版本 - 启动时强制初始化所有组件
"""
import os
from flask import Flask, request, jsonify
from langchain_community.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings
from langchain.llms import OpenAI
from langchain.chains import RetrievalQA
from langchain.text_splitter import CharacterTextSplitter
from langchain_community.document_loaders import TextLoader

app = Flask(__name__)

# 配置
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
FAISS_INDEX_PATH = "faiss_index"
DATA_FILE = "data.txt"

# 全局变量
qa_chain = None


def create_sample_data():
    """创建示例数据文件"""
    print("📝 创建示例数据文件...")
    sample_data = """人工智能（Artificial Intelligence，AI）是计算机科学的一个分支，致力于创建能够执行通常需要人类智能的任务的系统。人工智能包括机器学习、自然语言处理、计算机视觉等多个领域。

机器学习（Machine Learning，ML）是人工智能的一个子集，它使计算机能够从数据中学习并改进，而无需明确编程。机器学习算法可以识别模式、做出预测和决策。

深度学习（Deep Learning）是机器学习的一个子集，使用多层神经网络来模拟人脑的工作方式。深度学习在图像识别、语音识别和自然语言处理等领域取得了突破性进展。

自然语言处理（Natural Language Processing，NLP）是人工智能的一个领域，专注于使计算机能够理解、解释和生成人类语言。NLP应用包括机器翻译、情感分析和聊天机器人。

计算机视觉（Computer Vision）是人工智能的一个领域，使计算机能够从数字图像或视频中获取高级理解。计算机视觉应用包括人脸识别、自动驾驶和医学图像分析。

神经网络（Neural Network）是一种受生物神经系统启发的计算模型，由相互连接的节点（神经元）组成。神经网络是深度学习的基础。

强化学习（Reinforcement Learning）是一种机器学习方法，智能体通过与环境交互来学习如何做出决策以最大化累积奖励。强化学习被用于游戏AI、机器人控制等领域。"""
    
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        f.write(sample_data)
    print(f"✅ 示例数据已写入 {DATA_FILE}")


def create_faiss_index():
    """创建FAISS向量索引"""
    print("🔨 创建 FAISS 向量索引...")
    
    # 确保数据文件存在
    if not os.path.exists(DATA_FILE):
        create_sample_data()
    
    # 加载文档
    loader = TextLoader(DATA_FILE, encoding="utf-8")
    documents = loader.load()
    print(f"📄 已加载 {len(documents)} 个文档")
    
    # 分割文档
    text_splitter = CharacterTextSplitter(
        chunk_size=500,
        chunk_overlap=50,
        separator="\n\n"
    )
    texts = text_splitter.split_documents(documents)
    print(f"✂️  文档已分割为 {len(texts)} 个块")
    
    # 创建向量存储
    embeddings = OpenAIEmbeddings(openai_api_key=OPENAI_API_KEY)
    vectorstore = FAISS.from_documents(texts, embeddings)
    print("🧮 向量嵌入已创建")
    
    # 保存索引
    vectorstore.save_local(FAISS_INDEX_PATH)
    print(f"💾 FAISS 索引已保存到 {FAISS_INDEX_PATH}")
    
    return vectorstore


def initialize_qa_system():
    """初始化问答系统"""
    global qa_chain
    
    print("\n" + "="*50)
    print("🚀 初始化 RAG 问答系统")
    print("="*50)
    
    # 检查 API Key
    if not OPENAI_API_KEY:
        raise ValueError("❌ 错误: 未设置 OPENAI_API_KEY 环境变量")
    
    print(f"✅ OpenAI API Key 已设置 (长度: {len(OPENAI_API_KEY)})")
    
    # 检查索引是否存在
    index_file = os.path.join(FAISS_INDEX_PATH, "index.faiss")
    
    if os.path.exists(index_file):
        print(f"📦 加载现有 FAISS 索引: {index_file}")
        embeddings = OpenAIEmbeddings(openai_api_key=OPENAI_API_KEY)
        vectorstore = FAISS.load_local(
            FAISS_INDEX_PATH,
            embeddings
        )
    else:
        print("📦 FAISS 索引不存在，创建新索引...")
        vectorstore = create_faiss_index()
    
    # 初始化 LLM
    print("🤖 初始化 OpenAI LLM...")
    llm = OpenAI(
        temperature=0.7,
        openai_api_key=OPENAI_API_KEY
    )
    
    # 创建 QA chain
    print("🔗 创建检索问答链...")
    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
        return_source_documents=True
    )
    
    print("✅ RAG 问答系统初始化完成！")
    print("="*50 + "\n")


# Flask 路由
@app.route('/')
def home():
    """首页"""
    return jsonify({
        "status": "ok",
        "message": "RAG 问答系统运行中",
        "endpoints": {
            "/health": "健康检查",
            "/ask": "问答接口 (POST)",
            "/info": "系统信息"
        }
    })


@app.route('/health')
def health():
    """健康检查"""
    return jsonify({"status": "ok"})


@app.route('/info')
def info():
    """系统信息"""
    return jsonify({
        "app": "RAG 问答系统",
        "description": "基于 LangChain + FAISS + OpenAI 的检索增强生成系统",
        "version": "2.0-simplified",
        "qa_system_ready": qa_chain is not None,
        "endpoints": {
            "/": "首页",
            "/health": "健康检查",
            "/ask": "问答接口 (POST)",
            "/info": "系统信息"
        },
        "usage": {
            "method": "POST",
            "endpoint": "/ask",
            "body": {"question": "你的问题"},
            "example": {
                "question": "什么是人工智能？"
            }
        }
    })


@app.route('/ask', methods=['POST'])
def ask():
    """问答端点"""
    try:
        # 检查 QA 系统是否就绪
        if qa_chain is None:
            return jsonify({
                "error": "QA 系统未初始化",
                "message": "系统启动失败，请检查日志"
            }), 503
        
        # 获取问题
        data = request.get_json()
        if not data or 'question' not in data:
            return jsonify({
                "error": "缺少必需字段",
                "message": "请在请求体中提供 'question' 字段",
                "example": {"question": "什么是人工智能？"}
            }), 400
        
        question = data['question']
        
        if not question.strip():
            return jsonify({
                "error": "问题不能为空"
            }), 400
        
        # 执行问答
        print(f"❓ 收到问题: {question}")
        result = qa_chain({"query": question})
        print(f"✅ 回答已生成")
        
        # 提取源文档
        sources = []
        if 'source_documents' in result:
            for i, doc in enumerate(result['source_documents'], 1):
                sources.append({
                    "id": i,
                    "content": doc.page_content[:200] + "..." if len(doc.page_content) > 200 else doc.page_content
                })
        
        return jsonify({
            "question": question,
            "answer": result['result'],
            "source_documents": sources,
            "sources_count": len(sources)
        })
        
    except Exception as e:
        print(f"❌ 错误: {str(e)}")
        return jsonify({
            "error": "处理问题时出现错误",
            "message": str(e)
        }), 500


# 模块加载时立即初始化（Gunicorn 也会执行）
try:
    initialize_qa_system()
except Exception as e:
    print(f"\n初始化失败: {str(e)}")
    print("容器将启动但 QA 功能不可用\n")


if __name__ == '__main__':
    # 启动 Flask 应用（仅用于本地测试）
    port = int(os.getenv('PORT', 8080))
    print(f"启动 Flask 服务器，端口: {port}")
    app.run(host='0.0.0.0', port=port, debug=False)
