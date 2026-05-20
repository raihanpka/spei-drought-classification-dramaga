from __future__ import annotations

import numpy as np
import pandas as pd
from lightgbm import LGBMClassifier
from sklearn.metrics import accuracy_score, classification_report, f1_score, roc_auc_score

from .data import FORECAST_FEATURES


def build_30d_risk_dataset(
    df: pd.DataFrame,
    horizon: int = 30,
    threshold_spei: float = -1.0,
    features: list[str] | None = None,
) -> tuple[pd.DataFrame, list[str], str]:
    feature_cols = features or FORECAST_FEATURES
    target_col = f"moderate_drought_risk_next_{horizon}d"

    future_spei_window = pd.concat(
        [df["spei_30d"].shift(-day) for day in range(1, horizon + 1)],
        axis=1,
    )

    forecast_df = df.copy()
    forecast_df[f"min_spei_next_{horizon}d"] = future_spei_window.min(axis=1)
    forecast_df[target_col] = (forecast_df[f"min_spei_next_{horizon}d"] <= threshold_spei).astype(int)
    forecast_df = forecast_df[
        feature_cols + ["date", f"min_spei_next_{horizon}d", target_col]
    ].dropna().reset_index(drop=True)
    return forecast_df, feature_cols, target_col


def train_30d_risk_model(
    df: pd.DataFrame,
    horizon: int = 30,
    threshold_spei: float = -1.0,
    test_size: float = 0.2,
    validation_size: float = 0.2,
    threshold_candidates: np.ndarray | None = None,
    random_state: int = 42,
) -> dict[str, object]:
    forecast_df, feature_cols, target_col = build_30d_risk_dataset(
        df=df,
        horizon=horizon,
        threshold_spei=threshold_spei,
    )

    split_idx = int(len(forecast_df) * (1 - test_size))
    trainval_df = forecast_df.iloc[:split_idx].copy()
    test_df = forecast_df.iloc[split_idx:].copy()

    validation_idx = int(len(trainval_df) * (1 - validation_size))
    train_df = trainval_df.iloc[:validation_idx].copy()
    valid_df = trainval_df.iloc[validation_idx:].copy()

    model = LGBMClassifier(
        n_estimators=300,
        learning_rate=0.01,
        num_leaves=15,
        class_weight="balanced",
        random_state=random_state,
        verbose=-1,
    )
    model.fit(train_df[feature_cols], train_df[target_col])

    candidates = threshold_candidates
    if candidates is None:
        candidates = np.arange(0.35, 0.66, 0.01)

    valid_proba = model.predict_proba(valid_df[feature_cols])[:, 1]
    threshold_scores = []
    for threshold in candidates:
        valid_pred = (valid_proba >= threshold).astype(int)
        threshold_scores.append(
            {
                "threshold": float(threshold),
                "macro_f1": f1_score(valid_df[target_col], valid_pred, average="macro"),
                "accuracy": accuracy_score(valid_df[target_col], valid_pred),
            }
        )

    best_threshold = max(threshold_scores, key=lambda item: item["macro_f1"])["threshold"]

    final_model = LGBMClassifier(
        n_estimators=300,
        learning_rate=0.01,
        num_leaves=15,
        class_weight="balanced",
        random_state=random_state,
        verbose=-1,
    )
    final_model.fit(trainval_df[feature_cols], trainval_df[target_col])

    test_df["risk_proba_next_30d"] = final_model.predict_proba(test_df[feature_cols])[:, 1]
    test_df["risk_pred_next_30d"] = (test_df["risk_proba_next_30d"] >= best_threshold).astype(int)

    metrics = {
        "validation_threshold": best_threshold,
        "test_accuracy": accuracy_score(test_df[target_col], test_df["risk_pred_next_30d"]),
        "test_macro_f1": f1_score(test_df[target_col], test_df["risk_pred_next_30d"], average="macro"),
        "test_roc_auc": roc_auc_score(test_df[target_col], test_df["risk_proba_next_30d"]),
    }

    report = classification_report(
        test_df[target_col],
        test_df["risk_pred_next_30d"],
        target_names=["Tidak ada risiko sedang+", "Risiko sedang+"],
        zero_division=0,
    )

    return {
        "model": final_model,
        "forecast_df": forecast_df,
        "test_df": test_df,
        "features": feature_cols,
        "target": target_col,
        "metrics": metrics,
        "classification_report": report,
        "threshold_scores": threshold_scores,
    }
