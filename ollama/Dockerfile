FROM runpod/base:1.0.3-cuda1300-ubuntu2404

ARG OLLAMA_VERSION=0.24.0
ENV OLLAMA_MODELS=/workspace/.ollama/models
ENV OLLAMA_HOST=0.0.0.0:11434

# Install Ollama using the official method (extracts bin/ + lib/ to /usr)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    zstd \
    && curl -fsSL "https://github.com/ollama/ollama/releases/download/v${OLLAMA_VERSION}/ollama-linux-amd64.tar.zst" \
        | tar --zstd -xC /usr \
    && rm -rf /var/lib/apt/lists/*

COPY start-ollama.sh /start-ollama.sh
RUN chmod +x /start-ollama.sh

CMD ["/start-ollama.sh"]
