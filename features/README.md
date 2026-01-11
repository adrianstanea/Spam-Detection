# Feature Engineering

## TF-IDF

- Features are stored using a sparse representation. Make sure to use appropriate
  loader from `scipy.sparse`.

### How to use

```python
from pathlib import Path

import numpy as np
import scipy.sparse as sp

features_path = Path("features/tf-idf")
X = sp.load_npz(features_path / "features.npz")
y = np.load(features_path / "labels.npy")
```

## TF-IDF + LSA

### How to use

```python
from pathlib import Path

import numpy as np

features_path = Path("features/tf-idf")
X = np.load_npz(features_path / "features.npy")
y = np.load(features_path / "labels.npy")
```

## Vector Embeddings

Embeddings were generated with a Sentence transformer model.

For more details see [EmbeddingGemma model](https://huggingface.co/google/embeddinggemma-300m)

### How to use

```python
from pathlib import Path

import numpy as np

features_path = Path("features/vector-embeddings")
X = np.load_npz(features_path / "features.npy")
y = np.load(features_path / "labels.npy")
```
