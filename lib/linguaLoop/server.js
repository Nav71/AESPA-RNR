const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Sample data (replace with your actual database)
const sampleData = {
  'jumlah-penduduk': {
    data: [
      { tahun: 2020, provinsi: 'DKI Jakarta', nilai: 10770487 },
      { tahun: 2020, provinsi: 'Jawa Barat', nilai: 49578431 },
      { tahun: 2020, provinsi: 'Jawa Tengah', nilai: 36516027 },
      { tahun: 2021, provinsi: 'DKI Jakarta', nilai: 10840758 },
      { tahun: 2021, provinsi: 'Jawa Barat', nilai: 49974536 },
      { tahun: 2021, provinsi: 'Jawa Tengah', nilai: 36648649 }
    ]
  },
  'kepadatan-penduduk': {
    data: [
      { tahun: 2020, provinsi: 'DKI Jakarta', nilai: 149 },
      { tahun: 2020, provinsi: 'Jawa Barat', nilai: 145 },
      { tahun: 2020, provinsi: 'Jawa Tengah', nilai: 108 },
      { tahun: 2021, provinsi: 'DKI Jakarta', nilai: 151 },
      { tahun: 2021, provinsi: 'Jawa Barat', nilai: 147 },
      { tahun: 2021, provinsi: 'Jawa Tengah', nilai: 109 }
    ]
  },
  'penduduk-miskin': {
    data: [
      { tahun: 2020, provinsi: 'DKI Jakarta', nilai: 5.31 },
      { tahun: 2020, provinsi: 'Jawa Barat', nilai: 8.43 },
      { tahun: 2020, provinsi: 'Jawa Tengah', nilai: 11.12 },
      { tahun: 2021, provinsi: 'DKI Jakarta', nilai: 5.14 },
      { tahun: 2021, provinsi: 'Jawa Barat', nilai: 8.21 },
      { tahun: 2021, provinsi: 'Jawa Tengah', nilai: 10.89 }
    ]
  }
};

const publications = [
  { id: 1, title: 'Statistik Penduduk Indonesia 2021', category: 'Demografi', year: 2021 },
  { id: 2, title: 'Laporan Kemiskinan 2022', category: 'Ekonomi', year: 2022 },
  { id: 3, title: 'Data Pendidikan Nasional', category: 'Pendidikan', year: 2021 }
];

const provinces = [
  { id: '11', name: 'Aceh' },
  { id: '12', name: 'Sumatera Utara' },
  { id: '13', name: 'Sumatera Barat' },
  { id: '31', name: 'DKI Jakarta' },
  { id: '32', name: 'Jawa Barat' },
  { id: '33', name: 'Jawa Tengah' }
];

// Enhanced CORS configuration
app.use(cors({
  origin: ['http://localhost', 'http://10.0.2.2:3000', 'http://192.168.1.77:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true
}));

app.use(helmet());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// ===== ROUTES =====

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Selamat datang di Statistik Indonesia API',
    version: '1.0',
    description: 'API untuk mengakses data statistik resmi Indonesia',
    endpoints: {
      health: '/health',
      statistik: '/api/statistik',
      publikasi: '/api/publikasi',
      kategori: '/api/kategori',
      data: '/api/data',
      wilayah: '/api/wilayah',
      export: '/api/export',
      infografis: '/api/infografis'
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// ===== STATISTIK ROUTES =====
app.get('/api/statistik/terbaru', (req, res) => {
  try {
    const latestData = {};
    Object.keys(sampleData).forEach(key => {
      latestData[key] = sampleData[key].data.slice(-3); // Get last 3 entries
    });

    res.json({
      status: 'success',
      data: latestData,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch latest statistics' });
  }
});

app.get('/api/statistik', (req, res) => {
  const { kategori } = req.query;
  
  if (kategori && sampleData[kategori]) {
    res.json({
      status: 'success',
      data: sampleData[kategori],
      total: sampleData[kategori].data.length
    });
  } else {
    res.json({
      status: 'success',
      data: sampleData,
      total: Object.keys(sampleData).length
    });
  }
});

// ===== PUBLIKASI ROUTES =====
app.get('/api/publikasi/recent', (req, res) => {
  try {
    const recentPubs = publications.slice(0, 5); // Get first 5 publications
    res.json({
      status: 'success',
      data: recentPubs,
      total: recentPubs.length
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch recent publications' });
  }
});

app.get('/api/publikasi', (req, res) => {
  const { page = 1, limit = 10 } = req.query;
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;

  const result = publications.slice(startIndex, endIndex);
  
  res.json({
    status: 'success',
    data: result,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: publications.length,
      pages: Math.ceil(publications.length / limit)
    }
  });
});

app.get('/api/publikasi/kategori', (req, res) => {
  try {
    const categories = [...new Set(publications.map(pub => pub.category))];
    res.json({
      status: 'success',
      data: categories
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch publication categories' });
  }
});

// ===== DATA ROUTES =====
app.get('/api/data/:dataId', (req, res) => {
  const { dataId } = req.params;
  const { tahun, provinsi } = req.query;

  if (!sampleData[dataId]) {
    return res.status(404).json({ error: 'Data not found' });
  }

  let filteredData = sampleData[dataId].data;

  if (tahun) {
    filteredData = filteredData.filter(item => item.tahun == tahun);
  }

  if (provinsi) {
    filteredData = filteredData.filter(item => 
      item.provinsi.toLowerCase().includes(provinsi.toLowerCase())
    );
  }

  res.json({
    status: 'success',
    data: filteredData,
    total: filteredData.length
  });
});

app.get('/api/data/search', (req, res) => {
  const { query } = req.query;
  
  if (!query) {
    return res.status(400).json({ error: 'Query parameter required' });
  }

  const results = [];
  Object.keys(sampleData).forEach(key => {
    sampleData[key].data.forEach(item => {
      if (item.provinsi.toLowerCase().includes(query.toLowerCase())) {
        results.push({ ...item, dataset: key });
      }
    });
  });

  res.json({
    status: 'success',
    data: results,
    total: results.length
  });
});

app.get('/api/data/:dataId/tahun', (req, res) => {
  const { dataId } = req.params;

  if (!sampleData[dataId]) {
    return res.status(404).json({ error: 'Data not found' });
  }

  const years = [...new Set(sampleData[dataId].data.map(item => item.tahun))];
  
  res.json({
    status: 'success',
    data: years.sort()
  });
});

// ===== WILAYAH ROUTES =====
app.get('/api/wilayah/provinsi', (req, res) => {
  res.json({
    status: 'success',
    data: provinces,
    total: provinces.length
  });
});

app.get('/api/wilayah/kabupaten', (req, res) => {
  const { provinsi } = req.query;
  
  if (!provinsi) {
    return res.status(400).json({ error: 'Provinsi parameter required' });
  }

  // Mock districts data
  const districts = {
    '31': [ // DKI Jakarta
      { id: '3171', name: 'Jakarta Selatan' },
      { id: '3172', name: 'Jakarta Timur' },
      { id: '3173', name: 'Jakarta Pusat' }
    ],
    '32': [ // Jawa Barat
      { id: '3201', name: 'Bogor' },
      { id: '3202', name: 'Sukabumi' },
      { id: '3203', name: 'Cianjur' }
    ]
  };

  const result = districts[provinsi] || [];
  
  res.json({
    status: 'success',
    data: result,
    total: result.length
  });
});

// ===== INFOGRAFIS ROUTES =====
app.get('/api/infografis', (req, res) => {
  const infographics = [
    { id: 1, title: 'Pertumbuhan Penduduk 2022', imageUrl: '/images/info1.png' },
    { id: 2, title: 'Tingkat Kemiskinan Nasional', imageUrl: '/images/info2.png' },
    { id: 3, title: 'Distribusi Pendidikan', imageUrl: '/images/info3.png' }
  ];

  res.json({
    status: 'success',
    data: infographics,
    total: infographics.length
  });
});

// ===== KATEGORI ROUTES =====
app.get('/api/kategori', (req, res) => {
  const { type } = req.query;
  const categories = {
    demografi: ['Penduduk', 'Kepadatan', 'Migrasi'],
    ekonomi: ['Kemiskinan', 'PDRB', 'Inflasi'],
    sosial: ['Pendidikan', 'Kesehatan', 'Ketenagakerjaan']
  };

  if (type && categories[type]) {
    res.json({
      status: 'success',
      data: categories[type]
    });
  } else {
    res.json({
      status: 'success',
      data: categories
    });
  }
});

// ===== EXPORT ROUTES =====
app.get('/api/export/:dataId', (req, res) => {
  const { dataId } = req.params;
  const { format = 'json' } = req.query;

  if (!sampleData[dataId]) {
    return res.status(404).json({ error: 'Data not found for export' });
  }

  res.json({
    status: 'success',
    data: {
      download_url: `http://localhost:3000/api/export/${dataId}/download.${format}`,
      format: format,
      expires_at: new Date(Date.now() + 3600000).toISOString() // 1 hour
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `Route ${req.originalUrl} not found`
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Statistik Indonesia API v1.0`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📍 Local: http://localhost:${PORT}`);
  console.log(`📱 Android Emulator: http://10.0.2.2:${PORT}`);
});