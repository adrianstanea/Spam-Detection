# syntax=docker/dockerfile:1.7

ARG PYTHON_IMAGE=python:3.12.12-slim-bookworm
ARG UV_IMAGE=ghcr.io/astral-sh/uv:latest

FROM ${UV_IMAGE} AS uv_tools

# ==============================================================================
# Runtime Stage
# ==============================================================================
FROM ${PYTHON_IMAGE} AS runtime
ENV VIRTUAL_ENV=/code/.venv
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

# Provide uv tooling
COPY --from=uv_tools /uv /uvx /bin/

WORKDIR /code

COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --locked --only-group api

# Create directories for model cache and huggingface cache
RUN mkdir -p /code/models /root/.cache/huggingface
COPY models/model.joblib ${MODEL_PATH}

# Pre-download NLTK data and Hugging Face model to cache
RUN --mount=type=cache,target=/root/nltk_data \
    python -c "import nltk; nltk.data.path.append('/root/nltk_data'); nltk.download('punkt'); nltk.download('stopwords'); nltk.download('punkt_tab')"

RUN --mount=type=secret,id=huggingface_hub_token \
    --mount=type=cache,target=/root/.cache/huggingface \
    HUGGINGFACE_HUB_TOKEN=$(cat /run/secrets/huggingface_hub_token) \
    python -c "import os; from sentence_transformers import SentenceTransformer; os.environ['HF_HOME']='/root/.cache/huggingface'; SentenceTransformer('google/embeddinggemma-300m', token=os.getenv('HUGGINGFACE_HUB_TOKEN'))"

# Set environment variables from args
ENV UVICORN_HOST=${UVICORN_HOST}
ENV UVICORN_PORT=${UVICORN_PORT}
ENV MODEL_PATH=${MODEL_PATH}
ENV HUGGINGFACE_HOME=${HUGGINGFACE_HOME}
ENV HF_HOME=${HF_HOME}

COPY app ./app

WORKDIR /code/app
EXPOSE 9696

ENTRYPOINT ["sh", "-c", "uvicorn main:app --host ${UVICORN_HOST:-0.0.0.0} --port ${UVICORN_PORT:-9696}"]
