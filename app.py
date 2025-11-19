"""
RAG (Retrieval-Augmented Generation) Flask 应用
使用 LangChain + FAISS + OpenAI 实现问答系统
"""
import os
from flask import Flask, request, jsonify
from langchain_community.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings
from langchain.llms import OpenAI
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate
from langchain.text_splitter import CharacterTextSplitter
from langchain_community.document_loaders import TextLoader

app = Flask(__name__)

# 配置
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
FAISS_INDEX_PATH = "faiss_index"

# 初始化全局变量
qa_chain = None
_initialized = False


def initialize_qa_chain():
    """初始化 QA 链"""
    global qa_chain
    
    try:
        # 初始化 OpenAI Embeddings
        embeddings = OpenAIEmbeddings(
            openai_api_key=OPENAI_API_KEY
        )
        
        # 加载 FAISS 向量数据库
        vectorstore = FAISS.load_local(
            FAISS_INDEX_PATH,
            embeddings,
            allow_dangerous_deserialization=True
        )
        
        # 初始化 LLM
        llm = OpenAI(
            temperature=0.7,
            openai_api_key=OPENAI_API_KEY
        )
        
        # 创建自定义 prompt
        prompt_template = """使用以下上下文来回答问题。如果你不知道答案，就说不知道，不要试图编造答案。

上下文: {context}

问题: {question}

详细回答:"""
        
        PROMPT = PromptTemplate(
            template=prompt_template,
            input_variables=["context", "question"]
        )
        
        # 创建 QA 链
        qa_chain = RetrievalQA.from_chain_type(
            llm=llm,
            chain_type="stuff",
            retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
            return_source_documents=True,
            chain_type_kwargs={"prompt": PROMPT}
        )
        
        print("✅ QA Chain 初始化成功！")
        
    except Exception as e:
        print(f"❌ 初始化 QA Chain 失败: {str(e)}")
        raise


@app.route('/')
def home():
    """健康检查端点"""
    return jsonify({
        "status": "healthy",
        "message": "RAG 问答系统正在运行",
        "version": "1.0.0"
    })


@app.route('/health')
def health():
    """健康检查端点"""
    return jsonify({"status": "ok"})


@app.route('/status')
def status():
    """系统状态检查端点"""
    return jsonify({
        "initialized": _initialized,
        "qa_chain_ready": qa_chain is not None,
        "openai_api_key_set": OPENAI_API_KEY is not None and OPENAI_API_KEY != "",
        "faiss_index_exists": os.path.exists(FAISS_INDEX_PATH),
        "data_file_exists": os.path.exists("data.txt")
    })


@app.route('/ask', methods=['POST'])
def ask():
    """问答端点"""
    try:
        # 确保系统已初始化
        ensure_initialized()
        
        # 检查 QA chain 是否初始化
        if qa_chain is None:
            return jsonify({
                "error": "QA 系统未初始化",
                "message": "知识库初始化失败，请检查配置",
                "suggestion": "请确保 OPENAI_API_KEY 已正确配置"
            }), 503
        
        # 获取问题
        data = request.get_json()
        if not data or 'question' not in data:
            return jsonify({
                "error": "请提供 'question' 字段"
            }), 400
        
        question = data['question']
        
        if not question.strip():
            return jsonify({
                "error": "问题不能为空"
            }), 400
        
        # 执行问答
        result = qa_chain({"query": question})
        
        # 提取源文档
        sources = []
        if 'source_documents' in result:
            sources = [
                {
                    "content": doc.page_content[:200] + "...",
                    "metadata": doc.metadata
                }
                for doc in result['source_documents']
            ]
        
        return jsonify({
            "question": question,
            "answer": result['result'],
            "sources": sources
        })
    
    except Exception as e:
        return jsonify({
            "error": f"处理问题时出错: {str(e)}"
        }), 500


@app.route('/info')
def info():
    """系统信息端点"""
    return jsonify({
        "app": "RAG 问答系统",
        "description": "基于 LangChain + FAISS + OpenAI 的检索增强生成系统",
        "endpoints": {
            "/": "健康检查",
            "/health": "健康状态",
            "/ask": "问答接口 (POST)",
            "/info": "系统信息"
        },
        "usage": {
            "method": "POST",
            "endpoint": "/ask",
            "body": {
                "question": "你的问题"
            }
        }
    })


def ensure_initialized():
    """确保系统已初始化（只执行一次）"""
    global _initialized
    if _initialized:
        return
    
    print("🚀 正在初始化 RAG 问答系统...")
    
    if not OPENAI_API_KEY:
        print("⚠️ 警告: 未设置 OPENAI_API_KEY 环境变量")
        _initialized = True
        return
    
    # 创建索引
    create_sample_index_if_needed()
    
    # 初始化 QA chain
    if os.path.exists(FAISS_INDEX_PATH):
        initialize_qa_chain()
    
    _initialized = True
    print("✅ RAG 问答系统初始化完成")


def create_sample_index_if_needed():
    """如果索引不存在，创建一个示例索引"""
    if os.path.exists(FAISS_INDEX_PATH):
        return
    
    try:
        print("📝 FAISS 索引不存在，正在创建示例索引...")
        
        # 检查 data.txt 是否存在
        if not os.path.exists("data.txt"):
            # 创建示例数据
            sample_data = """人工智能（AI）是计算机科学的一个分支，致力于创建能够执行通常需要人类智能的任务的系统。

机器学习是人工智能的一个子集，它使计算机能够从数据中学习并改进，而无需明确编程。

深度学习是机器学习的一个子集，使用神经网络来模拟人脑的工作方式。

自然语言处理（NLP）是人工智能的一个领域，专注于使计算机能够理解、解释和生成人类语言。

计算机视觉是人工智能的一个领域，使计算机能够从数字图像或视频中获取高级理解。"""
            
            with open("data.txt", "w", encoding="utf-8") as f:
                f.write(sample_data)
            print("✅ 创建了示例数据文件 data.txt")
        
        # 加载文档
        loader = TextLoader("data.txt", encoding="utf-8")
        documents = loader.load()
        
        # 分割文档
        text_splitter = CharacterTextSplitter(
            chunk_size=500,
            chunk_overlap=50,
            separator="\n\n"
        )
        texts = text_splitter.split_documents(documents)
        
        # 创建向量存储
        embeddings = OpenAIEmbeddings(openai_api_key=OPENAI_API_KEY)
        vectorstore = FAISS.from_documents(texts, embeddings)
        
        # 保存索引
        vectorstore.save_local(FAISS_INDEX_PATH)
        print(f"✅ FAISS 索引已创建并保存到 {FAISS_INDEX_PATH}")
        
    except Exception as e:
        print(f"❌ 创建 FAISS 索引失败: {str(e)}")


if __name__ == '__main__':
    # 启动时初始化 QA chain
    print("🚀 正在启动 RAG 问答系统...")
    
    # 检查 OpenAI API Key
    if not OPENAI_API_KEY:
        print("⚠️  警告: 未设置 OPENAI_API_KEY 环境变量")
    else:
        # 如果索引不存在，创建它
        create_sample_index_if_needed()
        
        # 初始化 QA chain
        if os.path.exists(FAISS_INDEX_PATH):
            initialize_qa_chain()
        else:
            print(f"⚠️  警告: FAISS 索引目录不存在: {FAISS_INDEX_PATH}")
    
    # 启动 Flask 应用
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)

