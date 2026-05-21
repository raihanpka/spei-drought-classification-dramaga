from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd


def _svg_header(width: int, height: int) -> list[str]:
    return [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="white" />',
    ]


def _svg_footer() -> list[str]:
    return ["</svg>"]


def save_bar_chart(values: list[float], labels: list[str], title: str, x_label: str, y_label: str, out_path: Path) -> None:
    width, height = 820, 420
    margin_left, margin_right = 70, 30
    margin_top, margin_bottom = 50, 70

    plot_width = width - margin_left - margin_right
    plot_height = height - margin_top - margin_bottom

    max_val = max(values) if values else 1.0
    max_val = max_val if max_val > 0 else 1.0

    svg = _svg_header(width, height)

    # Title
    svg.append(
        f'<text x="{width/2}" y="{margin_top - 15}" font-size="16" font-family="Times New Roman, serif" text-anchor="middle">{title}</text>'
    )

    # Axes
    x0, y0 = margin_left, margin_top + plot_height
    svg.append(f'<line x1="{x0}" y1="{y0}" x2="{x0 + plot_width}" y2="{y0}" stroke="#333" />')
    svg.append(f'<line x1="{x0}" y1="{margin_top}" x2="{x0}" y2="{y0}" stroke="#333" />')

    # Bars
    n = len(values)
    step = plot_width / n if n else plot_width
    bar_width = step * 0.6

    for i, (val, label) in enumerate(zip(values, labels)):
        bar_height = (val / max_val) * plot_height
        x = margin_left + i * step + (step - bar_width) / 2
        y = margin_top + (plot_height - bar_height)
        svg.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{bar_width:.1f}" height="{bar_height:.1f}" fill="#5DA5DA" />')
        svg.append(
            f'<text x="{x + bar_width/2:.1f}" y="{y0 + 18}" font-size="11" font-family="Times New Roman, serif" text-anchor="middle">{label}</text>'
        )

    # Axis labels
    svg.append(
        f'<text x="{width/2}" y="{height - 18}" font-size="12" font-family="Times New Roman, serif" text-anchor="middle">{x_label}</text>'
    )
    svg.append(
        f'<text x="18" y="{height/2}" font-size="12" font-family="Times New Roman, serif" text-anchor="middle" transform="rotate(-90, 18, {height/2})">{y_label}</text>'
    )

    svg.extend(_svg_footer())
    out_path.write_text("\n".join(svg), encoding="utf-8")


def save_histogram(values: np.ndarray, title: str, x_label: str, y_label: str, out_path: Path, bins: int = 20) -> None:
    width, height = 820, 420
    margin_left, margin_right = 70, 30
    margin_top, margin_bottom = 50, 70

    plot_width = width - margin_left - margin_right
    plot_height = height - margin_top - margin_bottom

    counts, edges = np.histogram(values, bins=bins)
    max_count = counts.max() if counts.size else 1

    svg = _svg_header(width, height)
    svg.append(
        f'<text x="{width/2}" y="{margin_top - 15}" font-size="16" font-family="Times New Roman, serif" text-anchor="middle">{title}</text>'
    )

    x0, y0 = margin_left, margin_top + plot_height
    svg.append(f'<line x1="{x0}" y1="{y0}" x2="{x0 + plot_width}" y2="{y0}" stroke="#333" />')
    svg.append(f'<line x1="{x0}" y1="{margin_top}" x2="{x0}" y2="{y0}" stroke="#333" />')

    bin_width = plot_width / bins
    for i, count in enumerate(counts):
        bar_height = (count / max_count) * plot_height if max_count else 0
        x = margin_left + i * bin_width
        y = margin_top + (plot_height - bar_height)
        svg.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{bin_width * 0.9:.1f}" height="{bar_height:.1f}" fill="#60BD68" />')

    # X-axis tick labels (min, mid, max)
    tick_positions = [0, bins // 2, bins - 1]
    for pos in tick_positions:
        x = margin_left + pos * bin_width + bin_width / 2
        label = f"{edges[pos]:.2f}"
        svg.append(
            f'<text x="{x:.1f}" y="{y0 + 18}" font-size="11" font-family="Times New Roman, serif" text-anchor="middle">{label}</text>'
        )

    svg.append(
        f'<text x="{width/2}" y="{height - 18}" font-size="12" font-family="Times New Roman, serif" text-anchor="middle">{x_label}</text>'
    )
    svg.append(
        f'<text x="18" y="{height/2}" font-size="12" font-family="Times New Roman, serif" text-anchor="middle" transform="rotate(-90, 18, {height/2})">{y_label}</text>'
    )

    svg.extend(_svg_footer())
    out_path.write_text("\n".join(svg), encoding="utf-8")


def main() -> None:
    root = Path.cwd()
    data_path = root / "data" / "dataset_featured_dramaga.csv"
    fig_dir = root / "docs" / "figures"
    fig_dir.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(data_path)

    # Histogram SPEI-30
    spei = df["spei_30d"].dropna().to_numpy()
    save_histogram(
        spei,
        title="Distribusi SPEI-30 (Hasil Praproses)",
        x_label="Nilai SPEI-30",
        y_label="Frekuensi",
        out_path=fig_dir / "pra_spei_histogram.svg",
        bins=24,
    )

    # Bar chart kelas kekeringan
    counts = df["drought_class"].dropna().astype(int).value_counts().sort_index()
    labels = ["0 Normal", "1 Ringan", "2 Sedang", "3 Parah"]
    values = [counts.get(i, 0) for i in range(4)]
    save_bar_chart(
        values,
        labels,
        title="Distribusi Kelas Kekeringan (SPEI-30)",
        x_label="Kelas",
        y_label="Jumlah hari",
        out_path=fig_dir / "pra_kelas_kekeringan.svg",
    )

    print("Saved figures:")
    print("- docs/figures/pra_spei_histogram.svg")
    print("- docs/figures/pra_kelas_kekeringan.svg")


if __name__ == "__main__":
    main()
