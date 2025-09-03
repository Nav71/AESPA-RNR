const express = require('express');
const router = express.Router();

// Mock data untuk publikasi
let publikasiData = [
  {
    id: 1,
    judul: 'Statistik Indonesia 2024',
    slug: 'statistik-indonesia-2024',
    deskripsi: 'Publikasi tahunan berisi data statistik komprehensif Indonesia tahun 2024',
    kategori_id: 1,
    kategori_nama: 'Ekonomi',
    tipe: 'buku',
    isbn: '978-602-438-123-4',
    penulis: ['Badan Pusat Statistik'],
    editor: 'Dr. Statistika Indonesia',
    penerbit: 'BPS Indonesia',
    tahun_terbit: 2024,
    jumlah_halaman: 450,
    bahasa: 'id',
    abstrak: 'Publikasi ini menyajikan data statistik terkini mengenai kondisi sosial ekonomi Indonesia pada tahun 2024, meliputi demografi, ekonomi, pendidikan, kesehatan, dan lingkungan.',
    kata_kunci: ['statistik', 'indonesia', 'ekonomi', 'demografi', '2024'],
    file_pdf: 'https://example.com/publikasi/statistik-indonesia-2024.pdf',
    cover_image: 'https://example.com/covers/statistik-indonesia-2024.jpg',
    ukuran_file: '25.6 MB',
    tanggal_publikasi: '2024-03-15T00:00:00.000Z',
    tanggal_upload: '2024-03-16T10:30:00.000Z',
    status: 'published',
    views: 2850,
    downloads: 1247,
    rating: 4.5,
    jumlah_rating: 89,
    is_featured: true,
    created_at: '2024-02-01T08:00:00.000Z',
    updated_at: '2024-03-16T10:30:00.000Z'
  },
  {
    id: 2,
    judul: 'Indeks Pembangunan Manusia Indonesia 2023',
    slug: 'ipm-indonesia-2023',
    deskripsi: 'Analisis mendalam tentang perkembangan Indeks Pembangunan Manusia di seluruh provinsi Indonesia',
    kategori_id: 4,
    kategori_nama: 'Pendidikan',
    tipe: 'laporan',
    isbn: null,
    penulis: ['Tim IPM BPS', 'Dr. Pembangunan Manusia'],
    editor: 'Prof. Indeks Nasional',
    penerbit: 'BPS Indonesia',
    tahun_terbit: 2023,
    jumlah_halaman: 180,
    bahasa: 'id',
    abstrak: 'Laporan ini menganalisis capaian dan tantangan dalam pembangunan manusia di Indonesia, dengan fokus pada aspek pendidikan, kesehatan, dan ekonomi.',
    kata_kunci: ['ipm', 'pembangunan manusia', 'pendidikan', 'kesehatan', 'provinsi'],
    file_pdf: 'https://example.com/publikasi/ipm-indonesia-2023.pdf',
    cover_image: 'https://example.com/covers/ipm-indonesia-2023.jpg',
    ukuran_file: '12.3 MB',
    tanggal_publikasi: '2023-12-10T00:00:00.000Z',
    tanggal_upload: '2023-12-11T14:20:00.000Z',
    status: 'published',
    views: 1920,
    downloads: 856,
    rating: 4.2,
    jumlah_rating: 45,
    is_featured: false,
    created_at: '2023-11-01T09:00:00.000Z',
    updated_at: '2023-12-11T14:20:00.000Z'
  },
  {
    id: 3,
    judul: 'Survei Angkatan Kerja Nasional (SAKERNAS) 2024',
    slug: 'sakernas-2024',
    deskripsi: 'Hasil survei ketenagakerjaan nasional yang mencakup tingkat pengangguran, partisipasi angkatan kerja, dan kondisi ketenagakerjaan',
    kategori_id: 1,
    kategori_nama: 'Ekonomi',
    tipe: 'survei',
    isbn: '978-602-438-156-7',
    penulis: ['Direktorat Statistik Ketenagakerjaan'],
    editor: 'Dr. Tenaga Kerja',
    penerbit: 'BPS Indonesia',
    tahun_terbit: 2024,
    jumlah_halaman: 320,
    bahasa: 'id',
    abstrak: 'Publikasi hasil SAKERNAS 2024 yang menyajikan data komprehensif tentang kondisi ketenagakerjaan di Indonesia, termasuk analisis tren dan proyeksi.',
    kata_kunci: ['sakernas', 'ketenagakerjaan', 'pengangguran', 'angkatan kerja', 'survei'],
    file_pdf: 'https://example.com/publikasi/sakernas-2024.pdf',
    cover_image: 'https://example.com/covers/sakernas-2024.jpg',
    ukuran_file: '18.7 MB',
    tanggal_publikasi: '2024-02-20T00:00:00.000Z',
    tanggal_upload: '2024-02-21T11:45:00.000Z',
    status: 'published',
    views: 1650,
    downloads: 723,
    rating: 4.3,
    jumlah_rating: 67,
    is_featured: true,
    created_at: '2024-01-15T10:00:00.000Z',
    updated_at: '2024-02-21T11:45:00.000Z'
  },
  {
    id: 4,
    judul: 'Profil Kesehatan Indonesia 2023',
    slug: 'profil-kesehatan-indonesia-2023',
    deskripsi: 'Gambaran lengkap kondisi kesehatan masyarakat Indonesia berdasarkan data tahun 2023',
    kategori_id: 5,
    kategori_nama: 'Kesehatan',
    tipe: 'profil',
    isbn: '978-602-438-189-5',
    penulis: ['Kementerian Kesehatan RI', 'BPS Indonesia'],
    editor: 'Dr. Kesehatan Masyarakat',
    penerbit: 'Kemenkes RI & BPS',
    tahun_terbit: 2023,
    jumlah_halaman: 280,
    bahasa: 'id',
    abstrak: 'Profil kesehatan yang menampilkan indikator kesehatan utama, fasilitas kesehatan, dan program-program kesehatan masyarakat di Indonesia.',
    kata_kunci: ['kesehatan', 'profil kesehatan', 'indikator kesehatan', 'fasilitas kesehatan', 'masyarakat'],
    file_pdf: 'https://example.com/publikasi/profil-kesehatan-2023.pdf',
    cover_image: 'https://example.com/covers/profil-kesehatan-2023.jpg',
    ukuran_file: '22.1 MB',
    tanggal_publikasi: '2023-11-30T00:00:00.000Z',
    tanggal_upload: '2023-12-01T16:15:00.000Z',
    status: 'published',
    views: 1340,
    downloads: 587,
    rating: 4.1,
    jumlah_rating: 34,
    is_featured: false,
    created_at: '2023-10-01T12:00:00.000Z',
    updated_at: '2023-12-01T16:15:00.000Z'
  },
  {
    id: 5,
    judul: 'Indikator Lingkungan Hidup Indonesia 2024',
    slug: 'indikator-lingkungan-2024',
    deskripsi: 'Data dan analisis indikator lingkungan hidup Indonesia tahun 2024',
    kategori_id: 6,
    kategori_nama: 'Lingkungan',
    tipe: 'indikator',
    isbn: '978-602-438-201-4',
    penulis: ['KLHK', 'BPS Indonesia'],
    editor: 'Prof. Lingkungan Hidup',
    penerbit: 'KLHK & BPS',
    tahun_terbit: 2024,
    jumlah_halaman: 195,
    bahasa: 'id',
    abstrak: 'Publikasi yang menyajikan berbagai indikator lingkungan hidup Indonesia, meliputi kualitas air, udara, hutan, dan keanekaragaman hayati.',
    kata_kunci: ['lingkungan hidup', 'indikator lingkungan', 'kualitas air', 'kualitas udara', 'hutan'],
    file_pdf: 'https://example.com/publikasi/indikator-lingkungan-2024.pdf',
    cover_image: 'https://example.com/covers/indikator-lingkungan-2024.jpg',
    ukuran_file: '15.8 MB',
    tanggal_publikasi: '2024-01-25T00:00:00.000Z',
    tanggal_upload: '2024-01-26T09:30:00.000Z',
    status: 'draft',
    views: 890,
    downloads: 312,
    rating: 4.0,
    jumlah_rating: 18,
    is_featured: false,
    created_at: '2023-12-15T14:00:00.000Z',
    updated_at: '2024-01-26T09:30:00.000Z'
  }
];

// GET semua publikasi dengan filter dan pagination
router.get('/', (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      kategori_id, 
      tipe, 
      status, 
      tahun_terbit,
      bahasa,
      featured,
      search,
      sort_by = 'tanggal_publikasi',
      sort_order = 'desc'
    } = req.query;

    let filteredPublikasi = [...publikasiData];

    // Filter by kategori_id
    if (kategori_id) {
      filteredPublikasi = filteredPublikasi.filter(pub => 
        pub.kategori_id === parseInt(kategori_id)
      );
    }

    // Filter by tipe
    if (tipe) {
      filteredPublikasi = filteredPublikasi.filter(pub => 
        pub.tipe.toLowerCase() === tipe.toLowerCase()
      );
    }

    // Filter by status
    if (status) {
      filteredPublikasi = filteredPublikasi.filter(pub => 
        pub.status.toLowerCase() === status.toLowerCase()
      );
    }

    // Filter by tahun_terbit
    if (tahun_terbit) {
      filteredPublikasi = filteredPublikasi.filter(pub => 
        pub.tahun_terbit === parseInt(tahun_terbit)
      );
    }

    // Filter by bahasa
    if (bahasa) {
      filteredPublikasi = filteredPublikasi.filter(pub => 
        pub.bahasa === bahasa
      );
    }

    // Filter by featured
    if (featured) {
      filteredPublikasi = filteredPublikasi.filter(pub => 
        pub.is_featured === (featured === 'true')
      );
    }

    // Search by judul, deskripsi, atau kata kunci
    if (search) {
      const searchTerm = search.toLowerCase();
      filteredPublikasi = filteredPublikasi.filter(pub =>
        pub.judul.toLowerCase().includes(searchTerm) ||
        pub.deskripsi.toLowerCase().includes(searchTerm) ||
        pub.kata_kunci.some(kw => kw.toLowerCase().includes(searchTerm)) ||
        pub.penulis.some(p => p.toLowerCase().includes(searchTerm))
      );
    }

    // Sorting
    filteredPublikasi.sort((a, b) => {
      let valueA = a[sort_by];
      let valueB = b[sort_by];

      if (sort_by === 'tanggal_publikasi' || sort_by === 'created_at' || sort_by === 'updated_at') {
        valueA = new Date(valueA);
        valueB = new Date(valueB);
      }

      if (sort_order === 'desc') {
        return valueB > valueA ? 1 : valueB < valueA ? -1 : 0;
      } else {
        return valueA > valueB ? 1 : valueA < valueB ? -1 : 0;
      }
    });

    // Pagination
    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const paginatedData = filteredPublikasi.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: paginatedData,
      pagination: {
        current_page: parseInt(page),
        total_pages: Math.ceil(filteredPublikasi.length / limit),
        total_items: filteredPublikasi.length,
        items_per_page: parseInt(limit)
      },
      filters_applied: {
        kategori_id,
        tipe,
        status,
        tahun_terbit,
        bahasa,
        featured,
        search
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data publikasi',
      error: error.message
    });
  }
});

// GET publikasi berdasarkan ID
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const publikasi = publikasiData.find(pub => pub.id === parseInt(id));

    if (!publikasi) {
      return res.status(404).json({
        success: false,
        message: 'Publikasi tidak ditemukan'
      });
    }

    // Increment views
    publikasi.views += 1;

    res.json({
      success: true,
      data: publikasi,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data publikasi',
      error: error.message
    });
  }
});

// GET publikasi berdasarkan slug
router.get('/slug/:slug', (req, res) => {
  try {
    const { slug } = req.params;
    const publikasi = publikasiData.find(pub => pub.slug === slug);

    if (!publikasi) {
      return res.status(404).json({
        success: false,
        message: 'Publikasi tidak ditemukan'
      });
    }

    // Increment views
    publikasi.views += 1;

    res.json({
      success: true,
      data: publikasi,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data publikasi',
      error: error.message
    });
  }
});

// GET publikasi terpopuler
router.get('/trending/popular', (req, res) => {
  try {
    const { limit = 10, periode = '30' } = req.query;
    
    // Filter publikasi yang published saja
    const publishedPublikasi = publikasiData.filter(pub => pub.status === 'published');
    
    // Sort by views descending
    const popular = publishedPublikasi
      .sort((a, b) => b.views - a.views)
      .slice(0, parseInt(limit));

    res.json({
      success: true,
      data: popular,
      periode: `${periode} hari terakhir`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil publikasi populer',
      error: error.message
    });
  }
});

// GET publikasi terbaru
router.get('/trending/latest', (req, res) => {
  try {
    const { limit = 10 } = req.query;
    
    // Filter publikasi yang published saja
    const publishedPublikasi = publikasiData.filter(pub => pub.status === 'published');
    
    // Sort by tanggal_publikasi descending
    const latest = publishedPublikasi
      .sort((a, b) => new Date(b.tanggal_publikasi) - new Date(a.tanggal_publikasi))
      .slice(0, parseInt(limit));

    res.json({
      success: true,
      data: latest,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil publikasi terbaru',
      error: error.message
    });
  }
});

// GET publikasi featured
router.get('/featured/list', (req, res) => {
  try {
    const { limit = 5 } = req.query;
    
    const featured = publikasiData
      .filter(pub => pub.is_featured && pub.status === 'published')
      .sort((a, b) => new Date(b.tanggal_publikasi) - new Date(a.tanggal_publikasi))
      .slice(0, parseInt(limit));

    res.json({
      success: true,
      data: featured,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil publikasi featured',
      error: error.message
    });
  }
});

// GET statistik publikasi
router.get('/stats/overview', (req, res) => {
  try {
    const stats = {
      total_publikasi: publikasiData.length,
      publikasi_published: publikasiData.filter(pub => pub.status === 'published').length,
      publikasi_draft: publikasiData.filter(pub => pub.status === 'draft').length,
      publikasi_featured: publikasiData.filter(pub => pub.is_featured).length,
      total_views: publikasiData.reduce((sum, pub) => sum + pub.views, 0),
      total_downloads: publikasiData.reduce((sum, pub) => sum + pub.downloads, 0),
      rata_rata_rating: (publikasiData.reduce((sum, pub) => sum + pub.rating, 0) / publikasiData.length).toFixed(2),
      publikasi_per_kategori: publikasiData.reduce((acc, pub) => {
        const kategori = pub.kategori_nama;
        acc[kategori] = (acc[kategori] || 0) + 1;
        return acc;
      }, {}),
      publikasi_per_tipe: publikasiData.reduce((acc, pub) => {
        acc[pub.tipe] = (acc[pub.tipe] || 0) + 1;
        return acc;
      }, {}),
      publikasi_per_tahun: publikasiData.reduce((acc, pub) => {
        acc[pub.tahun_terbit] = (acc[pub.tahun_terbit] || 0) + 1;
        return acc;
      }, {}),
      publikasi_terpopuler: publikasiData
        .sort((a, b) => b.views - a.views)
        .slice(0, 5)
        .map(pub => ({
          id: pub.id,
          judul: pub.judul,
          views: pub.views,
          downloads: pub.downloads
        }))
    };

    res.json({
      success: true,
      data: stats,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil statistik publikasi',
      error: error.message
    });
  }
});

// POST create publikasi baru
router.post('/', (req, res) => {
  try {
    const {
      judul,
      slug,
      deskripsi,
      kategori_id,
      tipe = 'buku',
      isbn,
      penulis = [],
      editor,
      penerbit,
      tahun_terbit,
      jumlah_halaman,
      bahasa = 'id',
      abstrak,
      kata_kunci = [],
      file_pdf,
      cover_image,
      ukuran_file,
      tanggal_publikasi,
      status = 'draft',
      is_featured = false
    } = req.body;

    if (!judul || !deskripsi || !kategori_id || !penerbit || !tahun_terbit) {
      return res.status(400).json({
        success: false,
        message: 'Field judul, deskripsi, kategori_id, penerbit, dan tahun_terbit harus diisi'
      });
    }

    // Generate slug if not provided
    const finalSlug = slug || judul.toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim('-');

    // Check if slug already exists
    const existingPublikasi = publikasiData.find(pub => pub.slug === finalSlug);
    if (existingPublikasi) {
      return res.status(400).json({
        success: false,
        message: 'Slug sudah digunakan'
      });
    }

    const newPublikasi = {
      id: Math.max(...publikasiData.map(pub => pub.id)) + 1,
      judul,
      slug: finalSlug,
      deskripsi,
      kategori_id: parseInt(kategori_id),
      kategori_nama: 'Unknown', // Dalam implementasi nyata, ambil dari database kategori
      tipe,
      isbn,
      penulis: Array.isArray(penulis) ? penulis : [penulis],
      editor,
      penerbit,
      tahun_terbit: parseInt(tahun_terbit),
      jumlah_halaman: jumlah_halaman ? parseInt(jumlah_halaman) : null,
      bahasa,
      abstrak,
      kata_kunci: Array.isArray(kata_kunci) ? kata_kunci : [],
      file_pdf,
      cover_image,
      ukuran_file,
      tanggal_publikasi: tanggal_publikasi || new Date().toISOString(),
      tanggal_upload: new Date().toISOString(),
      status,
      views: 0,
      downloads: 0,
      rating: 0,
      jumlah_rating: 0,
      is_featured,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    publikasiData.push(newPublikasi);

    res.status(201).json({
      success: true,
      message: 'Publikasi berhasil dibuat',
      data: newPublikasi
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal membuat publikasi',
      error: error.message
    });
  }
});

// PUT update publikasi
router.put('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const index = publikasiData.findIndex(pub => pub.id === parseInt(id));

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Publikasi tidak ditemukan'
      });
    }

    // Check if slug already exists (excluding current item)
    if (updateData.slug && updateData.slug !== publikasiData[index].slug) {
      const existingPublikasi = publikasiData.find(pub => pub.slug === updateData.slug);
      if (existingPublikasi) {
        return res.status(400).json({
          success: false,
          message: 'Slug sudah digunakan'
        });
      }
    }

    const updatedPublikasi = {
      ...publikasiData[index],
      ...updateData,
      kategori_id: updateData.kategori_id ? parseInt(updateData.kategori_id) : publikasiData[index].kategori_id,
      tahun_terbit: updateData.tahun_terbit ? parseInt(updateData.tahun_terbit) : publikasiData[index].tahun_terbit,
      jumlah_halaman: updateData.jumlah_halaman ? parseInt(updateData.jumlah_halaman) : publikasiData[index].jumlah_halaman,
      penulis: updateData.penulis ? (Array.isArray(updateData.penulis) ? updateData.penulis : [updateData.penulis]) : publikasiData[index].penulis,
      kata_kunci: updateData.kata_kunci ? (Array.isArray(updateData.kata_kunci) ? updateData.kata_kunci : []) : publikasiData[index].kata_kunci,
      updated_at: new Date().toISOString()
    };

    publikasiData[index] = updatedPublikasi;

    res.json({
      success: true,
      message: 'Publikasi berhasil diupdate',
      data: updatedPublikasi
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengupdate publikasi',
      error: error.message
    });
  }
});

// DELETE publikasi
router.delete('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const index = publikasiData.findIndex(pub => pub.id === parseInt(id));

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Publikasi tidak ditemukan'
      });
    }

    const deletedPublikasi = publikasiData.splice(index, 1)[0];

    res.json({
      success: true,
      message: 'Publikasi berhasil dihapus',
      data: deletedPublikasi
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal menghapus publikasi',
      error: error.message
    });
  }
});

// POST increment download count
router.post('/:id/download', (req, res) => {
  try {
    const { id } = req.params;
    const publikasi = publikasiData.find(pub => pub.id === parseInt(id));

    if (!publikasi) {
      return res.status(404).json({
        success: false,
        message: 'Publikasi tidak ditemukan'
      });
    }

    publikasi.downloads += 1;

    res.json({
      success: true,
      message: 'Download count berhasil diupdate',
      data: {
        id: publikasi.id,
        judul: publikasi.judul,
        downloads: publikasi.downloads
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengupdate download count',
      error: error.message
    });
  }
});

// POST add rating
router.post('/:id/rating', (req, res) => {
  try {
    const { id } = req.params;
    const { rating } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating harus berupa angka antara 1-5'
      });
    }

    const publikasi = publikasiData.find(pub => pub.id === parseInt(id));

    if (!publikasi) {
      return res.status(404).json({
        success: false,
        message: 'Publikasi tidak ditemukan'
      });
    }

    // Calculate new average rating
    const totalRating = (publikasi.rating * publikasi.jumlah_rating) + parseFloat(rating);
    publikasi.jumlah_rating += 1;
    publikasi.rating = parseFloat((totalRating / publikasi.jumlah_rating).toFixed(2));

    res.json({
      success: true,
      message: 'Rating berhasil ditambahkan',
      data: {
        id: publikasi.id,
        judul: publikasi.judul,
        rating: publikasi.rating,
        jumlah_rating: publikasi.jumlah_rating
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal menambahkan rating',
      error: error.message
    });
  }
});

module.exports = router;