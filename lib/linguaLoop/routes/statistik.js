const express = require('express');
const router = express.Router();

// GET /api/statistik - Root endpoint
router.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'API Statistik Indonesia - BPS',
    version: '1.0.0',
    endpoints: {
      terbaru: '/api/statistik/terbaru',
      trend: '/api/statistik/trend/:indicator',
      available_indicators: ['populasi', 'kemiskinan', 'kepadatan', 'pertumbuhan']
    }
  });
});

// GET /api/statistik/terbaru - Latest statistics
router.get('/terbaru', (req, res) => {
  try {
    const latestStats = {
      populasi: { value: 272.23, unit: 'Juta Jiwa', growth: 1.31, last_update: '2022-12-31' },
      kemiskinan: { value: 9.54, unit: 'Persen', growth: -5.9, last_update: '2022-09-15' },
      kepadatan: { value: 149, unit: 'per km²', growth: 1.28, last_update: '2022-12-31' },
      pertumbuhan_ekonomi: { value: 5.31, unit: 'Persen', growth: 2.1, last_update: '2022-12-31' }
    };
    res.json({ success: true, data: latestStats, timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/statistik/trend/:indicator - Trend data
router.get('/trend/:indicator', (req, res) => {
  try {
    const { indicator } = req.params;
    const { start_year, end_year, region } = req.query;
    
    const trendData = generateTrendData(indicator, start_year, end_year, region);
    
    res.json({
      success: true,
      data: {
        indicator,
        region: region || 'Indonesia',
        period: `${start_year || '2018'}-${end_year || '2022'}`,
        values: trendData
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Helper function to generate trend data
function generateTrendData(indicator, startYear = '2018', endYear = '2022', region = 'Indonesia') {
  const years = [];
  const start = parseInt(startYear);
  const end = parseInt(endYear);
  for (let year = start; year <= end; year++) years.push(year);

  const baseValues = {
    populasi: [264.16, 266.91, 267.66, 270.20, 272.23],
    kemiskinan: [9.82, 9.41, 10.19, 10.14, 9.54],
    kepadatan: [144, 146, 147, 148, 149],
    pertumbuhan: [5.17, 5.02, -2.07, 3.69, 5.31]
  };

  const values = baseValues[indicator] || [100, 105, 110, 115, 120];
  return years.map((year, index) => ({
    year,
    value: values[index] || values[values.length - 1],
    region
  }));
}

module.exports = router;