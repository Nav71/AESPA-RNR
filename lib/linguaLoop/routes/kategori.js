const express = require('express');
const router = express.Router();

// Mock data untuk kategori
let kategoriData = [
  {
    id: 1,
    nama: 'Ekonomi',
    slug: 'ekonomi',
    deskripsi: 'Data statistik ekonomi Indonesia termasuk PDB, inflasi, perdagangan',
    parent_id: null,
    icon: 'trend-up',
    warna: '#10B981',
    urutan: 1,
    status: 'active',
    jumlah_dataset: 45,
    jumlah_publikasi: 23,
    created_at: '2023-01-01T00:00:00.000Z',
    updated_at: '2024-01-15T10:30:00.000Z'
  },
  {
    id: 2,
    nama: 'Demografi',
    slug: 'demografi',
    deskripsi: 'Data kependudukan, sensus, dan statistik demografi Indonesia',
    parent_id: null,
    icon: 'users',
    warna: '#3B82F6',
    urutan: 2,
    status: 'active',
    jumlah_dataset: 32,
    jumlah_publikasi: 18,
    created_at: '2023-01-01T00:00:00.000Z',
    updated_at: '2024-01-12T14:20:00.000Z'
  },
  {
    id: 3,
    nama: 'Perdagangan Internasional',
    slug: 'perdagangan-internasional',
    deskripsi: 'Data ekspor, impor, dan neraca perdagangan Indonesia',
    parent_id: 1,
    icon: 'globe',
    warna: '#8B5CF6',
    urutan: 1,
    status: 'active',
    jumlah_dataset: 15,
    jumlah_publikasi: 8,
    created_at: '2023-02-01T00:00:00.000Z',
    updated_at: '2024-01-10T09:15:00.000Z'
  },
  {
    id: 4,
    nama: 'Pendidikan',
    slug: 'pendidikan',
    deskripsi: 'Statistik pendidikan, literasi, dan sumber daya manusia',
    parent_id: null,
    icon: 'graduation-cap',
    warna: '#F59E0B',
    urutan: 3,
    status: 'active',
    jumlah_dataset: 28,
    jumlah_publikasi: 15,
    created_at: '2023-01-01T00:00:00.000Z',
    updated_at: '2024-01-08T16:45:00.000Z'
  },
  {
    id: 5,
    nama: 'Kesehatan',
    slug: 'kesehatan',
    deskripsi: 'Data kesehatan masyarakat, fasilitas kesehatan, dan indikator kesehatan',
    parent_id: null,
    icon: 'heart',
    warna: '#EF4444',
    urutan: 4,
    status: 'active',
    jumlah_dataset: 22,
    jumlah_publikasi: 12,
    created_at: '2023-01-01T00:00:00.000Z',
    updated_at: '2024-01-05T11:20:00.000Z'
  },
  {
    id: 6,
    nama: 'Lingkungan',
    slug: 'lingkungan',
    deskripsi: 'Data lingkungan hidup, iklim, dan sumber daya alam',
    parent_id: null,
    icon: 'leaf',
    warna: '#059669',
    urutan: 5,
    status: 'active',
    jumlah_dataset: 19,
    jumlah_publikasi: 10,
    created_at: '2023-03-01T00:00:00.000Z',
    updated_at: '2023-12-20T08:30:00.000Z'
  },
  {
    id: 7,
    nama: 'Infrastruktur',
    slug: 'infrastruktur',
    deskripsi: 'Data pembangunan infrastruktur, transportasi, dan komunikasi',
    parent_id: null,
    icon: 'building',
    warna: '#6B7280',
    urutan: 6,
    status: 'draft',
    jumlah_dataset: 8,
    jumlah_publikasi: 4,
    created_at: '2023-06-01T00:00:00.000Z',
    updated_at: '2023-11-15T13:10:00.000Z'
  }
];

// GET semua kategori dengan filter dan pagination
router.get('/', (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      status, 
      parent_id, 
      search,
      include_children = 'true'
    } = req.query;

    let filteredKategori = [...kategoriData];

    // Filter by status
    if (status) {
      filteredKategori = filteredKategori.filter(kat => 
        kat.status.toLowerCase() === status.toLowerCase()
      );
    }

    // Filter by parent_id
    if (parent_id !== undefined) {
      if (parent_id === 'null' || parent_id === '') {
        filteredKategori = filteredKategori.filter(kat => kat.parent_id === null);
      } else {
        filteredKategori = filteredKategori.filter(kat => 
          kat.parent_id === parseInt(parent_id)
        );
      }
    }

    // Search by nama atau deskripsi
    if (search) {
      filteredKategori = filteredKategori.filter(kat =>
        kat.nama.toLowerCase().includes(search.toLowerCase()) ||
        kat.deskripsi.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Sort by urutan
    filteredKategori.sort((a, b) => a.urutan - b.urutan);

    // Include children if requested
    if (include_children === 'true') {
      filteredKategori = filteredKategori.map(kategori => ({
        ...kategori,
        children: kategoriData.filter(child => child.parent_id === kategori.id)
      }));
    }

    // Pagination
    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const paginatedData = filteredKategori.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: paginatedData,
      pagination: {
        current_page: parseInt(page),
        total_pages: Math.ceil(filteredKategori.length / limit),
        total_items: filteredKategori.length,
        items_per_page: parseInt(limit)
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data kategori',
      error: error.message
    });
  }
});

// GET kategori berdasarkan ID
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { include_children = 'true' } = req.query;

    const kategori = kategoriData.find(kat => kat.id === parseInt(id));

    if (!kategori) {
      return res.status(404).json({
        success: false,
        message: 'Kategori tidak ditemukan'
      });
    }

    let result = { ...kategori };

    // Include children if requested
    if (include_children === 'true') {
      result.children = kategoriData.filter(child => child.parent_id === kategori.id);
    }

    // Include parent if exists
    if (kategori.parent_id) {
      result.parent = kategoriData.find(parent => parent.id === kategori.parent_id);
    }

    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data kategori',
      error: error.message
    });
  }
});

// GET kategori berdasarkan slug
router.get('/slug/:slug', (req, res) => {
  try {
    const { slug } = req.params;
    const { include_children = 'true' } = req.query;

    const kategori = kategoriData.find(kat => kat.slug === slug);

    if (!kategori) {
      return res.status(404).json({
        success: false,
        message: 'Kategori tidak ditemukan'
      });
    }

    let result = { ...kategori };

    // Include children if requested
    if (include_children === 'true') {
      result.children = kategoriData.filter(child => child.parent_id === kategori.id);
    }

    // Include parent if exists
    if (kategori.parent_id) {
      result.parent = kategoriData.find(parent => parent.id === kategori.parent_id);
    }

    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data kategori',
      error: error.message
    });
  }
});

// GET kategori tree (hierarki)
router.get('/tree/hierarchy', (req, res) => {
  try {
    const { status = 'active' } = req.query;

    // Filter by status
    let filteredKategori = kategoriData;
    if (status !== 'all') {
      filteredKategori = kategoriData.filter(kat => kat.status === status);
    }

    // Build tree structure
    const buildTree = (parentId = null) => {
      return filteredKategori
        .filter(kat => kat.parent_id === parentId)
        .sort((a, b) => a.urutan - b.urutan)
        .map(kategori => ({
          ...kategori,
          children: buildTree(kategori.id)
        }));
    };

    const tree = buildTree();

    res.json({
      success: true,
      data: tree,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil hierarki kategori',
      error: error.message
    });
  }
});

// GET statistik kategori
router.get('/stats/overview', (req, res) => {
  try {
    const stats = {
      total_kategori: kategoriData.length,
      kategori_aktif: kategoriData.filter(kat => kat.status === 'active').length,
      kategori_draft: kategoriData.filter(kat => kat.status === 'draft').length,
      kategori_utama: kategoriData.filter(kat => kat.parent_id === null).length,
      subkategori: kategoriData.filter(kat => kat.parent_id !== null).length,
      total_dataset: kategoriData.reduce((sum, kat) => sum + kat.jumlah_dataset, 0),
      total_publikasi: kategoriData.reduce((sum, kat) => sum + kat.jumlah_publikasi, 0),
      kategori_terpopuler: kategoriData
        .sort((a, b) => b.jumlah_dataset - a.jumlah_dataset)
        .slice(0, 5)
        .map(kat => ({
          id: kat.id,
          nama: kat.nama,
          jumlah_dataset: kat.jumlah_dataset
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
      message: 'Gagal mengambil statistik kategori',
      error: error.message
    });
  }
});

// POST create kategori baru
router.post('/', (req, res) => {
  try {
    const { 
      nama, 
      slug, 
      deskripsi, 
      parent_id = null, 
      icon = 'folder', 
      warna = '#6B7280',
      urutan,
      status = 'draft'
    } = req.body;

    if (!nama || !slug || !deskripsi) {
      return res.status(400).json({
        success: false,
        message: 'Field nama, slug, dan deskripsi harus diisi'
      });
    }

    // Check if slug already exists
    const existingKategori = kategoriData.find(kat => kat.slug === slug);
    if (existingKategori) {
      return res.status(400).json({
        success: false,
        message: 'Slug sudah digunakan'
      });
    }

    // Validate parent_id if provided
    if (parent_id && !kategoriData.find(kat => kat.id === parseInt(parent_id))) {
      return res.status(400).json({
        success: false,
        message: 'Parent kategori tidak ditemukan'
      });
    }

    // Generate urutan if not provided
    let finalUrutan = urutan;
    if (!finalUrutan) {
      const siblings = kategoriData.filter(kat => kat.parent_id === parent_id);
      finalUrutan = siblings.length > 0 ? Math.max(...siblings.map(s => s.urutan)) + 1 : 1;
    }

    const newKategori = {
      id: Math.max(...kategoriData.map(kat => kat.id)) + 1,
      nama,
      slug,
      deskripsi,
      parent_id: parent_id ? parseInt(parent_id) : null,
      icon,
      warna,
      urutan: finalUrutan,
      status,
      jumlah_dataset: 0,
      jumlah_publikasi: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    kategoriData.push(newKategori);

    res.status(201).json({
      success: true,
      message: 'Kategori berhasil dibuat',
      data: newKategori
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal membuat kategori',
      error: error.message
    });
  }
});

// PUT update kategori
router.put('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { 
      nama, 
      slug, 
      deskripsi, 
      parent_id, 
      icon, 
      warna,
      urutan,
      status
    } = req.body;

    const index = kategoriData.findIndex(kat => kat.id === parseInt(id));

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Kategori tidak ditemukan'
      });
    }

    // Check if slug already exists (excluding current item)
    if (slug && slug !== kategoriData[index].slug) {
      const existingKategori = kategoriData.find(kat => kat.slug === slug);
      if (existingKategori) {
        return res.status(400).json({
          success: false,
          message: 'Slug sudah digunakan'
        });
      }
    }

    // Validate parent_id if provided and different
    if (parent_id !== undefined && parent_id !== kategoriData[index].parent_id) {
      if (parent_id && !kategoriData.find(kat => kat.id === parseInt(parent_id))) {
        return res.status(400).json({
          success: false,
          message: 'Parent kategori tidak ditemukan'
        });
      }
      
      // Prevent circular reference
      if (parent_id === parseInt(id)) {
        return res.status(400).json({
          success: false,
          message: 'Kategori tidak dapat menjadi parent dari dirinya sendiri'
        });
      }
    }

    const updatedKategori = {
      ...kategoriData[index],
      nama: nama || kategoriData[index].nama,
      slug: slug || kategoriData[index].slug,
      deskripsi: deskripsi || kategoriData[index].deskripsi,
      parent_id: parent_id !== undefined ? (parent_id ? parseInt(parent_id) : null) : kategoriData[index].parent_id,
      icon: icon || kategoriData[index].icon,
      warna: warna || kategoriData[index].warna,
      urutan: urutan !== undefined ? urutan : kategoriData[index].urutan,
      status: status || kategoriData[index].status,
      updated_at: new Date().toISOString()
    };

    kategoriData[index] = updatedKategori;

    res.json({
      success: true,
      message: 'Kategori berhasil diupdate',
      data: updatedKategori
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengupdate kategori',
      error: error.message
    });
  }
});

// DELETE kategori
router.delete('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { force = false } = req.query;

    const index = kategoriData.findIndex(kat => kat.id === parseInt(id));

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'Kategori tidak ditemukan'
      });
    }

    const kategori = kategoriData[index];

    // Check if kategori has children
    const hasChildren = kategoriData.some(kat => kat.parent_id === parseInt(id));
    if (hasChildren && !force) {
      return res.status(400).json({
        success: false,
        message: 'Kategori memiliki subkategori. Gunakan parameter force=true untuk menghapus paksa',
        children_count: kategoriData.filter(kat => kat.parent_id === parseInt(id)).length
      });
    }

    // Check if kategori has data
    if ((kategori.jumlah_dataset > 0 || kategori.jumlah_publikasi > 0) && !force) {
      return res.status(400).json({
        success: false,
        message: 'Kategori memiliki data terkait. Gunakan parameter force=true untuk menghapus paksa',
        dataset_count: kategori.jumlah_dataset,
        publikasi_count: kategori.jumlah_publikasi
      });
    }

    // If force delete, also delete children
    if (force && hasChildren) {
      kategoriData = kategoriData.filter(kat => kat.parent_id !== parseInt(id));
    }

    // Delete the kategori
    const deletedKategori = kategoriData.splice(index, 1)[0];

    res.json({
      success: true,
      message: 'Kategori berhasil dihapus',
      data: deletedKategori
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal menghapus kategori',
      error: error.message
    });
  }
});

// PUT reorder kategori
router.put('/reorder/batch', (req, res) => {
  try {
    const { reorder_data } = req.body;

    if (!reorder_data || !Array.isArray(reorder_data)) {
      return res.status(400).json({
        success: false,
        message: 'Data reorder harus berupa array dengan format [{ id, urutan }]'
      });
    }

    // Update urutan for each kategori
    reorder_data.forEach(item => {
      const index = kategoriData.findIndex(kat => kat.id === parseInt(item.id));
      if (index !== -1) {
        kategoriData[index].urutan = item.urutan;
        kategoriData[index].updated_at = new Date().toISOString();
      }
    });

    res.json({
      success: true,
      message: 'Urutan kategori berhasil diupdate',
      updated_count: reorder_data.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengupdate urutan kategori',
      error: error.message
    });
  }
});

module.exports = router;