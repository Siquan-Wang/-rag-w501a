"""
数据摄入脚本 - 将文本数据转换为向量并存储到 FAISS
"""
import os
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

# 配置
DATA_FILE = "data.txt"
FAISS_INDEX_PATH = "faiss_index"
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")


def create_vector_store():
    """创建向量存储"""
    print("🚀 开始处理数据...")
    
    # 检查 OpenAI API Key
    if not OPENAI_API_KEY:
        raise ValueError("❌ 未设置 OPENAI_API_KEY 环境变量")
    
    # 检查数据文件
    if not os.path.exists(DATA_FILE):
        raise FileNotFoundError(f"❌ 数据文件不存在: {DATA_FILE}")
    
    # 1. 加载文档
    print(f"📖 正在加载文档: {DATA_FILE}")
    loader = TextLoader(DATA_FILE, encoding='utf-8')
    documents = loader.load()
    print(f"✅ 加载了 {len(documents)} 个文档")
    
    # 2. 分割文本
    print("✂️  正在分割文本...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len,
    )
    texts = text_splitter.split_documents(documents)
    print(f"✅ 分割成 {len(texts)} 个文本块")
    
    # 3. 创建 embeddings
    print("🔮 正在创建向量嵌入...")
    embeddings = OpenAIEmbeddings(openai_api_key=OPENAI_API_KEY)
    
    # 4. 创建并保存 FAISS 向量存储
    print("💾 正在创建 FAISS 向量存储...")
    vectorstore = FAISS.from_documents(texts, embeddings)
    
    # 保存到本地
    vectorstore.save_local(FAISS_INDEX_PATH)
    print(f"✅ FAISS 索引已保存到: {FAISS_INDEX_PATH}")
    
    # 5. 测试检索
    print("\n🧪 测试向量检索...")
    query = "这是什么系统？"
    docs = vectorstore.similarity_search(query, k=2)
    print(f"查询: {query}")
    print(f"找到 {len(docs)} 个相关文档:")
    for i, doc in enumerate(docs, 1):
        print(f"\n文档 {i}:")
        print(doc.page_content[:200] + "...")
    
    print("\n✨ 数据处理完成！")


if __name__ == "__main__":
    try:
        create_vector_store()
    except Exception as e:
        print(f"\n❌ 错误: {str(e)}")
        exit(1)

