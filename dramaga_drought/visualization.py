from __future__ import annotations

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def plot_classification_confusion_matrix(confusion_matrix, labels: list[str] | None = None):
    class_labels = labels or ["Normal", "Ringan", "Sedang", "Parah"]
    fig, ax = plt.subplots(figsize=(7, 5))
    normalized = confusion_matrix.astype("float") / confusion_matrix.sum(axis=1)[:, None]
    sns.heatmap(
        normalized,
        annot=True,
        fmt=".1%",
        cmap="YlOrRd",
        xticklabels=class_labels,
        yticklabels=class_labels,
        ax=ax,
    )
    ax.set_title("Normalized Confusion Matrix")
    ax.set_xlabel("Predicted Class")
    ax.set_ylabel("True Class")
    fig.tight_layout()
    return fig, ax


def plot_feature_importance(model, features: list[str], top_n: int = 20):
    importances = getattr(model, "feature_importances_", None)
    if importances is None:
        raise AttributeError("Model does not expose feature_importances_")

    importance = pd.Series(importances, index=features).sort_values(ascending=False).head(top_n)
    fig, ax = plt.subplots(figsize=(8, 6))
    sns.barplot(x=importance.values, y=importance.index, color="#d35400", ax=ax)
    ax.set_title("Feature Importance")
    ax.set_xlabel("Relative Importance")
    ax.set_ylabel("")
    fig.tight_layout()
    return fig, ax


def plot_risk_forecast(test_df: pd.DataFrame, target_col: str, threshold: float, horizon: int = 30):
    fig, ax1 = plt.subplots(figsize=(16, 5))
    ax1.plot(
        test_df["date"],
        test_df["risk_proba_next_30d"],
        color="#d35400",
        linewidth=1.3,
        label="Probabilitas risiko sedang+",
    )
    ax1.axhline(threshold, color="black", linestyle="--", linewidth=1, label=f"Threshold {threshold:.2f}")
    ax1.set_ylabel("Probabilitas risiko")
    ax1.set_ylim(-0.02, 1.02)

    ax2 = ax1.twinx()
    ax2.fill_between(
        test_df["date"],
        0,
        test_df[target_col],
        step="post",
        color="#2c7fb8",
        alpha=0.18,
        label="Aktual ada risiko sedang+",
    )
    ax2.set_ylabel("Aktual risiko")
    ax2.set_yticks([0, 1])
    ax2.set_yticklabels(["Tidak", "Ya"])

    lines_1, labels_1 = ax1.get_legend_handles_labels()
    lines_2, labels_2 = ax2.get_legend_handles_labels()
    ax1.legend(lines_1 + lines_2, labels_1 + labels_2, loc="upper left")
    ax1.set_title(f"Forecast Risiko Kekeringan Minimal Sedang dalam {horizon} Hari ke Depan")
    ax1.set_xlabel("Tanggal")
    ax1.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig, (ax1, ax2)
