import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IpmScreen extends StatefulWidget {
  const IpmScreen({super.key});

  @override
  _IpmScreenState createState() => _IpmScreenState();
}

class _IpmScreenState extends State<IpmScreen> {
  int selectedYear = 2024;

  // Data untuk setiap tahun
  final Map<int, Map<String, dynamic>> yearlyData = {
    2020: {
      'ipm': 85.22,
      'ipmPerempuan': 81.38,
      'ipg': 95.49,
      'usia_harapan_hidup': 'Data tidak tersedia',
      'harapan_lama_sekolah_laki': 15.72,
      'harapan_lama_sekolah_perempuan': 15.23,
      'rata_lama_sekolah_laki': 11.42,
      'rata_lama_sekolah_perempuan': 10.16,
      'pengeluaran_laki': 16.128,
      'pengeluaran_perempuan': 14.287,
    },
    2021: {
      'ipm': 85.63,
      'ipmPerempuan': 81.92,
      'ipg': 95.67,
      'usia_harapan_hidup': 'Data tidak tersedia',
      'harapan_lama_sekolah_laki': 15.73,
      'harapan_lama_sekolah_perempuan': 15.24,
      'rata_lama_sekolah_laki': 11.51,
      'rata_lama_sekolah_perempuan': 10.44,
      'pengeluaran_laki': 16.436,
      'pengeluaran_perempuan': 14.442,
    },
    2022: {
      'ipm': 86.15,
      'ipmPerempuan': 82.64,
      'ipg': 95.93,
      'usia_harapan_hidup': 'Data tidak tersedia',
      'harapan_lama_sekolah_laki': 15.74,
      'harapan_lama_sekolah_perempuan': 15.53,
      'rata_lama_sekolah_laki': 11.53,
      'rata_lama_sekolah_perempuan': 10.46,
      'pengeluaran_laki': 17.115,
      'pengeluaran_perempuan': 14.908,
    },
    2023: {
      'ipm': 86.48,
      'ipmPerempuan': 82.99,
      'ipg': 95.96,
      'usia_harapan_hidup': 'Data tidak tersedia',
      'harapan_lama_sekolah_laki': 15.76,
      'harapan_lama_sekolah_perempuan': 15.54,
      'rata_lama_sekolah_laki': 11.54,
      'rata_lama_sekolah_perempuan': 10.47,
      'pengeluaran_laki': 17.549,
      'pengeluaran_perempuan': 15.238,
    },
    2024: {
      'ipm': 87.03,
      'ipmPerempuan': 83.87,
      'ipg': 96.37,
      'usia_harapan_hidup': 'Data tidak tersedia',
      'harapan_lama_sekolah_laki': 15.78,
      'harapan_lama_sekolah_perempuan': 15.56,
      'rata_lama_sekolah_laki': 11.55,
      'rata_lama_sekolah_perempuan': 10.76,
      'pengeluaran_laki': 18.175,
      'pengeluaran_perempuan': 15.750,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indeks Pembangunan Manusia',
            overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildYearSelector(),
            const SizedBox(height: 20),
            _buildIpmValue(),
            const SizedBox(height: 20),
            _buildIpmChart(),
            const SizedBox(height: 20),
            _buildComponentsAnalysis(),
            const SizedBox(height: 20),
            _buildGenderAnalysis(),
            const SizedBox(height: 20),
            _buildProvinceRanking(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.trending_up, color: Colors.white, size: 40),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Indeks Pembangunan Manusia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Mengukur pencapaian pembangunan manusia',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Pilih Tahun Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [2020, 2021, 2022, 2023, 2024].map((year) {
              bool isSelected = selectedYear == year;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedYear = year;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6D4C41) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    '$year',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIpmValue() {
    final data = yearlyData[selectedYear]!;
    final ipm = data['ipm'];
    final previousYear = selectedYear - 1;
    final previousIpm = selectedYear > 2020 ? yearlyData[previousYear]!['ipm'] : null;
    final difference = previousIpm != null ? ipm - previousIpm : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'IPM Laki-laki $selectedYear',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            ipm.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          if (difference != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                '↗ +${difference.toStringAsFixed(2)} poin dari $previousYear',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'Kategori: Tinggi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpmChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perkembangan IPM Laki-laki (2020-2024)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const years = ['2020', '2021', '2022', '2023', '2024'];
                        if (value.toInt() < years.length) {
                          return Text(
                            years[value.toInt()],
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 85.22),
                      const FlSpot(1, 85.63),
                      const FlSpot(2, 86.15),
                      const FlSpot(3, 86.48),
                      const FlSpot(4, 87.03),
                    ],
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsAnalysis() {
    final data = yearlyData[selectedYear]!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komponen IPM Laki-laki',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          _buildComponentItem(
              'Umur Harapan Hidup', 
              data['usia_harapan_hidup'], 
              Icons.favorite, 
              Colors.red),
          const SizedBox(height: 10),
          _buildComponentItem(
              'Harapan Lama Sekolah', 
              '${data['harapan_lama_sekolah_laki']} tahun', 
              Icons.school, 
              Colors.blue),
          const SizedBox(height: 10),
          _buildComponentItem(
              'Rata-rata Lama Sekolah', 
              '${data['rata_lama_sekolah_laki']} tahun', 
              Icons.book, 
              Colors.purple),
          const SizedBox(height: 10),
          _buildComponentItem(
              'Pengeluaran per Kapita', 
              'Rp ${data['pengeluaran_laki']} juta',
              Icons.monetization_on, 
              Colors.green),
        ],
      ),
    );
  }

  Widget _buildGenderAnalysis() {
    final data = yearlyData[selectedYear]!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perbandingan Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          _buildGenderComparisonItem(
            'IPM Laki-laki',
            data['ipm'].toStringAsFixed(2),
            Colors.blue,
          ),
          const SizedBox(height: 10),
          _buildGenderComparisonItem(
            'IPM Perempuan',
            data['ipmPerempuan'].toStringAsFixed(2),
            Colors.pink,
          ),
          const SizedBox(height: 10),
          _buildGenderComparisonItem(
            'Indeks Paritas Gender (IPG)',
            data['ipg'].toStringAsFixed(2),
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderComparisonItem(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentItem(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProvinceRanking() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ranking IPM Provinsi (2023)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          _buildRankingItem(1, 'DKI Jakarta', '81.11'),
          _buildRankingItem(2, 'DI Yogyakarta', '80.68'),
          _buildRankingItem(3, 'Kalimantan Timur', '78.39'),
          _buildRankingItem(4, 'Kepulauan Riau', '77.70'),
          _buildRankingItem(5, 'Bali', '77.25'),
        ],
      ),
    );
  }

  Widget _buildRankingItem(int rank, String province, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rank <= 3 ? const Color(0xFF4CAF50) : Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              province,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}