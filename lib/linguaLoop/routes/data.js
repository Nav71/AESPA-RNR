const express = require('express');
const router = express.Router();

// Search data
router.get('/search', async (req, res) => {
  const { query, category, limit = 20 } = req.query;
  const allData = [
    { id: 'jumlah-penduduk', title: 'Jumlah Penduduk', category: 'kependudukan', description: 'Data jumlah penduduk Indonesia berdasarkan proyeksi', keywords: ['penduduk', 'populasi'] },
    { id: 'penduduk-miskin', title: 'Penduduk Miskin', category: 'kependudukan', description: 'Persentase penduduk miskin terhadap total penduduk', keywords: ['miskin', 'kemiskinan'] },
    { id: 'kepadatan-penduduk', title: 'Kepadatan Penduduk', category: 'kependudukan', description: 'Kepadatan penduduk per km²', keywords: ['kepadatan', 'penduduk'] },
    { id: 'pdrb', title: 'PDRB', category: 'ekonomi', description: 'Nilai produksi barang dan jasa', keywords: ['pdrb', 'ekonomi'] }
  ];

  let results = allData;
  if (query) results = results.filter(item => item.title.toLowerCase().includes(query.toLowerCase()) || item.description.toLowerCase().includes(query.toLowerCase()) || item.keywords.some(k => k.toLowerCase().includes(query.toLowerCase())));
  if (category) results = results.filter(item => item.category === category.toLowerCase());
  results = results.slice(0, parseInt(limit));

  res.json({ success: true, data: results, total: results.length, query: query || '', category: category || 'all' });
});

// Get data detail
router.get('/:dataId', async (req, res) => {
  const { dataId } = req.params;
  const { tahun, provinsi } = req.query;
  const dataDetail = generateDataDetail(dataId, tahun, provinsi);
  res.json({ success: true, data: dataDetail, filters: { tahun: tahun || 'all', provinsi: provinsi || 'all' } });
});

// Get available years
router.get('/:dataId/tahun', async (req, res) => {
  const { dataId } = req.params;
  res.json({ success: true, data: [2018, 2019, 2020, 2021, 2022], dataId });
});

function generateDataDetail(dataId, tahun, provinsi) {
  const baseData = {
    'jumlah-penduduk': { title: 'Jumlah Penduduk', unit: 'Juta Jiwa', chart_data: [ { year: '2018', value: 264.16, region: provinsi || 'Indonesia' }, { year: '2019', value: 266.91, region: provinsi || 'Indonesia' }, { year: '2020', value: 267.66, region: provinsi || 'Indonesia' }, { year: '2021', value: 270.20, region: provinsi || 'Indonesia' }, { year: '2022', value: 272.23, region: provinsi || 'Indonesia' } ], current_value: 272.23, growth_rate: 1.31 },
    'penduduk-miskin': { title: 'Penduduk Miskin', unit: 'Persen', chart_data: [ { year: '2018', value: 9.82, region: provinsi || 'Indonesia' }, { year: '2019', value: 9.41, region: provinsi || 'Indonesia' }, { year: '2020', value: 10.19, region: provinsi || 'Indonesia' }, { year: '2021', value: 10.14, region: provinsi || 'Indonesia' }, { year: '2022', value: 9.54, region: provinsi || 'Indonesia' } ], current_value: 9.54, growth_rate: -5.9 }
  };

  const data = baseData[dataId] || { title: dataId.replace('-', ' '), unit: 'Unit', chart_data: [ { year: '2018', value: 100, region: provinsi || 'Indonesia' }, { year: '2019', value: 105, region: provinsi || 'Indonesia' }, { year: '2020', value: 110, region: provinsi || 'Indonesia' }, { year: '2021', value: 115, region: provinsi || 'Indonesia' }, { year: '2022', value: 120, region: provinsi || 'Indonesia' } ], current_value: 120, growth_rate: 4.35 };
  if (tahun) data.chart_data = data.chart_data.filter(item => item.year === tahun);
  data.last_update = new Date().toISOString();
  data.filters_applied = { tahun, provinsi };
  return data;
}

module.exports = router;
