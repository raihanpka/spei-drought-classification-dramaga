from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def main() -> None:
    root = Path.cwd()
    data_dir = root / "data"
    fig_dir = root / "docs" / "figures"
    fig_dir.mkdir(parents=True, exist_ok=True)

    sns.set_theme(style="whitegrid", palette="muted")
    plt.rcParams.update({"figure.dpi": 140, "font.size": 10, "axes.titlesize": 12, "axes.labelsize": 10})

    raw_path = data_dir / "dataset_iklim_dramaga_1980_2024_completed.csv"
    feat_path = data_dir / "dataset_featured_dramaga.csv"

    if not raw_path.exists():
        raise SystemExit(f"Missing file: {raw_path}")
    if not feat_path.exists():
        raise SystemExit(f"Missing file: {feat_path}")

    # Figure 1: Tren suhu & curah hujan (data awal)
    raw = pd.read_csv(raw_path)
    raw["date"] = pd.to_datetime(raw["date"], utc=True)
    raw["date"] = raw["date"].dt.tz_convert("Asia/Jakarta").dt.normalize()
    raw["date"] = raw["date"].dt.tz_localize(None)
    raw = raw.sort_values("date").set_index("date")

    monthly = raw.resample("MS").agg({
        "temperature_2m_mean": "mean",
        "precipitation_sum": "sum",
    })

    fig, ax1 = plt.subplots(figsize=(12, 4.8))
    ax1.plot(monthly.index, monthly["temperature_2m_mean"], color="crimson", lw=1.2, label="Suhu rata-rata bulanan")
    ax1.set_ylabel("Suhu (°C)")
    ax1.set_title("Tren Suhu dan Curah Hujan Bulanan Dramaga (1980-2024)")

    ax2 = ax1.twinx()
    ax2.bar(monthly.index, monthly["precipitation_sum"], width=25, color="steelblue", alpha=0.45, label="Curah hujan bulanan")
    ax2.set_ylabel("Curah hujan (mm/bulan)")

    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc="upper left", fontsize=8)
    fig.tight_layout()
    fig.savefig(fig_dir / "eda_trend_suhu_hujan.png", dpi=180)
    plt.close(fig)

    # Figure 2: Heatmap korelasi variabel iklim
    cols = [
        "temperature_2m_mean",
        "temperature_2m_max",
        "temperature_2m_min",
        "precipitation_sum",
        "et0_fao_evapotranspiration",
        "relative_humidity_2m_mean",
        "soil_moisture_0_to_7cm_mean",
    ]

    corr = raw[cols].corr()
    fig, ax = plt.subplots(figsize=(8.8, 6.8))
    mask = pd.DataFrame(
        [[i < j for j in range(len(corr))] for i in range(len(corr))],
        index=corr.index,
        columns=corr.columns,
    )
    sns.heatmap(
        corr,
        mask=mask,
        annot=True,
        fmt=".2f",
        cmap="RdYlGn",
        center=0,
        vmin=-1,
        vmax=1,
        linewidths=0.4,
        annot_kws={"size": 8},
        ax=ax,
    )
    ax.set_title("Korelasi Variabel Iklim Harian")
    fig.tight_layout()
    fig.savefig(fig_dir / "eda_korelasi.png", dpi=180)
    plt.close(fig)

    # Figure 3: Distribusi SPEI hasil praproses
    feat = pd.read_csv(feat_path)
    fig, axes = plt.subplots(1, 3, figsize=(12.6, 4))
    for col, ax in zip(["spei_30d", "spei_90d", "spei_180d"], axes):
        sns.histplot(data=feat, x=col, kde=True, bins=40, ax=ax, stat="density", color="skyblue", edgecolor="black", alpha=0.6)
        ax.axvline(x=0, color="red", linestyle="--", linewidth=1.5, label="SPEI=0")
        ax.axvline(x=-0.5, color="orange", linestyle=":", linewidth=1.2, label="Batas Ringan")
        ax.axvline(x=-1.5, color="darkred", linestyle=":", linewidth=1.2, label="Batas Parah")
        ax.set_title(col.upper())
        ax.legend(fontsize=7)
    fig.suptitle("Distribusi SPEI (30/90/180 hari)", fontsize=12)
    fig.tight_layout()
    fig.savefig(fig_dir / "pra_spei_distribusi.png", dpi=180)
    plt.close(fig)

    # Figure 4: Distribusi kelas kekeringan
    fig, ax = plt.subplots(figsize=(7.2, 4.2))
    feat = feat.dropna(subset=["drought_class"]).copy()
    feat["drought_class"] = feat["drought_class"].astype(int)
    order = sorted(feat["drought_class"].unique())
    labels = {0: "Normal", 1: "Ringan", 2: "Sedang", 3: "Parah"}

    sns.countplot(data=feat, x="drought_class", order=order, ax=ax, palette="Set2", edgecolor="black")
    ax.set_title("Distribusi Kelas Kekeringan (SPEI-30)")
    ax.set_xlabel("Kelas")
    ax.set_ylabel("Jumlah hari")
    ax.set_xticklabels([f"{v} ({labels.get(v, '?')})" for v in order])
    ax.grid(True, axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(fig_dir / "pra_kelas_kekeringan.png", dpi=180)
    plt.close(fig)

    print("Saved figures:")
    for fig_path in sorted(fig_dir.glob("*.png")):
        print(f"- {fig_path.relative_to(root)}")


if __name__ == "__main__":
    main()
