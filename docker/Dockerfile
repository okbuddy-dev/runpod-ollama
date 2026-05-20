FROM runpod/base:1.0.2-cuda1300-ubuntu2404

ARG OLLAMA_VERSION=0.24.0
ENV OLLAMA_MODELS=/workspace/.ollama/models
ENV OLLAMA_HOST=0.0.0.0:11434

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    zstd \
    && curl -fsSL "https://github.com/ollama/ollama/releases/download/v${OLLAMA_VERSION}/ollama-linux-amd64.tar.zst" -o /tmp/ollama.tar.zst \
    && mkdir /tmp/ollama \
    && tar -I zstd -xf /tmp/ollama.tar.zst -C /tmp/ollama \
    && cp /tmp/ollama/bin/ollama /usr/local/bin/ollama \
    && chmod +x /usr/local/bin/ollama \
    && rm -rf /tmp/ollama /tmp/ollama.tar.zst /var/lib/apt/lists/*

COPY start-ollama.sh /start-ollama.sh
RUN chmod +x /start-ollama.sh

CMD ["/start-ollama.sh"]