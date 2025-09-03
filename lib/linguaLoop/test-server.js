const express = require('express');
const app = express();
const PORT = 3000;

// Middleware dasar
app.use(express.json());

// Route kesehatan sederhana
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Server berjalan!',
    timestamp: new Date().toISOString()
  });
});

// Route statistik sederhana
app.get('/api/statistik/terbaru', (req, res) => {
  res.json({
    success: true,
    data: {
      populasi: { value: 272.23, unit: 'Juta Jiwa', growth: 1.31 },
      kemiskinan: { value: 9.54, unit: 'Persen', growth: -5.9 },
      kepadatan: { value: 149, unit: 'per km²', growth: 1.28 },
      pertumbuhan_ekonomi: { value: 5.31, unit: 'Persen', growth: 2.1 }
    }
  });
});

// Jalankan server di semua network interface
app.listen(PORT, '0.0.0.0', () => {
  console.log('===================================');
  console.log('🚀 SERVER BERJALAN SUKSES!');
  console.log('📍 Local:    http://localhost:' + PORT);
  console.log('🌐 Network:  http://192.168.1.77:' + PORT);
  console.log('💡 Test:     curl http://192.168.1.77:' + PORT + '/health');
  console.log('===================================');
});