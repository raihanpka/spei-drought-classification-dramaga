from __future__ import annotations

import pandas as pd
from imblearn.over_sampling import SMOTE
from lightgbm import LGBMClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, f1_score
from sklearn.neural_network import MLPClassifier
from sklearn.preprocessing import StandardScaler
from xgboost import XGBClassifier


CLASS_LABELS = ["Normal", "Ringan", "Sedang", "Parah"]


def build_classification_models(random_state: int = 42) -> dict[str, object]:
    return {
        "Random Forest": RandomForestClassifier(n_estimators=100, random_state=random_state),
        "XGBoost": XGBClassifier(
            n_estimators=100,
            learning_rate=0.05,
            max_depth=8,
            random_state=random_state,
        ),
        "LightGBM": LGBMClassifier(
            n_estimators=200,
            learning_rate=0.05,
            random_state=random_state,
            verbose=-1,
        ),
        "Neural Net (MLP)": MLPClassifier(
            hidden_layer_sizes=(128, 64, 32),
            max_iter=1000,
            early_stopping=True,
            random_state=random_state,
        ),
    }


def train_classification_models(
    x_train: pd.DataFrame,
    y_train: pd.Series,
    x_test: pd.DataFrame,
    y_test: pd.Series,
    random_state: int = 42,
) -> dict[str, object]:
    scaler = StandardScaler()
    x_train_scaled = scaler.fit_transform(x_train)
    x_test_scaled = scaler.transform(x_test)

    smote = SMOTE(random_state=random_state)
    x_train_res, y_train_res = smote.fit_resample(x_train_scaled, y_train)

    models = build_classification_models(random_state=random_state)
    results = {}
    for name, model in models.items():
        model.fit(x_train_res, y_train_res)
        y_pred = model.predict(x_test_scaled)
        results[name] = {
            "model": model,
            "y_pred": y_pred,
            "accuracy": accuracy_score(y_test, y_pred),
            "macro_f1": f1_score(y_test, y_pred, average="macro"),
            "classification_report": classification_report(
                y_test,
                y_pred,
                target_names=CLASS_LABELS,
                zero_division=0,
            ),
            "confusion_matrix": confusion_matrix(y_test, y_pred),
        }

    return {
        "scaler": scaler,
        "models": models,
        "results": results,
        "x_train_resampled_shape": x_train_res.shape,
        "x_test_scaled_shape": x_test_scaled.shape,
    }
