#!/bin/bash
set -e

export OLLAMA_MODELS=/workspace/.ollama/models
export OLLAMA_HOST=0.0.0.0:11434

mkdir -p "${OLLAMA_MODELS}"
LOGS_DIR="${OLLAMA_MODELS}/../logs"
mkdir -p "${LOGS_DIR}"

ollama serve >> "${LOGS_DIR}/server.log" 2>&1 &
Ollama_PID=$!

echo "Ollama started with PID $OLLAMA_PID"

sleep 2

if ! kill -0 "$OLLAMA_PID" 2>/dev/null; then
    echo "ERROR: ollama serve failed to start. Check logs at ${LOGS_DIR}/server.log"
    exit 1
fi

if ollama list | awk '{print $1}' | grep -qx "qwen2.5:0.5b"; then
    echo "qwen2.5:0.5b is already cached"
else
    echo "Pulling qwen2.5:0.5b..."
    ollama pull qwen2.5:0.5b
fi

exec /start.sh