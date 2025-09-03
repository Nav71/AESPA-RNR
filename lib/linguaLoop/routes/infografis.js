const express = require('express');
const router = express.Router();

// Mock data untuk infografis
let infografis = [
  {
    id: 1,
    judul: 'Pertumbuhan Ekonomi Indonesia 2024',
    deskripsi: 'Infografis mengenai pertumbuhan ekonomi Indonesia di tahun 2024',
    kategori: 'ekonomi',
    url_gambar: 'https://example.com/infografis/ekonomi-2024.jpg',
    tanggal_dibuat: '2024-01-15T08:00:00.000Z',
    tanggal_update: '2024-01-15T08:00:00.000Z',
    status: 'published',
    tags: ['ekonomi', 'pdb', 'pertumbuhan'],
    views: 1250,
    downloads: 89
  },
  {
    id: 2,
    judul: 'Demografi Penduduk Indonesia',
    deskripsi: 'Visualisasi data demografi dan sebaran penduduk Indonesia',
    kategori: 'demografi',
    url_gambar: 'https://example.com/infografis/demografi-2024.jpg',
    tanggal_dibuat: '2024-01-10T10:30:00.000Z',
    tanggal_update: '2024-01-12T14:20:00.000Z',
    status: 'published',
    tags: ['demografi', 'penduduk', 'sensus'],
    views: 850,
    downloads: 45
  },
  {
    id: 3,
    judul: 'Indeks Pembangunan Manusia 2023',
    deskripsi: 'Perkembangan IPM Indonesia dan perbandingan antar provinsi',
    kategori: 'pembangunan',
    url_gambar: 'https://example.com/infografis/ipm-2023.jpg',
    tanggal_dibuat: '2023-12-20T09:15:00.000Z',
    tanggal_update: '2024-01-05T11:00:00.000Z',
    status: 'published',
    tags: ['ipm', 'pembangunan', 'kesejahteraan'],
    views: 920,
    downloads: 67
  }
];

// GET semua infografis dengan pagination dan filter
router.get('/', (req, res) => {
  try {
    const { page = 1, limit = 10, kategori, status, search } = req.query;
    let filteredInfografis = [...infografis];

    // Filter by kategori
    if (kategori) {
      filteredInfografis = filteredInfografis.filter(item => 
        item.kategori.toLowerCase() === kategori.toLowerCase()
      );
    }

    // Filter by status
    if (status) {
      filteredInfografis = filteredInfografis.filter(item => 
        item.status.toLowerCase() === status.toLowerCase()
      );
    }

    // Search by judul atau deskripsi
    if (search) {
      filteredInfografis = filteredInfografis.filter(item =>
        item.judul.toLowerCase().includes(search.toLowerCase()) ||
        item.deskripsi.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Pagination
    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const paginatedData = filteredInfografis.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: paginatedData,
      pagination: {
        current_page: parseInt(page),
        total_pages: Math.ceil(filteredInfografis.length / limit),
        total_items: filteredInfografis.length,
        items_per_page: parseInt(limit)
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data infografis',
      error: error.message
    });
  }
});

// GET infografis berdasarkan ID
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const item = infografis.find(inf => inf.id === parseInt(id));

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Infografis tidak ditemukan'
      });
    }

    // Increment views
    item.views += 1;

    res.json({
      success: true,
      data: item,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data infografis',
      error: error.message
    });
  }
});

// GET infografis populer (berdasarkan views)
router.get('/trending/popular', (req, res) => {
  try {
    const { limit = 5 } = req.query;
    const popular = [...infografis]
      .sort((a, b) => b.views - a.views)
      .slice(0, limit);

    res.json({
      success: true,
      data: popular,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil infografis populer',
      error: error.message
    });
  }
});

// GET infografis terbaru
router.get('/trending/latest', (req, res) => {
  try {
    const { limit = 5 } = req.query;
    const latest = [...infografis]
      .sort((a, b) => new Date(b.tanggal_dibuat) - new Date(a.tanggal_dibuat))
      .slice(0, limit);

    res.json({
      success: true,
      data: latest,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil infografis terbaru',
      error: error.message
    });
  }
});

// POST create infografis baru
router.post('/', (req, res) => {
  try {
    const { judul, deskripsi, kategori, url_gambar, tags } = req.body;

    if (!judul || !deskripsi || !kategori || !url_gambar) {
      return res.status(400).json({
        success: false,
        message: 'Field judul, deskripsi, kategori, dan url_gambar harus diisi'
      });
    }

    const newInfografis = {
      id: infografis.length + 1,
      judul,
      deskripsi,
      kategori,
      url_gambar,
      tanggal_dibuat: new Date().toISOString(),
      tanggal_update: new Date().toISOString(),
      status: 'draft',
      tags: tags || [],
      views: 0,
      downloads: 0
    };

    infografis.push(newInfografis);

    res.status(201).json({
      success: true,
      message: 'Infografis berhasil dibuat',
      data: newInfografis
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal membuat infografis',
      error: error.message
    });
  }
});

// PUT update infografis
router.put('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { judul, deskripsi, kategori, url_gambar, status, tags } = req.body;

    const index = infografis.findIndex(inf => inf.id === parseInt(id));

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Infografis tidak ditemukan'
      });
    }

    const updatedInfografis = {
      ...infografis[index],
      judul: judul || infografis[index].judul,
      deskripsi: deskripsi || infografis[index].deskripsi,
      kategori: kategori || infografis[index].kategori,
      url_gambar: url_gambar || infografis[index].url_gambar,
      status: status || infografis[index].status,
      tags: tags || infografis[index].tags,
      tanggal_update: new Date().toISOString()
    };

    infografis[index] = updatedInfografis;

    res.json({
      success: true,
      message: 'Infografis berhasil diupdate',
      data: updatedInfografis
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengupdate infografis',
      error: error.message
    });
  }
});

// DELETE infografis
router.delete('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const index = infografis.findIndex(inf => inf.id === parseInt(id));

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Infografis tidak ditemukan'
      });
    }

    const deletedInfografis = infografis.splice(index, 1)[0];

    res.json({
      success: true,
      message: 'Infografis berhasil dihapus',
      data: deletedInfografis
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal menghapus infografis',
      error: error.message
    });
  }
});

// POST increment download count
router.post('/:id/download', (req, res) => {
  try {
    const { id } = req.params;
    const item = infografis.find(inf => inf.id === parseInt(id));

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Infografis tidak ditemukan'
      });
    }

    item.downloads += 1;

    res.json({
      success: true,
      message: 'Download count berhasil diupdate',
      data: {
        id: item.id,
        judul: item.judul,
        downloads: item.downloads
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

module.exports = router;