const express = require('express');
const router = express.Router();

// Get provinces
router.get('/provinsi', async (req, res) => {
  const provinces = [
    { id: 'jawa-barat', name: 'Jawa Barat', code: '32', capital: 'Bandung' },
    { id: 'jawa-tengah', name: 'Jawa Tengah', code: '33', capital: 'Semarang' },
    { id: 'jawa-timur', name: 'Jawa Timur', code: '35', capital: 'Surabaya' }
  ];
  res.json({ success: true, data: provinces, total: provinces.length });
});

// Get districts by province
router.get('/kabupaten', async (req, res) => {
  const { provinsi } = req.query;
  const districts = {
    'jawa-barat': [ { id: 'bandung', name: 'Kabupaten Bandung', type: 'kabupaten' }, { id: 'bogor', name: 'Kabupaten Bogor', type: 'kabupaten' } ],
    'jawa-tengah': [ { id: 'semarang', name: 'Kabupaten Semarang', type: 'kabupaten' } ]
  };
  const result = districts[provinsi] || [];
  res.json({ success: true, data: result, provinsi, total: result.length });
});

module.exports = router;
