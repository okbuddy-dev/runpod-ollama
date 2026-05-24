# runpod-ollama

RunPod serverless-compatible container images for running LLM inference engines.

## Engines

| Engine | Image | Directory |
|--------|-------|-----------|
| [Ollama](https://ollama.com/) v0.24.0 | `ghcr.io/<owner>/runpod-ollama/ollama` | [`ollama/`](ollama/) |

Each engine image is built from RunPod's official CUDA base image and published
to GitHub Container Registry via GitHub Actions.

## Ollama

- Based on [RunPod's official base image](https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile) (`runpod/base:1.0.3-cuda1300-ubuntu2404`)
- Auto-pulls `qwen2.5:0.5b` on first start (cached in `/workspace/.ollama/models`)
- Exposes Ollama API on `0.0.0.0:11434`

## Base image

This project is built on top of the RunPod base container template:

**https://github.com/runpod/containers/blob/main/official-templates/base/Dockerfile**

The base image provides the CUDA runtime, Python, Jupyter, and all the scaffolding needed for serverless and GPU pod deployments on RunPod.

## Build locally

```bash
# Build Ollama image
docker build -t runpod-ollama:local -f ollama/Dockerfile ollama/

# Run locally
docker run --rm -it -p 11434:11434 runpod-ollama:local
```

## Usage on RunPod

1. Pull the image from GHCR (e.g. `ghcr.io/<owner>/runpod-ollama/ollama:latest`)
2. Create a serverless endpoint or GPU pod using the image
3. The engine starts automatically and pulls its default model
4. The API is available at the engine's port (e.g. `11434` for Ollama)

## GitHub Actions

The CI workflow uses a **matrix strategy** to build and publish all engine images.
To add a new engine (e.g. `llamacpp`), create its directory with a `Dockerfile`
and add one entry to the matrix in `.github/workflows/docker-publish.yml`:

```yaml
matrix:
  image:
    - name: ollama
      context: ollama
      file: ollama/Dockerfile
    - name: llamacpp       # ← add this
      context: llamacpp
      file: llamacpp/Dockerfile
```

The resulting image will be published as `ghcr.io/<owner>/runpod-ollama/llamacpp`.

Pushes to `main` (affecting any engine directory or the workflow file) trigger
builds. You can also manually dispatch a single image via the Actions tab.
