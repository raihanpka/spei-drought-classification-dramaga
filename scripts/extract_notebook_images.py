from __future__ import annotations

import base64
import json
from pathlib import Path


def extract_first_png(cell: dict) -> bytes | None:
    for output in cell.get("outputs", []):
        data = output.get("data", {})
        png_data = data.get("image/png")
        if isinstance(png_data, list):
            png_data = "".join(png_data)
        if isinstance(png_data, str):
            return base64.b64decode(png_data)
    return None


def export_images(mapping: list[tuple[Path, str, Path]]) -> None:
    for nb_path, cell_id, out_path in mapping:
        if not nb_path.exists():
            raise FileNotFoundError(f"Notebook not found: {nb_path}")

        notebook = json.loads(nb_path.read_text(encoding="utf-8"))
        cell = next((c for c in notebook.get("cells", []) if c.get("id") == cell_id), None)
        if cell is None:
            raise ValueError(f"Cell id not found: {cell_id} in {nb_path}")

        png_bytes = extract_first_png(cell)
        if png_bytes is None:
            raise ValueError(f"No image/png output found for cell {cell_id} in {nb_path}")

        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(png_bytes)
        print(f"Saved: {out_path}")


def main() -> None:
    root = Path.cwd()
    mapping = [
        (
            root / "notebooks" / "01_eda.ipynb",
            "120924b3",
            root / "docs" / "figures" / "eda_tren_jangka_panjang.png",
        ),
        (
            root / "notebooks" / "01_eda.ipynb",
            "c2904049",
            root / "docs" / "figures" / "eda_korelasi.png",
        ),
    ]
    export_images(mapping)


if __name__ == "__main__":
    main()
