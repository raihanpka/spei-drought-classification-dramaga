# Klasifikasi Tingkat Kekeringan Agrometeorologi Berbasis Indeks SPEI Menggunakan Pendekatan Data Mining pada Data Iklim Harian Dramaga, Bogor Tahun 1980-2024

Proyek ini membangun pipeline data mining end-to-end untuk mengklasifikasikan tingkat kekeringan
agrometeorologi di kawasan Dramaga, Bogor berdasarkan data iklim harian ERA5 selama 45 tahun
(1980-2024). Target klasifikasi adalah **Drought Stress Index** berbasis SPEI-30 (Standardized
Precipitation-Evapotranspiration Index) dengan empat kelas: Normal, Ringan, Sedang, dan Parah.

---

## Project Plan

### Checkpoint 1: Data Collection
> Status: selesai

- [x] Identifikasi sumber data: Open-Meteo Archive API (ERA5 Reanalysis, ECMWF)
- [x] Tentukan lokasi dan periode: Dramaga, Bogor (-6.5624 LS, 106.7319 BT), 1980-2024
- [x] Tulis script pengambilan data (`scrape_data.py`)
- [x] Evaluasi kelengkapan kolom raw:
  - Hapus `rain_sum` (redundan dengan `precipitation_sum` di iklim tropis)
  - Hapus `wind_direction_10m_dominant` (variabel siklik, relevansi rendah)
  - Tambah `relative_humidity_2m_mean` (tersedia di ERA5, tidak redundan dengan VPD)
- [x] Simpan dataset mentah: `dataset_iklim_dramaga_1980_2024.csv`

---

### Checkpoint 2: Eksplorasi Data (EDA)
> Status: belum dimulai

- [x] Cek distribusi dan statistik deskriptif tiap variabel
- [x] Deteksi missing value dan outlier (ERA5 jarang null, tapi perlu diverifikasi)
- [x] Plot time series suhu dan curah hujan 1980-2024 (tren jangka panjang)
- [x] Plot seasonal pattern per bulan (boxplot bulanan)
- [x] Heatmap korelasi antar variabel
- [x] Visualisasi pola El Nino (identifikasi tahun-tahun anomali: 1997, 2015, 2023)

---

### Checkpoint 3: Feature Engineering
> Status: belum dimulai

- [ ] Hitung neraca air harian: `water_balance = precipitation_sum - et0_fao_evapotranspiration`
- [ ] Hitung akumulasi rolling: `wb_30d`, `wb_90d`, `wb_180d`
- [ ] Hitung SPEI-30, SPEI-90, SPEI-180 (normalisasi per bulan kalender, baseline 1981-2010)
- [ ] Hitung anomali suhu bulanan terhadap baseline 1981-2010
- [ ] Hitung `aridity_index = precipitation / ET0`
- [ ] Hitung `soil_water_deficit` (ET0 dikurangi presipitasi, diklem pada 0)
- [ ] Tambah fitur lag temporal (lag-1, lag-7, lag-30 untuk fitur kritis)
- [ ] Tambah fitur siklus musiman (sin/cos bulan) untuk model yang tidak menangkap urutan waktu
- [ ] Buat label target `drought_class` berdasarkan SPEI-30:
  - 0 = Normal (SPEI lebih besar dari -0.50)
  - 1 = Kekeringan Ringan (-1.00 sampai -0.50)
  - 2 = Kekeringan Sedang (-1.50 sampai -1.00)
  - 3 = Kekeringan Parah (SPEI lebih kecil dari atau sama dengan -1.50)

---

### Checkpoint 4: Preprocessing dan Split Data
> Status: belum dimulai

- [ ] Buang 30 baris pertama (rolling window SPEI-30 belum terpenuhi)
- [ ] Normalisasi fitur numerik (StandardScaler atau MinMaxScaler sesuai model)
- [ ] Handle class imbalance: cek distribusi kelas, pertimbangkan SMOTE jika diperlukan
- [ ] Split data: train (1980-2014) / validation (2015-2019) / test (2020-2024)
  - Alasan: split temporal, bukan random, untuk menghindari data leakage

---

### Checkpoint 5: Modelling
> Status: belum dimulai

- [ ] Baseline model: Decision Tree (interpretable, benchmark awal)
- [ ] Ensemble model: Random Forest, XGBoost, LightGBM
- [ ] Time series model: LSTM atau GRU (tangkap dependensi temporal)
- [ ] Evaluasi: F1-macro (prioritas karena kelas imbalanced), confusion matrix, ROC-AUC per kelas
- [ ] Analisis feature importance dari model terbaik

---

### Checkpoint 6: Visualisasi dan Dashboard
> Status: belum dimulai

- [ ] **Tableau:** dashboard eksploratif dari dataset bulanan
  - Heatmap kalender drought class per tahun-bulan
  - Time series SPEI-30 dengan highlight kelas kekeringan
  - Bar chart distribusi kelas per dekade (1980an, 1990an, dst.)
- [ ] **Streamlit:** dashboard prediktif
  - Input parameter iklim, output prediksi kelas kekeringan
  - Plot time series interaktif hasil prediksi model

---

### Checkpoint 7: Dokumentasi dan Laporan
> Status: sebagian selesai

- [x] README project plan (dokumen ini)
- [ ] Notebook EDA (format .ipynb, terstruktur per section)
- [ ] Laporan akhir: metodologi, hasil, interpretasi, dan rekomendasi kebijakan