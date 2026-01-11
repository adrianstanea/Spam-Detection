import os
import joblib
import nltk
import torch
from fastapi import FastAPI
from typing import Literal
from pydantic import BaseModel, ConfigDict
import uvicorn
from sentence_transformers import SentenceTransformer
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize

nltk.download("punkt")
nltk.download("punkt_tab")
nltk.download("stopwords")


def get_device():
    """Detect and return the best available device."""
    device_env = os.getenv("DEVICE", "").lower()

    if device_env in ["cpu", "cuda", "mps"]:
        return device_env

    # Auto-detect
    if torch.cuda.is_available():
        return "cuda"
    elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
        return "mps"
    else:
        return "cpu"


class SpamRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    text: str


class PredictResponse(BaseModel):
    prediction_index: int
    label: Literal["spam", "ham"]


app = FastAPI(title="Spam-Ham AI Classifier")

# Detect device
device = get_device()
print(f"Using device: {device}")

rfc = joblib.load(os.getenv("MODEL_PATH"))

embedding_model = SentenceTransformer(
    "google/embeddinggemma-300m",
    token=os.getenv("HUGGINGFACE_HUB_TOKEN"),
    device=device,
).eval()


def preprocess_text(text: str) -> str:
    words = word_tokenize(text)
    words = [word.lower() for word in words if word.isalnum()]
    stop_words = set(stopwords.words("english"))
    words = [word for word in words if word not in stop_words]
    return " ".join(words)


def get_prediction(raw_text: str):
    # 1. Clean
    cleaned_text = preprocess_text(raw_text)

    # 2. Obtain embedding
    vector = embedding_model.encode(
        [cleaned_text], prompt_name="Classification", normalize_embeddings=True
    )

    # 3. Predict
    idx = int(rfc.predict(vector)[0])
    return idx


@app.post("/predict")
def predict(request: SpamRequest) -> PredictResponse:
    prediction_index = get_prediction(request.text)
    label: Literal["spam", "ham"] = "spam" if prediction_index == 0 else "ham"

    return PredictResponse(prediction_index=prediction_index, label=label)


if __name__ == "__main__":
    uvicorn.run(
        app,
        host=os.getenv("UVICORN_HOST", "0.0.0.0"),
        port=int(os.getenv("UVICORN_PORT", "9696")),
    )
