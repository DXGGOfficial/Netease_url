# 基础镜像保持 alpine（体积优势）
FROM python:3.12-alpine

WORKDIR /app

# 关键：添加 ca-certificates 解决 HTTPS 证书问题
# 同时保留构建依赖的安装与清理逻辑
RUN apk add --no-cache \
    # 解决 SSL 证书问题（必须添加）
    ca-certificates \
    # 运行时依赖
    libffi-dev \
    openssl-dev \
    tzdata \
    # 临时构建工具
    gcc \
    musl-dev \
    && \
    # 配置时区
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    # 删除构建工具
    apk del gcc musl-dev && \
    # 清理缓存
    rm -rf /var/cache/apk/*

# 拷贝依赖文件
COPY requirements.txt .

# 安装 Python 依赖（清华源保持不变，证书问题已解决）
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple && \
    pip3 install --no-cache-dir --default-timeout=200 -r requirements.txt

# 拷贝项目文件（配合 .dockerignore 排除冗余）
COPY . .

# 修正 entrypoint 权限
RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# 环境变量
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

EXPOSE 5000

CMD ["/app/entrypoint.sh"]