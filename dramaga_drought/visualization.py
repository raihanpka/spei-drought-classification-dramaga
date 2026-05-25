from __future__ import annotations

import matplotlib.pyplot as plt
import numpy as np
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
    ax1.legend(lines_1 + labels_1, labels_1 + labels_2, loc="upper left")
    ax1.set_title(f"Forecast Risiko Kekeringan Minimal Sedang dalam {horizon} Hari ke Depan")
    ax1.set_xlabel("Tanggal")
    ax1.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig, (ax1, ax2)


def plot_severity_trend(df: pd.DataFrame, actual_col: str, pred_col: str, window: int = 30):
    smoothed_actual = df[actual_col].rolling(window=window, min_periods=1).mean()
    smoothed_pred = df[pred_col].rolling(window=window, min_periods=1).mean()

    fig, ax = plt.subplots(figsize=(16, 6))
    ax.plot(df["date"], smoothed_actual, label="Aktual (30-day Moving Avg)", color="black", linewidth=1.5)
    ax.plot(df["date"], smoothed_pred, label="Prediksi Model", color="#d35400", linewidth=1.5)
    ax.fill_between(df["date"], 0, smoothed_pred, color="#d35400", alpha=0.25)
    ax.axhline(y=1.5, color="gray", linestyle="--", alpha=0.6, label="Batas Kekeringan Signifikan (> Moderate)")

    ax.set_title(f"Tren Keparahan Kekeringan: Aktual vs Prediksi (Smoothed {window}-Days)", fontsize=15, pad=15)
    ax.set_xlabel("Tahun", fontsize=12)
    ax.set_ylabel("Rata-rata Kelas Keparahan (0-3)", fontsize=12)
    ax.set_yticks([0, 1, 2, 3])
    ax.set_yticklabels(["0 (Normal)", "1 (Ringan)", "2 (Sedang)", "3 (Parah)"])
    ax.legend(loc="upper right")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig, ax


def plot_yearly_distribution(df: pd.DataFrame, class_col: str):
    yearly_dist = df.groupby([df["date"].dt.year, class_col]).size().unstack(fill_value=0)
    yearly_dist_pct = yearly_dist.div(yearly_dist.sum(axis=1), axis=0) * 100

    colors = ["#2ca02c", "#f1c40f", "#e67e22", "#d35400"]
    fig, ax = plt.subplots(figsize=(14, 6))
    yearly_dist_pct.plot(kind="bar", stacked=True, color=colors, ax=ax, width=0.75)

    ax.set_title("Proporsi Hari Kekeringan per Tahun", fontsize=14, pad=15)
    ax.set_xlabel("Tahun", fontsize=12)
    ax.set_ylabel("Persentase Hari dalam Setahun (%)", fontsize=12)
    ax.legend(
        ["0 (Normal)", "1 (Ringan)", "2 (Sedang)", "3 (Parah)"],
        loc="center left",
        bbox_to_anchor=(1.02, 0.5),
        title="Kelas Kekeringan",
    )
    plt.xticks(rotation=45)
    fig.tight_layout()
    return fig, ax


def plot_calendar_heatmap(df: pd.DataFrame, class_col: str, year: int):
    year_df = df[df["date"].dt.year == year].copy()
    if year_df.empty:
        return None

    year_df["month"] = year_df["date"].dt.month
    year_df["day"] = year_df["date"].dt.day

    pivot = year_df.pivot(index="month", columns="day", values=class_col)

    fig, ax = plt.subplots(figsize=(12, 6))
    sns.heatmap(
        pivot,
        cmap="YlOrRd",
        annot=False,
        cbar_kws={"label": "Kelas Kekeringan"},
        linewidths=0.5,
        ax=ax,
    )

    ax.set_title(f"Kalender Kelas Kekeringan Tahun {year}", fontsize=14)
    ax.set_xlabel("Hari dalam Bulan")
    ax.set_ylabel("Bulan")
    ax.set_yticks(np.arange(12) + 0.5)
    ax.set_yticklabels(
        ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"], rotation=0
    )
    fig.tight_layout()
    return fig, ax


def plot_spei_time_series(df: pd.DataFrame, spei_col: str = "spei_30d"):
    fig, ax = plt.subplots(figsize=(16, 5))
    ax.plot(df["date"], df[spei_col], color="black", linewidth=0.8, alpha=0.7)

    # Highlight areas
    ax.axhline(-0.5, color="#f1c40f", linestyle="--", alpha=0.5, label="Mild Drought (<-0.5)")
    ax.axhline(-1.0, color="#e67e22", linestyle="--", alpha=0.5, label="Moderate Drought (<-1.0)")
    ax.axhline(-1.5, color="#d35400", linestyle="--", alpha=0.5, label="Severe Drought (<-1.5)")

    ax.fill_between(df["date"], df[spei_col], -0.5, where=(df[spei_col] < -0.5), color="#f1c40f", alpha=0.3)
    ax.fill_between(df["date"], df[spei_col], -1.0, where=(df[spei_col] < -1.0), color="#e67e22", alpha=0.3)
    ax.fill_between(df["date"], df[spei_col], -1.5, where=(df[spei_col] < -1.5), color="#d35400", alpha=0.3)

    ax.set_title(f"Time Series {spei_col.upper()} dengan Highlight Kelas Kekeringan", fontsize=15)
    ax.set_xlabel("Tahun")
    ax.set_ylabel(spei_col.upper())
    ax.legend(loc="lower left")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig, ax


def plot_decade_distribution(df: pd.DataFrame, class_col: str):
    df = df.copy()
    df["decade"] = (df["date"].dt.year // 10) * 10
    df["decade"] = df["decade"].astype(str) + "an"

    decade_dist = df.groupby(["decade", class_col]).size().unstack(fill_value=0)
    decade_dist_pct = decade_dist.div(decade_dist.sum(axis=1), axis=0) * 100

    colors = ["#2ca02c", "#f1c40f", "#e67e22", "#d35400"]
    fig, ax = plt.subplots(figsize=(10, 6))
    decade_dist_pct.plot(kind="bar", stacked=True, color=colors, ax=ax, width=0.6)

    ax.set_title("Distribusi Kelas Kekeringan per Dekade", fontsize=14)
    ax.set_xlabel("Dekade")
    ax.set_ylabel("Persentase Hari (%)")
    ax.legend(["Normal", "Ringan", "Sedang", "Parah"], title="Kelas", loc="upper right")
    plt.xticks(rotation=0)
    fig.tight_layout()
    return fig, ax
