from __future__ import annotations

from pathlib import Path

import pandas as pd

TARGET_COLUMN = "drought_class"

DEFAULT_FEATURES = [
    "temperature_2m_mean",
    "soil_moisture_0_to_7cm_mean",
    "temp_anomaly",
    "aridity_index",
    "month_sin",
    "month_cos",
    "precip_30d_sum",
    "et0_30d_sum",
    "temp_30d_mean",
    "soil_moist_30d_mean",
    "precip_90d_sum",
    "et0_90d_sum",
    "precip_180d_sum",
    "et0_180d_sum",
]

FORECAST_FEATURES = DEFAULT_FEATURES + [
    "water_balance",
    "wb_30d",
    "wb_90d",
    "wb_180d",
    "spei_30d",
    "spei_90d",
    "spei_180d",
    "soil_water_deficit",
    "water_balance_lag_1",
    "water_balance_lag_7",
    "water_balance_lag_30",
]


def resolve_project_root(start: Path | None = None) -> Path:
    current = (start or Path.cwd()).resolve()
    for candidate in (current, current.parent):
        if (candidate / "data").exists() and (candidate / "notebooks").exists():
            return candidate
    raise FileNotFoundError("Project root not found")


def load_featured_dataset(data_dir: str | Path | None = None) -> pd.DataFrame:
    data_path = _resolve_data_dir(data_dir)
    df = pd.read_csv(data_path / "dataset_featured_dramaga.csv")
    df["date"] = pd.to_datetime(df["date"])
    return df


def load_model_splits(data_dir: str | Path | None = None) -> dict[str, pd.DataFrame | pd.Series]:
    df = load_featured_dataset(data_dir=data_dir)
    return temporal_train_test_split(df)


def temporal_train_test_split(
    df: pd.DataFrame,
    features: list[str] | None = None,
    target: str = TARGET_COLUMN,
    train_size: float = 0.8,
) -> dict[str, pd.DataFrame | pd.Series]:
    feature_cols = features or DEFAULT_FEATURES
    df_clean = df.dropna(subset=feature_cols + [target]).reset_index(drop=True)
    split_idx = int(len(df_clean) * train_size)
    train_df = df_clean.iloc[:split_idx].copy()
    test_df = df_clean.iloc[split_idx:].copy()

    x_train = train_df[feature_cols]
    x_test = test_df[feature_cols]
    y_train = train_df[target]
    y_test = test_df[target]

    return {
        "X_train": x_train,
        "X_test": x_test,
        "y_train": y_train,
        "y_test": y_test,
        "train_df": train_df,
        "test_df": test_df,
    }


def _resolve_data_dir(data_dir: str | Path | None) -> Path:
    if data_dir is not None:
        return Path(data_dir)
    return resolve_project_root() / "data"
