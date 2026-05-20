#!/bin/bash
# Start Ollama alongside RunPod's base startup script.
# Designed to be resilient: Ollama failures are logged but never
# prevent the container from starting, so SSH / web terminal remain
# accessible for debugging.

set -u  # catch unset variables, but do NOT use set -e (we handle errors here)

OLLAMA_MODELS="${OLLAMA_MODELS:-/workspace/.ollama/models}"
OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0:11434}"

export OLLAMA_MODELS OLLAMA_HOST

LOGS_DIR="${OLLAMA_MODELS%/models}/logs"
mkdir -p "${OLLAMA_MODELS}" "${LOGS_DIR}"

log() {
    echo "[start-ollama] $(date '+%Y-%m-%d %H:%M:%S') $*"
}

# ── Start ollama serve with retries ──────────────────────────────────
MAX_RETRIES=5
RETRY_DELAY=4   # seconds — doubles on each retry

ollama_started=false
for i in $(seq 1 "$MAX_RETRIES"); do
    log "Starting ollama serve (attempt $i/$MAX_RETRIES)..."

    # Kill any stale ollama process
    pkill -f "ollama serve" 2>/dev/null || true
    sleep 1

    # Start ollama in background, logging to file
    ollama serve >> "${LOGS_DIR}/server.log" 2>&1 &
    PID=$!
    log "Spawned ollama PID $PID"

    # Wait with increasing backoff then check it's still alive and serving
    wait_sec=$((RETRY_DELAY * (2 ** (i - 1))))
    sleep "$wait_sec"

    if ! kill -0 "$PID" 2>/dev/null; then
        log "ollama serve exited prematurely (attempt $i). Last 5 lines of server log:"
        tail -n 5 "${LOGS_DIR}/server.log" | while read -r line; do log "  >> $line"; done
        continue
    fi

    # Verify the API is actually responding
    if curl -sf "http://127.0.0.1:11434/api/tags" > /dev/null 2>&1; then
        log "ollama serve is healthy (PID $PID, port 11434)"
        ollama_started=true
        break
    fi

    log "ollama process is alive but API not responding yet (attempt $i)"
done

if ! $ollama_started; then
    log "WARNING: ollama serve failed to start after $MAX_RETRIES attempts."
    log "WARNING: RunPod connectivity (SSH, web terminal) will work; Ollama will not."
    log "WARNING: Check logs at ${LOGS_DIR}/server.log"
    # Do NOT exit — let the container stay up for debugging.
else
    # ── Pull default model (fire-and-forget in background) ───────────
    (
        if ollama list | awk '{print $1}' | grep -qx "qwen2.5:0.5b"; then
            log "qwen2.5:0.5b is already cached"
        else
            log "Pulling qwen2.5:0.5b (this may take several minutes)..."
            if ollama pull qwen2.5:0.5b; then
                log "qwen2.5:0.5b pulled successfully"
            else
                log "WARNING: failed to pull qwen2.5:0.5b — you can pull it manually later"
            fi
        fi
    ) &
fi

# ── Hand control to RunPod's standard startup ────────────────────────
log "Launching RunPod base startup (PID 1)..."
exec /start.sh
