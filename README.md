# Klasifikasi Tingkat Kekeringan Agrometeorologi Berbasis Indeks SPEI Menggunakan Pendekatan Data Mining pada Data Iklim Harian Dramaga, Bogor Tahun 1980-2024

Dataset ini merupakan produk rekayasa fitur berbasis data iklim harian Stasiun Klimatologi Dramaga, Kabupaten Bogor, Provinsi Jawa Barat, yang diperoleh dari arsip reanalisis ERA5 melalui Open-Meteo Archive API. Cakupan temporal selama 45 tahun (1 Januari 1980 sampai dengan 31 Desember 2024) menjadikan dataset ini representatif untuk analisis perubahan iklim jangka panjang dan pemodelan prediktif kekeringan agrometeorologi di wilayah tropis basah Indonesia.

---

## Latar Belakang Ilmiah

Dramaga merupakan kawasan sentra penelitian pertanian yang terletak di bawah naungan Institut Pertanian Bogor (IPB University). Lokasi ini berada pada lintang 6,56 derajat Lintang Selatan dan bujur 106,73 derajat Bujur Timur, dengan ketinggian sekitar 207 meter di atas permukaan laut. Secara klimatologis, Dramaga tergolong iklim tipe A menurut klasifikasi Schmidt-Ferguson, dengan curah hujan rata-rata tahunan yang tinggi dan tidak terdapat batas musim yang tegas antara musim hujan dan musim kemarau.

Riset ilmiah yang mendasari pendekatan analisis dalam dataset ini antara lain:

* **SPEI sebagai Indeks Kekeringan Multiskala:** Vicente-Serrano et al. (2010) memperkenalkan Standardized Precipitation-Evapotranspiration Index (SPEI) sebagai indeks kekeringan yang menggabungkan defisit air (selisih presipitasi dan evapotranspirasi potensial) dengan teknik standardisasi z-score berbasis distribusi referensi. SPEI mampu mendeteksi onset, durasi, dan tingkat keparahan kekeringan pada berbagai skala temporal, menjadikannya lebih responsif terhadap perubahan iklim dibandingkan SPI yang hanya bergantung pada presipitasi.

* **Kekeringan di Pulau Jawa:** Penelitian Suroso et al. (2021) yang dipublikasikan dalam Journal of Water and Climate Change mengidentifikasi pola spasial dan temporal kekeringan di Pulau Jawa menggunakan SPEI, menunjukkan bahwa periode kekeringan di Jawa Barat berkorelasi kuat dengan kejadian El Nino-Southern Oscillation (ENSO). Kajian ini memvalidasi relevansi penggunaan SPEI sebagai indikator kekeringan utama di kawasan ini.

* **Dampak Iklim terhadap Produktivitas Pertanian Indonesia:** Studi Sumana et al. (2024) yang diterbitkan dalam Scientific Reports membuktikan bahwa variabel meteorologis seperti suhu, curah hujan, dan kelembapan tanah memiliki hubungan kausal yang signifikan terhadap produktivitas tanaman pangan di Indonesia menggunakan algoritma Peter-Clark (PC) untuk pembuatan causal graph. Temuan ini memperkuat urgensi pemantauan indeks kekeringan berbasis komponen neraca air.

* **Standar Normalisasi WMO:** World Meteorological Organization (WMO, 2012) dalam panduan teknis nomor 1090 menetapkan periode referensi 1981-2010 sebagai baseline normalisasi untuk indeks iklim, termasuk SPI dan SPEI. Periode ini digunakan dalam komputasi SPEI pada dataset ini untuk menjamin komparabilitas dengan literatur dan data operasional global.

---

## Sumber dan Akuisisi Data

Data mentah diperoleh dari Open-Meteo Archive API yang menggabungkan data reanalisis ERA5 milik European Centre for Medium-Range Weather Forecasts (ECMWF) dengan koreksi bias berbasis observasi stasiun darat. ERA5 menyediakan rekonstruksi atmosfer historis dengan resolusi spasial 0,25 derajat dan resolusi temporal per jam yang kemudian diagregasi menjadi nilai harian.

| Atribut           | Keterangan                                              |
|-------------------|---------------------------------------------------------|
| Sumber Data       | Open-Meteo Archive API (ERA5 Reanalysis, ECMWF)         |
| Periode           | 1 Januari 1980 sampai dengan 31 Desember 2024           |
| Resolusi Temporal | Harian                                                  |
| Lokasi            | Dramaga, Kabupaten Bogor, Jawa Barat                    |
| Koordinat         | 6,5624 LS, 106,7319 BT                                  |
| Elevasi           | 207 meter di atas permukaan laut                        |
| Zona Waktu        | Asia/Jakarta (WIB, UTC+7)                               |
| Baseline SPEI     | Periode referensi WMO 1981-2010                         |

---

## Skema Dataset

Dataset tersedia dalam dua format agregasi temporal, masing-masing dirancang untuk tujuan analisis yang berbeda.

### A. Dataset Harian (`data/dataset_iklim_dramaga_1980_2024_completed.csv`)

Dataset primer untuk pelatihan model machine learning. Setiap baris merepresentasikan satu hari pengamatan dengan kelompok fitur sebagai berikut.

#### Kelompok 1: Identitas dan Metadata Spasial

| Kolom          | Tipe    | Satuan | Keterangan                                              |
|----------------|---------|--------|---------------------------------------------------------|
| `date`         | string  |        | Tanggal pengamatan (format YYYY-MM-DD)                  |
| `latitude`     | float   | derajat| Koordinat lintang lokasi stasiun                        |
| `longitude`    | float   | derajat| Koordinat bujur lokasi stasiun                          |
| `station_name` | string  |        | Nama stasiun klimatologi                                |
| `province`     | string  |        | Nama provinsi                                           |
| `elevation_masl`| float  | meter  | Elevasi di atas permukaan laut                          |

#### Kelompok 2: Variabel Iklim Dasar (Raw ERA5)

| Kolom                            | Satuan     | Keterangan                                              |
|----------------------------------|------------|---------------------------------------------------------|
| `temperature_2m_mean`            | degC       | Suhu udara rata-rata harian pada ketinggian 2 meter     |
| `temperature_2m_max`             | degC       | Suhu udara maksimum harian pada ketinggian 2 meter      |
| `temperature_2m_min`             | degC       | Suhu udara minimum harian pada ketinggian 2 meter       |
| `precipitation_sum`              | mm         | Akumulasi total presipitasi harian                      |
| `rain_sum`                       | mm         | Komponen curah hujan harian (tidak termasuk salju)      |
| `et0_fao_evapotranspiration`     | mm         | Evapotranspirasi referensi FAO Penman-Monteith (ET0)    |
| `shortwave_radiation_sum`        | MJ/m2      | Total radiasi gelombang pendek yang mencapai permukaan  |
| `vapor_pressure_deficit_max`     | kPa        | Defisit tekanan uap maksimum harian                     |
| `wind_speed_10m_max`             | km/jam     | Kecepatan angin maksimum harian pada ketinggian 10 meter|
| `wind_direction_10m_dominant`    | derajat    | Arah angin dominan harian pada ketinggian 10 meter      |
| `soil_temperature_0_to_7cm_mean` | degC       | Suhu tanah rata-rata harian pada kedalaman 0-7 cm       |
| `soil_moisture_0_to_7cm_mean`    | m3/m3      | Kandungan air tanah rata-rata harian pada kedalaman 0-7 cm |

#### Kelompok 3: Fitur Turunan (Derived Features)

Fitur-fitur berikut direkayasa secara langsung dari variabel iklim dasar untuk meningkatkan kemampuan representasi kondisi hidroklimatologis.

| Kolom                    | Satuan  | Keterangan                                                       |
|--------------------------|---------|------------------------------------------------------------------|
| `water_balance`          | mm      | Neraca air harian: presipitasi dikurangi ET0 (P minus ET0)       |
| `soil_water_deficit`     | mm      | Defisit air tanah harian: nilai positif berarti permintaan ET0 melebihi suplai hujan; diklem pada nol |
| `aridity_index`          | rasio   | Indeks kekeringan aridity: rasio presipitasi terhadap ET0; nilai di bawah 0,5 mengindikasikan kondisi kering |
| `wb_30d`                 | mm      | Akumulasi neraca air dalam jendela bergulir 30 hari (basis komputasi SPEI-30) |
| `wb_90d`                 | mm      | Akumulasi neraca air dalam jendela bergulir 90 hari (basis komputasi SPEI-90) |
| `wb_180d`                | mm      | Akumulasi neraca air dalam jendela bergulir 180 hari (basis komputasi SPEI-180) |
| `spei_30`                | z-score | SPEI skala 30 hari: indeks kekeringan jangka pendek; sensitif terhadap stres pertanian musiman |
| `spei_90`                | z-score | SPEI skala 90 hari: indeks kekeringan jangka menengah; relevan untuk ketahanan pangan antarmusimanl |
| `spei_180`               | z-score | SPEI skala 180 hari: indeks kekeringan jangka panjang; mencerminkan akumulasi defisit air antartahun |
| `temp_anomaly`           | degC    | Anomali suhu harian: deviasi dari rata-rata klimatologis per bulan kalender pada periode referensi 1981-2010 |
| `temp_rolling_30d`       | degC    | Rata-rata bergerak suhu udara dalam 30 hari terakhir             |
| `heat_stress_flag`       | biner   | Penanda stres panas: bernilai 1 apabila suhu maksimum mencapai atau melebihi 33 degC |
| `heat_stress_days_30d`   | hari    | Jumlah hari stres panas dalam 30 hari terakhir                   |
| `rain_freq_30d`          | proporsi| Frekuensi hari hujan dalam 30 hari terakhir (ambang batas 1 mm per hari) |
| `precip_30d`             | mm      | Akumulasi curah hujan dalam 30 hari terakhir                     |

#### Kelompok 4: Target Klasifikasi

| Kolom                | Tipe    | Keterangan                                                        |
|----------------------|---------|-------------------------------------------------------------------|
| `drought_class`      | string  | Label kelas kekeringan berdasarkan nilai SPEI-30 (lihat definisi di bawah) |
| `drought_class_code` | integer | Kode numerik kelas kekeringan: 0 = Normal, 1 = Ringan, 2 = Sedang, 3 = Parah |

---

### B. Dataset Bulanan (`dataset_iklim_dramaga_1980_2024_monthly.csv`)

Dataset agregasi untuk visualisasi tren jangka panjang dan dashboard geomap (Tableau, Kepler.gl). Nilai numerik diagregasi menggunakan fungsi yang sesuai dengan karakteristik masing-masing variabel: akumulasi untuk variabel fluks (curah hujan, ET0), rata-rata untuk variabel status (suhu, kelembapan tanah), dan nilai akhir periode untuk nilai SPEI jangka menengah dan panjang.

---

## Definisi Target Klasifikasi

Target klasifikasi dalam dataset ini adalah variabel `drought_class`, yang dikonstruksi berdasarkan nilai SPEI-30. Penetapan ambang batas mengikuti skala kekeringan McKee et al. (1993) yang telah diadopsi secara luas oleh WMO (2012) sebagai standar pemantauan kekeringan meteorologis internasional.

| Kode | Label Kelas         | Rentang Nilai SPEI-30         | Interpretasi Hidroklimatologis                            |
|------|---------------------|-------------------------------|-----------------------------------------------------------|
| 0    | Normal              | SPEI lebih besar dari -0,50   | Kondisi neraca air dalam batas variabilitas normal        |
| 1    | Kekeringan Ringan   | -1,00 lebih kecil dari atau sama dengan SPEI lebih kecil dari atau sama dengan -0,50 | Defisit air mulai terdeteksi; tanaman dengan toleransi rendah mulai mengalami stres |
| 2    | Kekeringan Sedang   | -1,50 lebih kecil dari atau sama dengan SPEI lebih kecil dari atau sama dengan -1,00 | Defisit air signifikan; penurunan hasil pertanian tanaman pangan mulai terjadi       |
| 3    | Kekeringan Parah    | SPEI lebih kecil dari atau sama dengan -1,50                  | Defisit air ekstrem; potensi gagal panen dan dampak ekosistem yang luas             |

### Distribusi Kelas (Empiris, 1980-2024)

Berdasarkan komputasi pada data historis Dramaga, distribusi kelas kekeringan yang terbentuk adalah sebagai berikut:

| Kelas               | Jumlah Hari | Proporsi (%) |
|---------------------|-------------|--------------|
| Normal              | 10.541      | 64,1         |
| Kekeringan Ringan   | 2.748       | 16,7         |
| Kekeringan Sedang   | 2.134       | 13,0         |
| Kekeringan Parah    | 991         | 6,0          |
| Unknown (awal deret)| 23          | 0,1          |

Distribusi ini mencerminkan karakteristik iklim tropis basah Dramaga yang cenderung lembap, dengan frekuensi kekeringan parah yang relatif rendah namun terkonsentrasi pada periode El Nino (contoh: 1997-1998, 2015-2016, dan 2023).

---

## Metodologi Komputasi SPEI

Komputasi SPEI dalam dataset ini mengikuti alur berikut:

1. **Penghitungan Neraca Air Harian:** Nilai neraca air diperoleh dari selisih antara presipitasi harian dan ET0 FAO Penman-Monteith yang telah tersedia dalam data ERA5.

2. **Akumulasi Jendela Bergulir:** Neraca air harian diakumulasikan dalam jendela bergulir 30, 90, dan 180 hari untuk merepresentasikan kondisi defisit air pada skala temporal yang berbeda.

3. **Normalisasi Per Bulan Kalender:** Standardisasi dilakukan secara terpisah untuk setiap bulan kalender (Januari sampai Desember) menggunakan rata-rata dan simpangan baku yang dihitung dari periode referensi WMO 1981-2010. Pendekatan ini menghilangkan pengaruh musiman sehingga nilai SPEI mencerminkan anomali yang bersifat murni interannual.

4. **Klipping Nilai Ekstrem:** Nilai SPEI diklem pada rentang -3,0 sampai dengan +3,0 untuk menjaga kestabilan numerik dan kompatibilitas dengan skala standar distribusi normal.

5. **Klasifikasi:** Nilai SPEI-30 diklasifikasikan ke dalam empat kelas kekeringan menggunakan ambang batas McKee et al. (1993).

---

## Catatan Teknis

* Nilai SPEI pada 23 baris pertama data (Januari 1980) berstatus `Unknown` karena jendela bergulir 30 hari belum terpenuhi. Baris-baris ini disarankan untuk dikeluarkan dari proses pelatihan model.
* Variabel `aridity_index` diklem pada nilai maksimum 10 untuk menghindari nilai tak terhingga pada hari dengan ET0 mendekati nol.
* Dataset bulanan menggunakan nilai maksimum `drought_class_code` dalam setiap bulan untuk merepresentasikan tingkat keparahan kekeringan terparah yang terjadi selama bulan tersebut.
* Kolom `latitude` dan `longitude` disertakan di setiap baris untuk memfasilitasi visualisasi geomap pada platform seperti Tableau dan Kepler.gl meskipun dataset ini bersumber dari satu titik stasiun tunggal.

---

## Referensi

* Allen, R. G., Pereira, L. S., Raes, D., dan Smith, M. (1998). *Crop Evapotranspiration: Guidelines for Computing Crop Water Requirements*. FAO Irrigation and Drainage Paper No. 56. Food and Agriculture Organization of the United Nations.

* McKee, T. B., Doesken, N. J., dan Kleist, J. (1993). The relationship of drought frequency and duration to time scales. *Proceedings of the 8th Conference on Applied Climatology*, 179-183. American Meteorological Society.

* Sumana, N. H., et al. (2024). Integrated analysis of meteorological conditions and agricultural yields in Indonesia using causal learning and intelligent clustering for climate change mitigation. *Scientific Reports*, 16, artikel 40418. https://doi.org/10.1038/s41598-026-40418-5

* Suroso, D. S. A., Nadhilah, D., Ardiansyah, dan Aldrian, E. (2021). Drought detection in Java Island based on Standardized Precipitation and Evapotranspiration Index (SPEI). *Journal of Water and Climate Change*, 12(6), 2734-2752. https://doi.org/10.2166/wcc.2021.022

* Vicente-Serrano, S. M., Begueria, S., dan Lopez-Moreno, J. I. (2010). A multiscalar drought index sensitive to global warming: the Standardized Precipitation Evapotranspiration Index. *Journal of Climate*, 23(7), 1696-1718. https://doi.org/10.1175/2009JCLI2909.1

* World Meteorological Organization. (2012). *Standardized Precipitation Index User Guide*. WMO Technical Document No. 1090. World Meteorological Organization.

---

## Kredit

Project ini dikembangkan oleh **Kelompok 8 (P2)** untuk memenuhi tugas proyek mata kuliah **Data Mining (Daming)** dari **Departemen Ilmu Komputer, IPB University**.

**Anggota:**
| Nama | NIM | Role |
|------|-----|------|
| Insan Anshary Rasul | G6401231132 | Data Engineer |
| Daffa Aulia Musyaffa Subyantoro | G6401231028 | Data Analyst |
| Raihan Putra Kirana | G6401231027 | ML Engineer |
| Muhammad Chalied Al Walid | G6401231114 | Data Visualizer |

---

## Lisensi

Dataset ini didistribusikan di bawah lisensi Creative Commons Attribution 4.0 International (CC BY 4.0). Data ERA5 yang menjadi sumber bahan baku tunduk pada syarat penggunaan ECMWF yang mengizinkan penggunaan akademik dan penelitian non-komersial.