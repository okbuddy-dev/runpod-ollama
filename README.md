# runpod-ollama

RunPod serverless-compatible container image with Ollama pre-installed, automatically pulling the `qwen2.5:0.5b` model on startup.

## What's inside

- [Ollama](https://ollama.com/) v0.24.0 — run LLMs locally
- Based on [RunPod's official base image](https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile) (`runpod/base:1.0.2-cuda1280-ubuntu2404`)
- Auto-pulls `qwen2.5:0.5b` on first start (cached in `/workspace/.ollama/models`)
- Exposes Ollama API on `0.0.0.0:11434`

## Base image

This project is built on top of the RunPod base container template:

**https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile**

The base image provides the CUDA runtime, Python, Jupyter, and all the scaffolding needed for serverless and GPU pod deployments on RunPod.

## Build locally

```bash
# Build the image
docker build -t runpod-ollama:local -f docker/Dockerfile docker/

# Run locally
docker run --rm -it -p 11434:11434 runpod-ollama:local
```

## Usage on RunPod

1. Push the image to a registry (GHCR is configured via GitHub Actions)
2. Create a serverless endpoint or GPU pod using the image
3. Ollama starts automatically and pulls `qwen2.5:0.5b`
4. The Ollama API is available at port `11434`

## GitHub Actions

Pushes to `main` (affecting `docker/**` or the workflow file) automatically build and publish the image to `ghcr.io/<repo-owner>/runpod-ollama`.
