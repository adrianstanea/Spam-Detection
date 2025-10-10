# SMS Spam Detection

## Problem Statement

Unsolicited emails, including spam and phishing messages, cause significant
financial losses for individuals and organizations each year. Although various
models and techniques have been developed to automatically detect spam, none
have achieved perfect accuracy. Among these approaches, machine learning and
deep learning algorithms have shown the most promising results in improving
detection performance and adaptability.

In this project, we aim to implement several machine learning models and deep
learning algorithms to perform a comparative analysis to evaluate their
effectiveness in spam email detection.


## Dataset

### [SMS Spam Collection](https://archive.ics.uci.edu/dataset/228/sms+spam+collection)

We use the **SMS Spam Collection** from the UCI Machine Learning Repository—a public
corpus of *5,574 English SMS messages* labeled as **ham (legitimate)** or **spam (unsolicited)**.
The dataset aggregates messages from several real-world sources, including:

- **NUS SMS Corpus** (random subset of *3,375 ham*).
- **Caroline Tagg’s PhD thesis** (*450 ham*).
- **SMS Spam Corpus v0.1 Big** (*1,002 ham, 322 spam*).
- **Grumbletext** (UK user-reported spam forum).

**Format**: Distributed as a single text file, `SMSSpamCollection`, with one
message per line and two tab-separated fields: the label (`ham`/`spam`) followed by the raw message text.

**Class balance**: The corpus is imbalanced (**≈ 4,827 ham vs 747 spam**), so we will report metrics robust to imbalance (e.g., PR-AUC, F1) and use stratified splits and/or class weighting.

**Link**. https://archive.ics.uci.edu/dataset/228/sms+spam+collection



## Baselines

Keyword-based filters are widely used for SMS spam detection, but they often fail when spammers alter words (misspellings or symbol substitutions). For this reason, recent baselines typically use statistical or neural text classifiers.

### Machine Learning

Studies consistently report strong performance from simple, well-regularized text classifiers on TF-IDF or bag-of-words features:

- **Single-model baselines**: Naive Bayes (NB) and Support Vector Machines (SVM) repeatedly rank among the top classical methods for SMS spam, with SVMs and Multinomial NB often setting the reference line for new work. Several works note that adding lightweight features—e.g., message length—can yield small but consistent gains.

- **Hybrid clustering + classifier**: Using K-means to pre-structure the space and then training a supervised model can push accuracy higher. In one UCI-based study, a K-means→SVM pipeline reached 98.8% accuracy, outperforming K-means→NB and K-means→Logistic Regression (LR) variants. That work did not exhaust other clustering–classifier pairings, leaving room for further exploration, but it establishes a strong classical reference point.

- **Topic/modeling variants**: Approaches that enrich sparse SMS text (e.g., treating symbols as terms) and then apply K-Nearest Neighbors (KNN) against TF-IDF representations have shown improvements over standard topic models like LDA on small SMS corpora.

Overall, the classical baseline picture is clear: Multinomial NB and linear SVM on TF-IDF are robust, fast, and highly competitive; hybrids can add a small margin on certain datasets.


### Deep Learning

When evaluated on common SMS datasets, deep models consistently yield results that are close to the highest possible scores.

- **Convolutional and recurrent models**: On two benchmark-style datasets (UCI/Kaggle-like with ~5.6k messages, and a ~2k message set), CNN classifiers have achieved up to 99.10% accuracy using text-only inputs.

- **Bidirectional LSTM (BiLSTM)**: A Word2Vec-initialized BiLSTM surpassed several classical baselines (BayesNet, J48/Decision Tree, NB, SVM, KNN) and reached 98.6% accuracy, albeit with heavier preprocessing (e.g., manual abbreviation normalization).

- **CNN/LSTM ensembles**: Text-only CNN/LSTM configurations have been reported at 99.44% accuracy in a dedicated “Deep Learning to Filter SMS Spam” setting.

These results suggest that although deep models can outperform classical methods on standard datasets, the margin is often small compared to well-tuned TF−IDF + linear baselines. This narrow advantage becomes even more significant when considering the practical costs of training, preprocessing, and deployment.

