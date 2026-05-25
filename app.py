import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from dramaga_drought.data import load_featured_dataset, temporal_train_test_split, DEFAULT_FEATURES
from dramaga_drought.modelling import train_classification_models, CLASS_LABELS
from dramaga_drought.visualization import (
    plot_spei_time_series,
    plot_decade_distribution,
    plot_yearly_distribution,
    plot_calendar_heatmap,
    plot_classification_confusion_matrix,
    plot_feature_importance,
    plot_severity_trend
)

# Set page config
st.set_page_config(
    page_title="Dramaga Drought Dashboard",
    page_icon="🌵",
    layout="wide"
)

# Title and Description
st.title("🌾 Klasifikasi Kekeringan Agrometeorologi Dramaga")
st.markdown("""
Dashboard ini menyajikan analisis dan prediksi tingkat kekeringan di kawasan Dramaga, Bogor (1980-2024) 
berbasis indeks SPEI-30 (Standardized Precipitation-Evapotranspiration Index).
""")

@st.cache_data
def get_data():
    df = load_featured_dataset()
    splits = temporal_train_test_split(df)
    return df, splits

@st.cache_resource
def get_models(X_train, y_train, X_test, y_test):
    return train_classification_models(X_train, y_train, X_test, y_test)

# Load data
with st.spinner("Memuat data..."):
    df, splits = get_data()

# Sidebar
st.sidebar.header("Konfigurasi")
model_name = st.sidebar.selectbox(
    "Pilih Model",
    ["LightGBM", "XGBoost", "Random Forest", "Neural Net (MLP)"]
)

st.sidebar.markdown("---")
st.sidebar.subheader("Statistik Data")
st.sidebar.write(f"Rentang: {df['date'].dt.year.min()} - {df['date'].dt.year.max()}")
st.sidebar.write(f"Total baris: {len(df):,}")
st.sidebar.write(f"Fitur: {len(DEFAULT_FEATURES)}")

# Train/Get Models
with st.spinner(f"Melatih model {model_name}..."):
    artifacts = get_models(
        splits["X_train"], splits["y_train"], 
        splits["X_test"], splits["y_test"]
    )
    best_model = artifacts["models"][model_name]
    results = artifacts["results"][model_name]
    scaler = artifacts["scaler"]

# Main Tabs
tab1, tab2, tab3 = st.tabs(["📊 Dashboard Historis", "🔬 Analisis Model", "🔮 Prediksi Real-time"])

with tab1:
    st.header("Analisis Historis (1980-2024)")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        st.subheader("Tren SPEI-30")
        fig, _ = plot_spei_time_series(df)
        st.pyplot(fig)
        
    with col2:
        st.subheader("Distribusi per Dekade")
        fig, _ = plot_decade_distribution(df, "drought_class")
        st.pyplot(fig)
        
    st.markdown("---")
    
    col3, col4 = st.columns([2, 1])
    
    with col3:
        st.subheader("Proporsi Tahunan")
        fig, _ = plot_yearly_distribution(df, "drought_class")
        st.pyplot(fig)
        
    with col4:
        st.subheader("Kalender Tahunan")
        selected_year = st.selectbox("Pilih Tahun", sorted(df["date"].dt.year.unique(), reverse=True))
        fig, _ = plot_calendar_heatmap(df, "drought_class", selected_year)
        if fig:
            st.pyplot(fig)
        else:
            st.write("Data tidak tersedia untuk tahun ini.")

with tab2:
    st.header(f"Evaluasi Model: {model_name}")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Confusion Matrix")
        fig, _ = plot_classification_confusion_matrix(results["confusion_matrix"])
        st.pyplot(fig)
        
    with col2:
        st.subheader("Feature Importance")
        try:
            fig, _ = plot_feature_importance(best_model, DEFAULT_FEATURES)
            st.pyplot(fig)
        except AttributeError:
            st.write("Model ini tidak mendukung Feature Importance secara langsung.")
            
    st.markdown("---")
    st.subheader("Prediksi vs Aktual (Data Testing)")
    
    # Prepare test df with predictions
    test_df = splits["test_df"].copy()
    test_df["Predicted"] = results["y_pred"]
    
    fig, _ = plot_severity_trend(test_df, "drought_class", "Predicted")
    st.pyplot(fig)
    
    st.markdown("---")
    st.subheader("Laporan Klasifikasi")
    st.text(results["classification_report"])

with tab3:
    st.header("Input Parameter Iklim")
    st.markdown("Masukkan nilai parameter untuk memprediksi kelas kekeringan.")
    
    # Create input form
    with st.form("prediction_form"):
        col1, col2, col3 = st.columns(3)
        
        inputs = {}
        # Main features for user input
        with col1:
            inputs["temperature_2m_mean"] = st.number_input("Suhu Rata-rata (°C)", value=26.0)
            inputs["soil_moisture_0_to_7cm_mean"] = st.number_input("Kelembapan Tanah (0-7cm)", value=0.3)
            inputs["temp_anomaly"] = st.number_input("Anomali Suhu (°C)", value=0.5)
            
        with col2:
            inputs["precip_30d_sum"] = st.number_input("Presipitasi 30 Hari (mm)", value=200.0)
            inputs["et0_30d_sum"] = st.number_input("Evapotranspirasi 30 Hari (mm)", value=120.0)
            inputs["temp_30d_mean"] = st.number_input("Suhu 30 Hari (°C)", value=26.0)
            
        with col3:
            month = st.selectbox("Bulan", range(1, 13), index=4)
            inputs["month_sin"] = np.sin(2 * np.pi * month / 12)
            inputs["month_cos"] = np.cos(2 * np.pi * month / 12)
            inputs["aridity_index"] = st.number_input("Aridity Index", value=1.5)

        # Fill other features with defaults or calculated values
        inputs["soil_moist_30d_mean"] = 0.3
        inputs["precip_90d_sum"] = inputs["precip_30d_sum"] * 3
        inputs["et0_90d_sum"] = inputs["et0_30d_sum"] * 3
        inputs["precip_180d_sum"] = inputs["precip_30d_sum"] * 6
        inputs["et0_180d_sum"] = inputs["et0_30d_sum"] * 6
        
        submit = st.form_submit_button("Prediksi")
        
    if submit:
        # Prepare input for model
        input_data = pd.DataFrame([inputs])[DEFAULT_FEATURES]
        input_scaled = scaler.transform(input_data)
        
        prediction = best_model.predict(input_scaled)[0]
        prediction_proba = best_model.predict_proba(input_scaled)[0]
        
        st.markdown("---")
        st.subheader("Hasil Prediksi")
        
        res_col1, res_col2 = st.columns([1, 2])
        
        with res_col1:
            class_color = ["green", "yellow", "orange", "red"][int(prediction)]
            st.markdown(f"### Kelas: <span style='color:{class_color}'>{CLASS_LABELS[int(prediction)]}</span>", unsafe_allow_html=True)
            
        with res_col2:
            prob_df = pd.DataFrame({
                "Kelas": CLASS_LABELS,
                "Probabilitas": prediction_proba
            })
            st.bar_chart(prob_df.set_index("Kelas"))

st.sidebar.markdown("---")
st.sidebar.info("Dibuat untuk Proyek Akhir Penambangan Data - Dramaga Drought Project.")
