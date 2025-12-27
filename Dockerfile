# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# 设置时区和语言环境
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

# 设置 pip 镜像源为阿里云
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip config set global.trusted-host mirrors.aliyun.com

# 复制依赖文件并安装 Python 包
COPY requirements.txt .
RUN echo "开始安装依赖..." \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && echo "依赖安装完成!"

# 验证安装
RUN python -c "import fastapi, uvicorn, construct, requests; print('所有包导入成功')"

# 复制应用代码
COPY yspapp.py .

# 创建非root用户
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8080/docs', timeout=2)" || exit 1

# 运行应用
CMD ["python", "yspapp.py"]
