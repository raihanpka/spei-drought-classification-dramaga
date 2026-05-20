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

  v(2em)

  // --- ABSTRACT ---
  block(width: 100%, [
    #set par(first-line-indent: 0em)
    #align(center)[*Abstrak*]
    #v(0.5em)
    
    #set par(first-line-indent: 1.5em)
    #abstract

    #v(0.5em)
    #set par(first-line-indent: 0em)
    *Kata Kunci:* #keywords
  ])

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
    "Diardian Febiani (G64120113)", 
    "Reza Fahlevi (G64120003)", 
    "Yusuf Al Muqaddami (G64120027)"
  ),
  group: "5",
  class: "1",
  emails: ("username1@yahoo.co.id", "username1@yahoo.co.id"),
  abstract: [
    Abstrak ditulis dalam 1 paragraf dan panjangnya tidak lebih dari 200 kata. Abstrak dimulai dengan uraian latar belakang tugas akhir dalam 2-3 kalimat, metode, dan hasil temuan utama yang secara langsung menjawab masalah yang dikaji. Hindari penggunaan singkatan.
  ],
  keywords: "Kata Kunci terdiri atas maksimum 5 kata yang diurutkan mengikuti abjad."
)

= PENDAHULUAN
== Latar Belakang
Menjelaskan latar belakang dan perumusan masalah terkait topik tugas akhir.

== Tujuan
Menjelaskan tujuan dari tugas akhir.

== Ruang Lingkup
Menjelaskan ruang lingkup kegiatan yang dilakukan, meliputi data dan teknik yang digunakan.

== Manfaat
Menjelaskan secara singkat manfaat dari hasil yang diperoleh dalam tugas akhir.

= TINJAUAN PUSTAKA
Tinjauan pustaka memuat tinjauan singkat dan jelas atas pustaka yang mendasari bidang kajian. Pustaka yang digunakan sebaiknya berupa pustaka terbaru yang relevan dengan bidang kajian. Pengacuan pada pustaka harus sesuai dengan yang tercantum dalam Daftar Pustaka.

= METODE

== *Data*

Pada bagian ini dijelaskan data yang digunakan meliputi sumber data, deksripsi singkat tentang data, dan format data.

== *Tahapan Kegiatan*

Bagian ini menjelaskan tahapan kegiatan dalam bentuk penjelasan singkat maupun dalam bentuk diagram alur. Tahapan yang dilakukan dapat mengacu pada proses knowledge discovery in database (KDD).  Jelaskan teknik pra-proses data yang digunakan.
Lingkungan Pengembangan

Dijelaskan perangkat keras dan perangkat lunak yang digunakan dalam tugas akhir ini.

= HASIL DAN PEMBAHASAN
Menjelaskan hasil pra-proses data dan keluaran dari teknik yang diimplementasikan disertai dengan pembahasan terhadap keluaran tersebut.  Untuk memperjelas dan mempersingkat uraian dapat disertakan tabel, gambar, atau grafik.  Tabel dan gambar harus diacu dalam tubuh tulisan dan diletakkan tidak jauh dari kalimat yang mengacunya.

= KESIMPULAN DAN SARAN 
Bagian ini mengemukakan kesimpulan yang diperoleh dari kegiatan ini beserta saran perbaikan terkait dengan hasil yang diperoleh. @smith2020novel

= DAFTAR PUSTAKA

#daftar-pustaka("reference.bib", style: "ipb.csl")