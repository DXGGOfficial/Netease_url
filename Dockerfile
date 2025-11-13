FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖 + pip源 + 时区
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 拷贝依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip3 install --no-cache-dir --default-timeout=200 -r requirements.txt

# 拷贝整个项目
COPY . .

# 修正Windows换行符（如有）
RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# 设置环境变量
ENV TZ=Asia/Shanghai \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["/app/entrypoint.sh"]
