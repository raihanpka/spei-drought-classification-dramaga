#import "@preview/fletcher:0.5.8": diagram, edge, node

// --- TEMPLATE DEFINITION ---
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
  // Document and Page Setup
  set document(title: title)
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 3cm, left: 3cm, right: 3cm),
    header: context {
      // Only show page number starting from page 2, centered at the top
      if counter(page).get().first() > 1 {
        align(center)[#counter(page).get().first()]
      }
    },
  )

  // Font and Paragraph Setup
  set text(font: "Times New Roman", size: 11pt, lang: "id")
  set par(justify: true, leading: 0.65em, first-line-indent: 1.5em)

  // Customizing the footnote for the affiliation block
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt))
  set footnote(numbering: "*")

  // Heading Level 1 (e.g., PENDAHULUAN) - All Caps, Bold
  show heading.where(level: 1): it => block(above: 1.5em, below: 1em)[
    #set text(weight: "bold")
    #upper(it.body)
  ]

  // Heading Level 2 (e.g., Latar Belakang) - Bold
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.8em)[
    #set text(weight: "bold")
    #it.body
  ]

  // --- FIRST PAGE HEADER ---
  block(width: 100%, [
    #set par(first-line-indent: 0em) // Disable indent for metadata
    *Laporan Akhir Tugas MK. Data Mining (KOM1338), Semester Genap 2024/2025*\
    *Program Studi Sarjana Ilmu Komputer*\
    *SSMI IPB*
  ])

  v(1.5em)

  // --- TITLE ---
  block(width: 100%, [
    #set par(first-line-indent: 0em)
    #set text(size: 12pt, weight: "bold")
    #title
  ])

  v(1em)

  // --- AUTHORS & AFFILIATION ---
  block(width: 100%, [
    #set par(first-line-indent: 0em)
    // Join authors and attach the footnote to the end
    #authors.join(", ")#footnote[
      #set text(size: 9pt)
      #set par(first-line-indent: 0em)
      Program Studi Sarjana Ilmu Komputer, Sekolah Sains Data, Matematika dan Informatika (SSMI), Institut Pertanian Bogor, Bogor 16680 \
      \*Mahasiswa Program Studi Sarjana Ilmu Komputer, SSMI IPB; Surel: #emails.join(", ")
    ] \
    Kelompok: #group, Kelas Paralel: #class
  ])

  // v(2em)

  // --- ABSTRACT ---
  // block(width: 100%, [
    // #set par(first-line-indent: 0em)
    // #align(center)[*Abstrak*]
    // #v(0.5em)

    // #set par(first-line-indent: 1.5em)
    // #abstract

    // #v(0.5em)
    // #set par(first-line-indent: 0em)
    // *Kata Kunci:* #keywords
  // ])

  v(2em)

  // --- MAIN CONTENT ---
  body
}

#let daftar-pustaka(bibfile, style: "ipb.csl") = {
  // pagebreak(weak: true)
  // // Heading level 1 tanpa nomor bab, tetap masuk outline (Daftar Isi)
  // heading(level: 1, numbering: none, outlined: true)[DAFTAR PUSTAKA]
  // // Reset counter agar bab berikutnya tidak terganggu
  // counter(heading).update((ch, ..rest) => (calc.max(0, ch - 1),))
  // set par(
  //   first-line-indent: 0pt,
  //   hanging-indent: 1cm, // setiap entri: baris kedua dst. menjorok 1 cm
  //   leading: _leading,
  //   spacing: _leading,
  //   justify: true,
  // )
  bibliography(bibfile, title: none, style: style)
}



// --- DOCUMENT CONTENT ---
// Fill in your details below to use the template

#show: laporan_akhir.with(
  title: [Analisis Data Sosial Media Mengenai Kualitas Udara di Jakarta menggunakan _Text Mining_],
  authors: (
    "Raihan Putra Kirana (G6401231027)",
    "Daffa Aulia Musyaffa Subyantoro (G6401231028)",
    "Muhammad Chalied Al Walid (G6401231114)",
    "Insan Anshary Rasul (G6401231132)"
  ),
  group: "8",
  class: "1",
  emails: ("username1@yahoo.co.id", "username1@yahoo.co.id"),
  // abstract: [
  //   Abstrak ditulis dalam 1 paragraf dan panjangnya tidak lebih dari 200 kata. Abstrak dimulai dengan uraian latar belakang tugas akhir dalam 2-3 kalimat, metode, dan hasil temuan utama yang secara langsung menjawab masalah yang dikaji. Hindari penggunaan singkatan.
  // ],
  // keywords: "Kata Kunci terdiri atas maksimum 5 kata yang diurutkan mengikuti abjad.",
)

// = PENDAHULUAN
// == Latar Belakang
// Menjelaskan latar belakang dan perumusan masalah terkait topik tugas akhir.

// == Tujuan
// Menjelaskan tujuan dari tugas akhir.

// == Ruang Lingkup
// Menjelaskan ruang lingkup kegiatan yang dilakukan, meliputi data dan teknik yang digunakan.

// == Manfaat
// Menjelaskan secara singkat manfaat dari hasil yang diperoleh dalam tugas akhir.

// = TINJAUAN PUSTAKA
// Tinjauan pustaka memuat tinjauan singkat dan jelas atas pustaka yang mendasari bidang kajian. Pustaka yang digunakan sebaiknya berupa pustaka terbaru yang relevan dengan bidang kajian. Pengacuan pada pustaka harus sesuai dengan yang tercantum dalam Daftar Pustaka.

= METODE

== *Data*

Data yang digunakan berupa data iklim harian Dramaga, Bogor periode 1980-2024 (hasil ekstraksi ERA5) dalam format CSV.
Variabel utama meliputi suhu 2 meter (mean/max/min), curah hujan, ET0 FAO, kelembapan relatif, dan kelembapan tanah lapisan 0-7 cm.
Kolom tanggal dikonversi dari UTC ke WIB dan dinormalisasi menjadi tanggal harian agar konsisten untuk agregasi dan perhitungan rolling window.

== *Tahapan Kegiatan*

Tahapan mengikuti alur KDD: seleksi data, cleaning, transformasi/feature engineering, data mining (klasifikasi), dan evaluasi.
Rincian tahapan utama sebagai berikut.
- Pengumpulan dan inspeksi data iklim harian (1980-2024)
- Praproses data (konversi waktu, cek missing, deteksi outlier)
- Feature engineering (water balance, rolling, SPEI, fitur temporal)
- Pelabelan kelas kekeringan berbasis SPEI-30
- Split temporal train/test dan pemodelan klasifikasi
- Evaluasi dan interpretasi hasil

#figure(
  caption: [Flow chart pengerjaan proyek],
)[
  #diagram(
    node-stroke: 0.8pt,
    spacing: 3.2em,
    node((0, 0), align(center)[Pengumpulan data iklim harian\ (ERA5, 1980-2024)], corner-radius: 2pt),
    node((0, 1), align(center)[Praproses dan cleaning\ (UTC->WIB, cek missing, IQR)], corner-radius: 2pt),
    node((0, 2), align(center)[Feature engineering\ (water balance, SPEI, rolling)], corner-radius: 2pt),
    node((0, 3), align(center)[Pelabelan kelas kekeringan\ (SPEI-30 thresholds)], corner-radius: 2pt),
    node((0, 4), align(center)[Split temporal dan modelling\ (train/test 80/20)], corner-radius: 2pt),
    node((0, 5), align(center)[Evaluasi dan interpretasi], corner-radius: 2pt),

    edge((0, 0), (0, 1), "-|>"),
    edge((0, 1), (0, 2), "-|>"),
    edge((0, 2), (0, 3), "-|>"),
    edge((0, 3), (0, 4), "-|>"),
    edge((0, 4), (0, 5), "-|>"),
  )
]

== *Praproses Data*

Langkah praproses yang digunakan beserta alasannya adalah sebagai berikut.
- Konversi waktu UTC ke WIB dan normalisasi tanggal harian agar data konsisten untuk analisis deret waktu.
- Pemeriksaan missing value dan missing tanggal untuk memastikan kelengkapan sebelum rolling window.
- Deteksi outlier dengan IQR untuk mengidentifikasi nilai ekstrem yang dapat mendistorsi statistik.
- Perhitungan water balance (P - ET0) sebagai indikator ketersediaan air harian.
- Rolling akumulasi 30/90/180 hari untuk menangkap memori kelembapan jangka pendek, menengah, dan panjang.
- Standardisasi SPEI dengan z-score per bulan (baseline 1981-2010) untuk menghilangkan efek musiman.
- Pembentukan fitur agrometeorologi (rolling precip/ET0, aridity index, soil water deficit, anomali suhu) guna memperkaya sinyal kekeringan.
- Fitur temporal berupa lag water balance (1/7/30 hari) dan encoding sin/cos bulan untuk menjaga kontinuitas musim.
- Pelabelan kelas kekeringan berbasis ambang SPEI-30 sebagai target klasifikasi.
- Cleaning akhir dengan menghapus baris NaN dan split temporal 80/20 untuk mencegah data leakage.
Lingkungan Pengembangan

Dijelaskan perangkat keras dan perangkat lunak yang digunakan dalam tugas akhir ini.

= HASIL DAN PEMBAHASAN
== Visualisasi Data Awal

Visualisasi tren jangka panjang memperlihatkan dinamika suhu, curah hujan, ET0, dan kelembapan tanah dalam periode 1980-2024, termasuk periode anomali iklim yang ditandai pada grafik.
#figure(
  image("figures/eda_tren_jangka_panjang.png", width: 100%),
  caption: [Tren jangka panjang variabel iklim Dramaga 1980-2024],
)

Heatmap korelasi menunjukkan keterkaitan antar variabel iklim. Pola korelasi membantu memilih fitur dan memahami hubungan fisik, misalnya kecenderungan suhu yang searah dengan ET0 dan berlawanan dengan kelembapan tanah.
#figure(
  image("figures/eda_korelasi.png", width: 100%),
  caption: [Korelasi antar variabel iklim harian],
)

== Hasil Praproses

Histogram SPEI-30 memperlihatkan distribusi indeks kekeringan yang terpusat di sekitar nol (hasil standardisasi), dengan ekor negatif yang mewakili kejadian kekeringan.
#figure(
  image("figures/pra_spei_histogram.svg", width: 100%),
  caption: [Distribusi SPEI-30 setelah praproses],
)

Distribusi kelas kekeringan menunjukkan ketidakseimbangan kelas, sehingga pada tahap modelling diperlukan teknik penanganan imbalance.
#figure(
  image("figures/pra_kelas_kekeringan.svg", width: 85%),
  caption: [Distribusi kelas kekeringan berbasis SPEI-30],
)

== Interpretasi Hasil Praproses

- Standardisasi SPEI per bulan membuat skala antar musim dapat dibandingkan langsung dan memudahkan identifikasi kejadian kering/anomali.
- Rolling window 30/90/180 hari mengungkap memori kelembapan yang berbeda, sehingga fitur mampu merepresentasikan kekeringan jangka pendek sampai panjang.
- Ketidakseimbangan kelas mengindikasikan kejadian kekeringan berat lebih jarang dibanding kondisi normal; hal ini perlu diantisipasi pada pemodelan.

// = KESIMPULAN DAN SARAN
// Bagian ini mengemukakan kesimpulan yang diperoleh dari kegiatan ini beserta saran perbaikan terkait dengan hasil yang diperoleh. @smith2020novel

// = DAFTAR PUSTAKA

// #daftar-pustaka("reference.bib", style: "ipb.csl")
