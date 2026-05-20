from __future__ import annotations

import json
from pathlib import Path


def list_image_cells(notebook_path: Path) -> None:
    data = json.loads(notebook_path.read_text(encoding="utf-8"))
    for idx, cell in enumerate(data.get("cells", []), start=1):
        if cell.get("cell_type") != "code":
            continue
        has_png = False
        for output in cell.get("outputs", []):
            data_out = output.get("data", {})
            if "image/png" in data_out:
                has_png = True
                break
        if not has_png:
            continue
        source_lines = cell.get("source", [])
        first_line = source_lines[0].strip() if source_lines else ""
        print(f"{notebook_path.name} | cell {idx:02d} | id={cell.get('id')} | {first_line}")


def main() -> None:
    root = Path.cwd()
    list_image_cells(root / "notebooks" / "01_eda.ipynb")
    list_image_cells(root / "notebooks" / "02_feature_engineering.ipynb")


if __name__ == "__main__":
    main()
