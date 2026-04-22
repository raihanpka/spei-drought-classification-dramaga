import openmeteo_requests
import requests_cache
import pandas as pd
from retry_requests import retry

# 1. Setup Client dengan Cache & Retry
cache_session = requests_cache.CachedSession('.cache', expire_after = -1)
retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
openmeteo = openmeteo_requests.Client(session = retry_session)

# 2. Definisi Parameter
# Lokasi: Dramaga, Bogor (IPB)
# Rentang Waktu: 1980 - 2024 (44 Tahun untuk data long-term)
url = "https://archive-api.open-meteo.com/v1/archive"

daily_vars = [
    "temperature_2m_mean",
    "temperature_2m_max",
    "temperature_2m_min",
    "precipitation_sum",
    "rain_sum",
    "et0_fao_evapotranspiration",
    "shortwave_radiation_sum",
    "vapor_pressure_deficit_max",
    "wind_speed_10m_max",
    "wind_direction_10m_dominant",
    "soil_temperature_0_to_7cm_mean",
    "soil_moisture_0_to_7cm_mean"
]

params = {
    # Dramaga, Bogor
	"latitude": -6.562413, 
	"longitude": 106.731904,
	"start_date": "1980-01-01",
	"end_date": "2024-12-31",
	"daily": daily_vars,
    "timezone": "Asia/Bangkok" # WIB
}

# 3. Request Data
print("Mengambil data dari Open-Meteo Archive...")
responses = openmeteo.weather_api(url, params=params)

# 4. Proses Respon
response = responses[0]
print(f"Coordinates: {response.Latitude()}°N {response.Longitude()}°E")
print(f"Elevation: {response.Elevation()} m asl")

# Ambil data harian (Daily)
daily = response.Daily()

# Buat Dictionary untuk DataFrame
daily_data = {"date": pd.date_range(
	start = pd.to_datetime(daily.Time(), unit = "s", utc = True),
	end = pd.to_datetime(daily.TimeEnd(), unit = "s", utc = True),
	freq = pd.Timedelta(seconds = daily.Interval()),
	inclusive = "left"
)}

# Loop untuk memasukkan semua variabel ke dictionary secara otomatis
# Urutan variabel di response.Daily() sama dengan urutan di list `daily_vars`
for i, var_name in enumerate(daily_vars):
    daily_data[var_name] = daily.Variables(i).ValuesAsNumpy()

# 5. Konversi ke DataFrame
df = pd.DataFrame(data = daily_data)

# Opsional: Membersihkan NaN (jika ada) atau setup index
# df.dropna(inplace=True) 

print("\nPreview Data")
print(df.head())
print(f"\nDimensi Data: {df.shape}")

# 6. Simpan
filename = '../data/dataset_iklim_dramaga_1980_2024.csv'
df.to_csv(filename, index=False)
print(f"Data tersimpan sebagai {filename}")