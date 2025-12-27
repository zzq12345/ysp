# Dockerfile
# 修改为3.10以支持uvicorn==0.40.0
FROM python:3.10-slim

WORKDIR /app

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY yspapp.py .
COPY ysp.txt .
COPY 说明.txt .

# 暴露端口（根据docker-compose.yml中的端口）
EXPOSE 7860

# 设置环境变量
ENV FLASK_APP=yspapp.py

# 健康检查（如果是FastAPI应用）
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#   CMD curl -f http://localhost:7860/health || exit 1

# 运行应用
CMD ["python", "yspapp.py"]
