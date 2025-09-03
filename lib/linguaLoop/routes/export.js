const express = require('express');
const router = express.Router();

// Mock data untuk demo export
const sampleData = {
  ekonomi: [
    { tahun: 2020, pdb: 15434.2, inflasi: 1.68, pengangguran: 7.07 },
    { tahun: 2021, pdb: 15834.1, inflasi: 1.56, pengangguran: 6.49 },
    { tahun: 2022, pdb: 16555.4, inflasi: 4.21, pengangguran: 5.86 },
    { tahun: 2023, pdb: 17384.9, inflasi: 3.61, pengangguran: 5.32 }
  ],
  demografi: [
    { provinsi: 'DKI Jakarta', populasi: 10562088, kepadatan: 15900 },
    { provinsi: 'Jawa Barat', populasi: 48037438, kepadatan: 1364 },
    { provinsi: 'Jawa Tengah', populasi: 34718204, kepadatan: 1067 },
    { provinsi: 'Jawa Timur', populasi: 40665696, kepadatan: 849 }
  ]
};

// Helper function untuk generate CSV
function generateCSV(data, headers) {
  if (!data || data.length === 0) {
    return 'No data available';
  }

  const csvHeaders = headers || Object.keys(data[0]);
  let csv = csvHeaders.join(',') + '\n';

  data.forEach(row => {
    const values = csvHeaders.map(header => {
      const value = row[header];
      // Handle values with commas by wrapping in quotes
      return typeof value === 'string' && value.includes(',') ? `"${value}"` : value;
    });
    csv += values.join(',') + '\n';
  });

  return csv;
}

// Helper function untuk generate JSON
function generateJSON(data) {
  return JSON.stringify({
    metadata: {
      exported_at: new Date().toISOString(),
      total_records: data.length,
      source: 'Statistik Indonesia API'
    },
    data: data
  }, null, 2);
}

// Helper function untuk generate XML
function generateXML(data, rootElement = 'data') {
  let xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
  xml += `<${rootElement}>\n`;
  xml += `  <metadata>\n`;
  xml += `    <exported_at>${new Date().toISOString()}</exported_at>\n`;
  xml += `    <total_records>${data.length}</total_records>\n`;
  xml += `    <source>Statistik Indonesia API</source>\n`;
  xml += `  </metadata>\n`;
  xml += `  <records>\n`;

  data.forEach((item, index) => {
    xml += `    <record id="${index + 1}">\n`;
    Object.keys(item).forEach(key => {
      xml += `      <${key}>${item[key]}</${key}>\n`;
    });
    xml += `    </record>\n`;
  });

  xml += `  </records>\n`;
  xml += `</${rootElement}>`;
  return xml;
}

// GET - List available export options
router.get('/', (req, res) => {
  try {
    const exportOptions = {
      available_datasets: [
        {
          id: 'ekonomi',
          name: 'Data Ekonomi',
          description: 'Data PDB, inflasi, dan pengangguran',
          fields: ['tahun', 'pdb', 'inflasi', 'pengangguran']
        },
        {
          id: 'demografi',
          name: 'Data Demografi',
          description: 'Data populasi dan kepadatan penduduk per provinsi',
          fields: ['provinsi', 'populasi', 'kepadatan']
        }
      ],
      supported_formats: ['csv', 'json', 'xml'],
      max_records: 10000,
      rate_limit: '10 requests per minute'
    };

    res.json({
      success: true,
      data: exportOptions,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil opsi export',
      error: error.message
    });
  }
});

// GET - Export data dalam format CSV
router.get('/csv/:dataset', (req, res) => {
  try {
    const { dataset } = req.params;
    const { fields } = req.query;

    if (!sampleData[dataset]) {
      return res.status(404).json({
        success: false,
        message: `Dataset '${dataset}' tidak ditemukan`
      });
    }

    const data = sampleData[dataset];
    const selectedFields = fields ? fields.split(',') : null;
    const csv = generateCSV(data, selectedFields);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="${dataset}_data.csv"`);
    res.send(csv);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengexport data CSV',
      error: error.message
    });
  }
});

// GET - Export data dalam format JSON
router.get('/json/:dataset', (req, res) => {
  try {
    const { dataset } = req.params;
    const { fields, pretty } = req.query;

    if (!sampleData[dataset]) {
      return res.status(404).json({
        success: false,
        message: `Dataset '${dataset}' tidak ditemukan`
      });
    }

    let data = sampleData[dataset];

    // Filter fields jika diminta
    if (fields) {
      const selectedFields = fields.split(',');
      data = data.map(item => {
        const filteredItem = {};
        selectedFields.forEach(field => {
          if (item.hasOwnProperty(field)) {
            filteredItem[field] = item[field];
          }
        });
        return filteredItem;
      });
    }

    const jsonData = generateJSON(data);

    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="${dataset}_data.json"`);
    
    if (pretty === 'false') {
      res.json(JSON.parse(jsonData));
    } else {
      res.send(jsonData);
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengexport data JSON',
      error: error.message
    });
  }
});

// GET - Export data dalam format XML
router.get('/xml/:dataset', (req, res) => {
  try {
    const { dataset } = req.params;
    const { fields } = req.query;

    if (!sampleData[dataset]) {
      return res.status(404).json({
        success: false,
        message: `Dataset '${dataset}' tidak ditemukan`
      });
    }

    let data = sampleData[dataset];

    // Filter fields jika diminta
    if (fields) {
      const selectedFields = fields.split(',');
      data = data.map(item => {
        const filteredItem = {};
        selectedFields.forEach(field => {
          if (item.hasOwnProperty(field)) {
            filteredItem[field] = item[field];
          }
        });
        return filteredItem;
      });
    }

    const xml = generateXML(data, dataset);

    res.setHeader('Content-Type', 'application/xml');
    res.setHeader('Content-Disposition', `attachment; filename="${dataset}_data.xml"`);
    res.send(xml);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengexport data XML',
      error: error.message
    });
  }
});

// POST - Custom export with filters
router.post('/custom', (req, res) => {
  try {
    const { 
      dataset, 
      format = 'json', 
      fields, 
      filters = {},
      filename 
    } = req.body;

    if (!dataset) {
      return res.status(400).json({
        success: false,
        message: 'Parameter dataset harus diisi'
      });
    }

    if (!sampleData[dataset]) {
      return res.status(404).json({
        success: false,
        message: `Dataset '${dataset}' tidak ditemukan`
      });
    }

    let data = [...sampleData[dataset]];

    // Apply filters
    Object.keys(filters).forEach(key => {
      if (filters[key] !== undefined && filters[key] !== null) {
        data = data.filter(item => {
          if (typeof filters[key] === 'object') {
            // Range filter
            if (filters[key].min !== undefined) {
              return item[key] >= filters[key].min;
            }
            if (filters[key].max !== undefined) {
              return item[key] <= filters[key].max;
            }
          } else {
            // Exact match
            return item[key] === filters[key];
          }
          return true;
        });
      }
    });

    // Filter fields
    if (fields && Array.isArray(fields)) {
      data = data.map(item => {
        const filteredItem = {};
        fields.forEach(field => {
          if (item.hasOwnProperty(field)) {
            filteredItem[field] = item[field];
          }
        });
        return filteredItem;
      });
    }

    const exportFilename = filename || `${dataset}_custom_export`;

    // Generate response based on format
    switch (format.toLowerCase()) {
      case 'csv':
        const csv = generateCSV(data, fields);
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="${exportFilename}.csv"`);
        res.send(csv);
        break;
      
      case 'xml':
        const xml = generateXML(data, dataset);
        res.setHeader('Content-Type', 'application/xml');
        res.setHeader('Content-Disposition', `attachment; filename="${exportFilename}.xml"`);
        res.send(xml);
        break;
      
      case 'json':
      default:
        const jsonData = generateJSON(data);
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', `attachment; filename="${exportFilename}.json"`);
        res.send(jsonData);
        break;
    }

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal melakukan custom export',
      error: error.message
    });
  }
});

// GET - Download log/history export
router.get('/history', (req, res) => {
  try {
    // Mock export history
    const exportHistory = [
      {
        id: 1,
        dataset: 'ekonomi',
        format: 'csv',
        exported_at: '2024-01-15T10:30:00.000Z',
        file_size: '2.5 KB',
        status: 'completed'
      },
      {
        id: 2,
        dataset: 'demografi',
        format: 'json',
        exported_at: '2024-01-14T15:20:00.000Z',
        file_size: '3.1 KB',
        status: 'completed'
      },
      {
        id: 3,
        dataset: 'ekonomi',
        format: 'xml',
        exported_at: '2024-01-13T09:45:00.000Z',
        file_size: '4.8 KB',
        status: 'completed'
      }
    ];

    res.json({
      success: true,
      data: exportHistory,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil history export',
      error: error.message
    });
  }
});

module.exports = router;