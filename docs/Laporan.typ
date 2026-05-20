// Paket diagram
#import "@preview/fletcher:0.5.8": diagram, edge, node

// Pengaturan dokumen
#let laporan_akhir(
  title: "",
  authors: (),
  group: "",
  class: "",
  emails: (),
  abstract: [],
  keywords: "",
  body,
) = {
  set document(title: title)
  set page(
    paper: "a4",
    margin: (top: 2.1cm, bottom: 2.2cm, left: 2.35cm, right: 2.35cm),
    numbering: "1",
    number-align: center,
  )
  set text(font: "Times New Roman", size: 11pt, lang: "id", region: "ID")
  set par(justify: true, first-line-indent: 0.8cm, leading: 0.58em)
  set heading(numbering: "1.")

  // Jarak judul bagian
  show heading.where(level: 1): it => block(above: 0.85em, below: 0.35em)[
    #set align(left)
    #set text(weight: "bold", size: 11.5pt)
    #it
  ]

  show heading.where(level: 2): it => block(above: 0.65em, below: 0.25em)[
    #set text(weight: "bold", size: 11pt)
    #it
  ]

  show heading.where(level: 3): it => block(above: 0.45em, below: 0.2em)[
    #set text(style: "italic", size: 11pt)
    #it
  ]

  show raw: set text(font: "Times New Roman", size: 10pt)

  // Kepala laporan
  align(center)[
    #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
    #text(size: 14pt, weight: "bold")[#title]

    #v(0.75em)
    #text(size: 10.5pt)[#authors.join("\n")]

    #v(0.35em)
    #text(size: 10pt)[Kelompok #group, Kelas Paralel #class]
  ]

  v(0.85em)

  // Abstrak dan kata kunci
  block[
    #set par(first-line-indent: 0pt, justify: true, leading: 0.52em)
    #text(weight: "bold")[Abstrak] #abstract

    #v(0.35em)
    #text(weight: "bold")[Kata kunci:] #keywords
  ]

  v(0.8em)
  body
}

#show: laporan_akhir.with(
  title: [Klasifikasi Tingkat Kekeringan Agrometeorologi Berbasis SPEI Menggunakan Pendekatan Penambangan Data pada Data Iklim Harian Dramaga, Bogor Tahun 1980 sampai 2024],
  authors: (
    "Raihan Putra Kirana, G6401231027",
    "Daffa Aulia Musyaffa Subyantoro, G6401231028",
    "Muhammad Chalied Al Walid, G6401231114",
    "Insan Anshary Rasul, G6401231132",
  ),
  group: "8",
  class: "1",
  emails: ("raihanputrakirana@apps.ipb.ac.id", "daffaaulia@apps.ipb.ac.id", "muhammadchalied@apps.ipb.ac.id", "insananshary@apps.ipb.ac.id"),
  abstract: [
    Kekeringan agrometeorologi terjadi ketika masukan air dari presipitasi tidak memadai untuk memenuhi kebutuhan air atmosfer dan tanaman. Masalah ini tetap relevan di Dramaga, Bogor, meskipun wilayah tersebut beriklim tropis basah, karena variasi curah hujan, peningkatan kebutuhan evapotranspirasi, dan anomali iklim dapat menimbulkan defisit air dalam skala harian sampai musiman. Penelitian ini menyusun alur penambangan data untuk mengklasifikasikan tingkat kekeringan agrometeorologi berdasarkan data iklim harian periode 1980 sampai 2024. Data diperoleh dari _Open Meteo Historical Weather API_ yang berbasis reanalisis ERA5. Indeks _Standardized Precipitation Evapotranspiration Index_ digunakan sebagai dasar pembentukan target karena mempertimbangkan presipitasi dan evapotranspirasi referensi. Tahapan penelitian meliputi akuisisi data, pemeriksaan mutu, prapemrosesan waktu, rekayasa fitur neraca air, standardisasi SPEI, pembentukan label kelas, dan penyiapan data untuk pemodelan klasifikasi berbasis deret waktu.
  ],
  keywords: "Dramaga, ERA5, kekeringan agrometeorologi, penambangan data, SPEI",
)

= Pendahuluan

== Latar belakang

Kekeringan merupakan gejala hidroklimatologis yang tidak dapat dinilai hanya dari rendahnya curah hujan pada satu hari pengamatan. Dalam konteks agrometeorologi, kekeringan muncul ketika ketersediaan air tidak mampu mengimbangi kebutuhan evaporatif atmosfer dan kebutuhan fisiologis tanaman selama periode tertentu. World Meteorological Organization menyatakan bahwa kekeringan bersifat relatif terhadap kondisi normal wilayah sehingga pengukurannya perlu mempertimbangkan karakter iklim setempat, skala waktu, dan tujuan pemantauan @wmo2012. Pemahaman tersebut penting untuk wilayah tropis basah karena curah hujan tahunan yang tinggi tidak selalu menjamin ketiadaan tekanan kekeringan pada periode tertentu.

Dramaga, Bogor, merupakan kawasan pendidikan dan penelitian pertanian yang memiliki ketergantungan kuat terhadap kestabilan unsur iklim. Wilayah ini umumnya lembap, tetapi tetap dipengaruhi variasi musiman dan anomali iklim seperti El Niño. Pada periode anomali, penurunan hujan dapat terjadi bersamaan dengan peningkatan suhu, radiasi, dan evapotranspirasi. Kombinasi tersebut memperbesar defisit neraca air meskipun jumlah hujan tahunan masih terlihat besar. Oleh sebab itu, pemantauan kekeringan di Dramaga memerlukan indikator yang tidak hanya menghitung presipitasi, tetapi juga memasukkan komponen kehilangan air.

_Standardized Precipitation Evapotranspiration Index_ atau SPEI digunakan dalam penelitian ini karena indeks tersebut merepresentasikan defisit air melalui selisih presipitasi dan evapotranspirasi potensial. Vicente Serrano, Begueria, dan Lopez Moreno memperkenalkan SPEI sebagai indeks multiskala yang sensitif terhadap perubahan suhu sehingga lebih sesuai untuk analisis kekeringan pada konteks perubahan iklim dibandingkan indeks yang hanya berbasis presipitasi @vicenteserrano2010. Pada proyek ini, SPEI menjadi dasar pembentukan label kelas kekeringan harian, sedangkan variabel iklim lain digunakan sebagai fitur untuk proses klasifikasi.

Selain aspek klimatologis, penelitian ini juga memiliki persoalan metodologis. Data iklim harian tahun 1980 sampai 2024 merupakan deret waktu panjang dengan hubungan antarvariabel yang kompleks, kelas kejadian yang tidak seimbang, dan risiko kebocoran informasi apabila data dipisahkan secara acak. Kerangka CRISP DM menempatkan pemahaman masalah, pemahaman data, persiapan data, pemodelan, evaluasi, dan penerapan sebagai tahapan yang saling terkait dalam proyek penambangan data @chapman2000. Dengan mengikuti alur tersebut, penelitian ini tidak langsung berfokus pada model, tetapi terlebih dahulu memastikan bahwa data, fitur, target, dan rancangan evaluasi memiliki dasar ilmiah yang jelas.

== Rumusan masalah

Rumusan masalah penelitian ini adalah bagaimana menyusun data iklim harian Dramaga tahun 1980 sampai 2024 menjadi dataset yang layak digunakan untuk klasifikasi tingkat kekeringan agrometeorologi. Pertanyaan tersebut mencakup pemilihan sumber data, pemeriksaan konsistensi waktu dan kelengkapan observasi, pembentukan fitur yang relevan secara hidroklimatologis, penghitungan SPEI, serta penetapan label target yang dapat dipertanggungjawabkan secara metodologis.

== Tujuan penelitian

Penelitian ini bertujuan membangun alur penambangan data untuk klasifikasi tingkat kekeringan agrometeorologi di Dramaga, Bogor. Tujuan khususnya adalah menjelaskan dasar pemilihan data iklim harian berbasis ERA5, melakukan prapemrosesan tanggal dan kualitas data, membentuk fitur neraca air dan fitur temporal, menghitung SPEI pada beberapa skala waktu, menetapkan target klasifikasi berbasis SPEI 30 hari, serta menyiapkan data latih dan data uji dengan pembagian temporal.

== Ruang lingkup

Ruang lingkup penelitian dibatasi pada data iklim harian satu titik koordinat Dramaga, Bogor, untuk periode 1 Januari 1980 sampai 31 Desember 2024. Variabel yang digunakan mencakup suhu udara, curah hujan, evapotranspirasi referensi, radiasi gelombang pendek, kelembapan relatif, defisit tekanan uap, kecepatan angin, arah angin, suhu tanah, dan kelembapan tanah. Laporan ini berfokus pada bagian awal sampai tahap proses, yaitu pengumpulan data, prapemrosesan, rekayasa fitur, pembentukan target, dan rancangan evaluasi. Bagian hasil model dan interpretasi performa akan menjadi tahap lanjutan setelah seluruh keluaran pemodelan dan visualisasi final tersedia.

== Manfaat penelitian

Manfaat penelitian ini adalah menyediakan alur kerja yang dapat ditelusuri untuk menghubungkan konsep kekeringan agrometeorologi dengan praktik penambangan data. Alur tersebut membantu menjelaskan bagaimana data reanalisis iklim diubah menjadi fitur dan target yang dapat digunakan pada model klasifikasi. Dari sisi terapan, dataset dan rancangan pemodelan ini dapat menjadi dasar awal bagi sistem pendukung keputusan atau peringatan dini kekeringan pada wilayah pertanian tropis basah.

= Tinjauan pustaka

== Kekeringan agrometeorologi

Kekeringan agrometeorologi berada di antara kekeringan meteorologis dan dampaknya terhadap sistem pertanian. Kondisi ini berkaitan dengan berkurangnya masukan air, meningkatnya kebutuhan atmosfer, dan menurunnya cadangan air tanah yang tersedia bagi tanaman. WMO menekankan bahwa kekeringan harus ditafsirkan berdasarkan kondisi normal suatu wilayah, bukan sebagai nilai mutlak yang berlaku sama untuk semua tempat @wmo2012. Dengan demikian, indikator kekeringan yang digunakan pada wilayah seperti Dramaga perlu mempertimbangkan pola curah hujan lokal dan variasi musiman yang khas.

== SPEI sebagai indikator kekeringan

SPEI dikembangkan untuk mengukur anomali neraca air pada berbagai skala waktu. Nilai dasarnya berasal dari presipitasi dikurangi evapotranspirasi potensial, kemudian distandardisasi terhadap periode referensi. Keunggulan utama SPEI terletak pada kemampuannya menangkap pengaruh peningkatan kebutuhan evaporatif, khususnya ketika suhu meningkat @vicenteserrano2010. Dalam konteks agrometeorologi, sifat ini penting karena tanaman dapat mengalami tekanan air meskipun hujan tidak sepenuhnya hilang, terutama ketika kehilangan air melalui evapotranspirasi meningkat.

Penelitian ini menggunakan SPEI 30 hari sebagai dasar target klasifikasi karena skala tersebut cukup peka terhadap perubahan kondisi air jangka pendek yang relevan dengan stres tanaman. SPEI 90 hari dan 180 hari tetap dihitung untuk menggambarkan memori defisit air yang lebih panjang. Dengan cara ini, model tidak hanya menerima informasi keadaan harian, tetapi juga konteks akumulasi defisit yang berkembang selama beberapa bulan.

Relevansi SPEI untuk wilayah Jawa juga didukung oleh kajian Suroso dan rekan yang menggunakan SPEI untuk mendeteksi kekeringan di Pulau Jawa @suroso2021. Kajian tersebut menunjukkan bahwa indeks berbasis presipitasi dan evapotranspirasi dapat digunakan untuk membaca variasi kekeringan pada wilayah dengan dinamika monsun dan anomali iklim yang kuat. Temuan tersebut memperkuat alasan penggunaan SPEI pada Dramaga sebagai bagian dari Jawa Barat.

== Evapotranspirasi referensi

Evapotranspirasi referensi atau ET0 menggambarkan kebutuhan air atmosfer terhadap permukaan acuan. FAO 56 menjelaskan metode Penman Monteith sebagai prosedur standar untuk memperkirakan ET0 dari unsur meteorologis @allen1998. Variabel ini menjadi penting karena kekeringan pertanian dipengaruhi oleh dua sisi neraca air, yaitu masukan melalui hujan dan kehilangan melalui evapotranspirasi. Pada suhu, radiasi, dan defisit tekanan uap yang lebih tinggi, jumlah hujan yang sama dapat menghasilkan tekanan kekeringan yang lebih besar.

== Data reanalisis ERA5

Data reanalisis digunakan ketika dibutuhkan deret waktu panjang yang konsisten pada lokasi tertentu. Dokumentasi _Open Meteo Historical Weather API_ menjelaskan bahwa layanan tersebut menyediakan data historis berbasis reanalisis ERA5 dengan cakupan sejak 1940 dan resolusi spasial 0,25 derajat @openmeteo2026. Sumber ini sesuai untuk penelitian karena menyediakan variabel meteorologis harian yang lengkap pada koordinat Dramaga. Walaupun data reanalisis bukan pengukuran stasiun langsung, konsistensi temporalnya mendukung analisis perubahan jangka panjang dan pembentukan fitur deret waktu.

== Penambangan data deret waktu iklim

Penambangan data iklim tidak dapat diperlakukan sepenuhnya sama seperti data tabular acak. Setiap baris memiliki urutan waktu, sehingga data masa depan tidak boleh digunakan untuk melatih model yang dievaluasi pada masa lalu. Pembagian data secara temporal digunakan untuk menjaga validitas evaluasi. Selain itu, kejadian kekeringan parah biasanya lebih jarang daripada kondisi normal. Ketidakseimbangan ini membuat akurasi saja tidak cukup sebagai ukuran performa, sehingga metrik seperti F1 makro dan analisis _confusion matrix_ perlu digunakan untuk melihat kemampuan model pada setiap kelas.

= Metode penelitian

== Desain penelitian

Penelitian ini merupakan penelitian kuantitatif berbasis penambangan data. Unit analisisnya adalah observasi iklim harian di Dramaga, Bogor. Alur kerja disusun mengikuti prinsip CRISP DM, yaitu memahami masalah, memahami data, menyiapkan data, membangun model, mengevaluasi model, dan menyiapkan keluaran yang dapat digunakan @chapman2000. Pada tahap laporan ini, penjelasan diarahkan pada proses sebelum pemodelan dan rancangan evaluasi agar dasar analisis dapat ditelusuri dengan jelas.

Alur penelitian pada Gambar @fig:alur memperlihatkan urutan kerja yang digunakan dalam proyek ini. Urutan tersebut dimulai dari pengumpulan data iklim harian, dilanjutkan dengan prapemrosesan, rekayasa fitur, pelabelan kekeringan, pembagian data secara temporal, pemodelan, dan evaluasi. Penyusunan alur seperti ini diperlukan agar setiap keputusan analisis dapat dilacak dari data mentah sampai keluaran model.

// Gambar alur penelitian
#figure(
  caption: [Alur pengerjaan proyek klasifikasi kekeringan agrometeorologi],
)[
  #diagram(
    node-stroke: 0.8pt,
    spacing: 2.6em,
    node((0, 0), align(center)[Pengumpulan data iklim harian\ ERA5, 1980 sampai 2024], corner-radius: 2pt),
    node((0, 1), align(center)[Prapemrosesan data\ konversi waktu, nilai kosong, pencilan], corner-radius: 2pt),
    node((0, 2), align(center)[Rekayasa fitur\ neraca air, SPEI, fitur temporal], corner-radius: 2pt),
    node((0, 3), align(center)[Pelabelan kelas kekeringan\ berbasis SPEI 30 hari], corner-radius: 2pt),
    node((0, 4), align(center)[Pembagian temporal dan pemodelan\ data latih dan data uji], corner-radius: 2pt),
    node((0, 5), align(center)[Evaluasi dan interpretasi], corner-radius: 2pt),

    edge((0, 0), (0, 1), "-|>"),
    edge((0, 1), (0, 2), "-|>"),
    edge((0, 2), (0, 3), "-|>"),
    edge((0, 3), (0, 4), "-|>"),
    edge((0, 4), (0, 5), "-|>"),
  )
] <fig:alur>

== Lokasi dan periode data

Lokasi penelitian berada di sekitar 6,5624 derajat Lintang Selatan dan 106,7319 derajat Bujur Timur. Periode observasi mencakup 1 Januari 1980 sampai 31 Desember 2024. Dataset mentah terdiri atas 16.437 baris harian dan 14 kolom variabel iklim. Setelah proses rekayasa fitur dan penghapusan baris yang belum memiliki nilai lengkap akibat kebutuhan jendela historis, dataset akhir berisi 16.258 baris dan 40 kolom.

== Sumber data dan variabel

Data diperoleh dari _Open Meteo Historical Weather API_ dengan parameter koordinat Dramaga, periode harian, dan zona waktu Asia Jakarta. Variabel dasar meliputi suhu udara rata rata, maksimum, dan minimum pada ketinggian 2 meter, presipitasi, curah hujan, ET0 FAO, radiasi gelombang pendek, kelembapan relatif, defisit tekanan uap, kecepatan angin maksimum pada ketinggian 10 meter, arah angin dominan, suhu tanah lapisan 0 sampai 7 sentimeter, serta kelembapan tanah pada lapisan yang sama. Kumpulan variabel tersebut dipilih karena mencakup masukan air, kehilangan air, energi permukaan, kondisi atmosfer, dan respons tanah.

== Pemahaman data awal

Sebelum rekayasa fitur dilakukan, data diperiksa melalui visualisasi deret waktu dan hubungan antarvariabel. Gambar @fig:tren menampilkan perubahan beberapa unsur iklim utama pada periode 1980 sampai 2024. Visualisasi ini digunakan untuk melihat pola jangka panjang, variasi tahunan, serta periode yang berpotensi berhubungan dengan anomali iklim. Pemeriksaan awal semacam ini membantu memastikan bahwa proses pemodelan tidak hanya bergantung pada angka ringkasan, tetapi juga memahami dinamika deret waktu.

// Gambar tren iklim
#figure(
  image("figures/eda_tren_jangka_panjang.png", width: 100%),
  caption: [Tren jangka panjang variabel iklim Dramaga tahun 1980 sampai 2024],
) <fig:tren>

Gambar @fig:korelasi memperlihatkan korelasi antarvariabel iklim harian. Korelasi digunakan untuk membaca kedekatan hubungan antarunsur iklim, misalnya hubungan antara suhu, evapotranspirasi, dan kelembapan tanah. Informasi ini tidak digunakan sebagai satu satunya dasar seleksi fitur, tetapi membantu menilai apakah fitur yang dibentuk masih memiliki makna fisik dan tidak sepenuhnya terlepas dari proses klimatologis.

// Gambar korelasi variabel
#figure(
  image("figures/eda_korelasi.png", width: 100%),
  caption: [Korelasi antarvariabel iklim harian],
) <fig:korelasi>

== Akuisisi dan penyimpanan data

Akuisisi data dilakukan melalui skrip `scrape/scrape_data.py`. Skrip tersebut membuat klien API dengan mekanisme penyimpanan sementara dan pengulangan permintaan agar proses pengambilan data lebih stabil. Respons API diubah menjadi tabel harian dan disimpan dalam format CSV. Dataset mentah yang digunakan dalam analisis adalah `dataset_iklim_dramaga_1980_2024_completed.csv`, sedangkan dataset hasil rekayasa fitur disimpan sebagai `dataset_featured_dramaga.csv`.

== Prapemrosesan data

Prapemrosesan dimulai dari kolom tanggal. Data mentah memiliki penanda waktu dalam UTC, lalu dikonversi ke zona waktu Asia Jakarta dan dinormalisasi menjadi tanggal harian. Tahap ini diperlukan agar setiap baris merepresentasikan hari lokal yang benar. Kesalahan pada tahap tanggal dapat memengaruhi agregasi harian, pembentukan jendela bergulir, dan penetapan target.

Setelah tanggal konsisten, data diperiksa dari sisi kelengkapan nilai dan kesinambungan tanggal. Pemeriksaan nilai kosong dilakukan pada setiap kolom, sedangkan kesinambungan tanggal diperiksa dengan membandingkan indeks data terhadap rentang tanggal harian penuh. Langkah ini penting karena fitur berbasis akumulasi membutuhkan urutan observasi yang utuh. Jika ada tanggal yang hilang, akumulasi 30, 90, atau 180 hari dapat menjadi tidak representatif.

Pencilan diperiksa menggunakan rentang antarkuartil. Pada data iklim, nilai ekstrem tidak serta merta dihapus karena dapat merepresentasikan kejadian nyata, misalnya hujan sangat tinggi atau periode panas yang kuat. Oleh karena itu, deteksi pencilan digunakan sebagai pemeriksaan diagnostik, bukan sebagai aturan pembersihan otomatis. Keputusan ini menjaga agar sinyal kejadian ekstrem tetap tersedia bagi tahap analisis berikutnya.

== Rekayasa fitur neraca air

Fitur neraca air harian dihitung sebagai presipitasi dikurangi ET0. Nilai positif menunjukkan masukan air lebih besar daripada kebutuhan evaporatif acuan, sedangkan nilai negatif menunjukkan defisit harian. Karena kekeringan berkembang melalui akumulasi defisit, neraca air harian kemudian dijumlahkan dalam jendela 30, 90, dan 180 hari. Jendela 30 hari menggambarkan tekanan jangka pendek, jendela 90 hari menggambarkan kondisi musiman, dan jendela 180 hari menggambarkan akumulasi defisit yang lebih panjang.

== Penghitungan SPEI

SPEI dihitung dari akumulasi neraca air yang distandardisasi terhadap periode referensi 1981 sampai 2010. Standardisasi dilakukan secara terpisah untuk setiap bulan kalender. Dengan demikian, nilai Januari dibandingkan dengan karakter Januari pada periode referensi, nilai Februari dibandingkan dengan karakter Februari, dan seterusnya. Pendekatan ini mengurangi pengaruh musim sehingga SPEI lebih mencerminkan anomali neraca air daripada perbedaan alami antarbulan.

Secara operasional, rata rata dan simpangan baku akumulasi neraca air dihitung per bulan kalender pada periode referensi. Nilai aktual kemudian dikurangi rata rata referensi dan dibagi simpangan baku referensi. Nilai akhir dibatasi pada rentang minus 3 sampai 3 untuk menjaga kestabilan numerik. Hasilnya adalah indeks tanpa satuan yang dapat dibandingkan antarwaktu dan antarskala jendela.

Distribusi SPEI 30 hari diperiksa setelah standardisasi untuk memastikan nilai indeks berada pada skala yang dapat ditafsirkan. Gambar @fig:spei menunjukkan bahwa nilai SPEI terpusat di sekitar nol dengan sisi negatif yang merepresentasikan kondisi kering. Pemeriksaan ini penting karena target klasifikasi dibentuk langsung dari batas nilai SPEI.

// Gambar distribusi SPEI
#figure(
  image("figures/pra_spei_histogram.svg", width: 100%),
  caption: [Distribusi SPEI 30 hari setelah prapemrosesan],
) <fig:spei>

== Fitur agrometeorologi dan temporal

Fitur turunan lain dibentuk untuk memperkuat representasi proses kekeringan. Presipitasi dan ET0 dijumlahkan pada jendela 30, 90, dan 180 hari. Suhu rata rata dan kelembapan tanah dihitung sebagai rata rata bergerak 30 hari. Indeks ariditas dihitung dari rasio presipitasi terhadap ET0, sedangkan defisit air tanah dihitung dari selisih ET0 dan presipitasi dengan batas bawah nol. Anomali suhu dihitung terhadap klimatologi bulanan periode 1981 sampai 2010.

Fitur temporal ditambahkan untuk menangkap struktur musiman dan memori kondisi sebelumnya. Bulan kalender dikodekan menggunakan sinus dan kosinus agar hubungan Desember dan Januari tetap berdekatan dalam ruang fitur. Neraca air juga diberi jeda waktu 1 hari, 7 hari, dan 30 hari. Gabungan fitur tersebut memungkinkan model memanfaatkan kondisi meteorologis saat ini, akumulasi historis, dan posisi musim dalam satu representasi data.

== Pembentukan target klasifikasi

Target klasifikasi dibentuk dari SPEI 30 hari. Observasi diberi label normal apabila SPEI lebih besar dari minus 0,50. Kekeringan ringan diberikan untuk nilai sampai minus 1,00, kekeringan sedang untuk nilai sampai minus 1,50, dan kekeringan parah untuk nilai lebih kecil atau sama dengan minus 1,50. Label tersebut disimpan dalam kolom `drought_class` dengan kode 0 untuk normal, 1 untuk ringan, 2 untuk sedang, dan 3 untuk parah.

Distribusi kelas pada Gambar @fig:kelas menunjukkan proporsi kejadian normal, kekeringan ringan, kekeringan sedang, dan kekeringan parah setelah target dibentuk. Informasi ini digunakan untuk menilai tingkat ketidakseimbangan kelas sebelum pemodelan. Apabila kelas parah jauh lebih sedikit daripada kelas normal, evaluasi model perlu menekankan kemampuan mengenali setiap kelas, bukan hanya akurasi keseluruhan.

// Gambar distribusi kelas
#figure(
  image("figures/pra_kelas_kekeringan.svg", width: 85%),
  caption: [Distribusi kelas kekeringan berbasis SPEI 30 hari],
) <fig:kelas>

Pemilihan SPEI 30 hari sebagai target didasarkan pada kebutuhan klasifikasi kondisi agrometeorologi jangka pendek. Sementara itu, SPEI 90 hari dan 180 hari tetap dipertahankan sebagai fitur karena keduanya memuat informasi defisit yang lebih lama. Rancangan ini memisahkan peran target dan fitur: target mewakili kelas kondisi terkini, sedangkan fitur memberi konteks historis yang membantu model mengenali perubahan kelas.

== Pembersihan akhir dan pembagian data

Setelah seluruh fitur dan target tersedia, baris dengan nilai kosong dihapus. Nilai kosong terutama muncul pada awal deret karena jendela historis 180 hari dan jeda waktu 30 hari belum terpenuhi. Dataset akhir kemudian digunakan sebagai masukan untuk tahap pemodelan. Pembagian data dilakukan secara temporal dengan 80 persen bagian awal sebagai data latih dan 20 persen bagian akhir sebagai data uji. Pendekatan ini menjaga agar evaluasi menyerupai situasi prediksi nyata, yaitu model dilatih pada masa lalu dan diuji pada periode yang lebih baru.

Pada tahap pemodelan, fitur numerik diskalakan menggunakan _StandardScaler_. Ketidakseimbangan kelas ditangani dengan _Synthetic Minority Oversampling Technique_ atau SMOTE hanya pada data latih. Data uji tidak dikenai oversampling agar distribusinya tetap mencerminkan kondisi historis yang sebenarnya. Keputusan ini penting karena evaluasi harus menunjukkan kinerja model pada data yang tidak dimodifikasi.

== Rancangan pemodelan dan evaluasi

Model yang disiapkan meliputi _Random Forest_, _XGBoost_, _LightGBM_, dan _Multi Layer Perceptron_. Model tersebut dipilih untuk membandingkan pendekatan berbasis ansambel pohon, _gradient boosting_, dan jaringan saraf sederhana pada data tabular iklim. Evaluasi utama menggunakan F1 makro karena metrik tersebut memberikan bobot setara pada setiap kelas. _Confusion matrix_ digunakan untuk menilai pola kesalahan, terutama apakah model cenderung menganggap kejadian parah sebagai kelas yang lebih ringan.

Selain klasifikasi kelas harian, proyek ini menyiapkan tugas prediksi risiko kekeringan minimal sedang dalam 30 hari ke depan. Target risiko bernilai 1 apabila dalam 30 hari setelah tanggal prediksi terdapat minimal satu hari dengan SPEI 30 lebih kecil atau sama dengan minus 1,00. Rancangan ini lebih sesuai untuk konteks peringatan dini karena pengguna lebih membutuhkan informasi risiko dalam jendela waktu tertentu daripada prediksi kelas tepat pada satu hari.

= Daftar pustaka

#bibliography("reference.bib", title: none, style: "ieee")
