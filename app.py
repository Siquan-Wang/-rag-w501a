"""
RAG (Retrieval-Augmented Generation) Flask 应用
使用 LangChain + FAISS + OpenAI 实现问答系统
"""
import os
from flask import Flask, request, jsonify
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate

app = Flask(__name__)

# 配置
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
FAISS_INDEX_PATH = "faiss_index"

# 初始化全局变量
qa_chain = None


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
        llm = ChatOpenAI(
            model_name="gpt-3.5-turbo",
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


@app.route('/ask', methods=['POST'])
def ask():
    """问答端点"""
    try:
        # 检查 QA chain 是否初始化
        if qa_chain is None:
            return jsonify({
                "error": "QA 系统未初始化"
            }), 500
        
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


if __name__ == '__main__':
    # 启动时初始化 QA chain
    print("🚀 正在启动 RAG 问答系统...")
    
    # 检查 OpenAI API Key
    if not OPENAI_API_KEY:
        print("⚠️  警告: 未设置 OPENAI_API_KEY 环境变量")
    
    # 检查 FAISS 索引是否存在
    if not os.path.exists(FAISS_INDEX_PATH):
        print(f"⚠️  警告: FAISS 索引目录不存在: {FAISS_INDEX_PATH}")
        print("请先运行 ingest.py 创建向量索引")
    else:
        initialize_qa_chain()
    
    # 启动 Flask 应用
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)

