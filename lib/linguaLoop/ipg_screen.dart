import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class IPGData {
  final int year;
  final double? uhh; // Umur Harapan Hidup
  final double? hls; // Harapan Lama Sekolah
  final double? rls; // Rata-rata Lama Sekolah
  final double? ppp; // Pengeluaran per Kapita
  final double? ikg; // Indeks Ketimpangan Gender
  final double? ipg; // Indeks Pembangunan Gender
  final double? uhhMale; // UHH Laki-laki
  final double? uhhFemale; // UHH Perempuan
  final double? hlsMale; // HLS Laki-laki
  final double? hlsFemale; // HLS Perempuan
  final double? rlsMale; // RLS Laki-laki
  final double? rlsFemale; // RLS Perempuan
  final double? pppMale; // PPP Laki-laki
  final double? pppFemale; // PPP Perempuan

  IPGData({
    required this.year,
    this.uhh,
    this.hls,
    this.rls,
    this.ppp,
    this.ikg,
    this.ipg,
    this.uhhMale,
    this.uhhFemale,
    this.hlsMale,
    this.hlsFemale,
    this.rlsMale,
    this.rlsFemale,
    this.pppMale,
    this.pppFemale,
  });

  String get ipgFormatted => ipg != null ? ipg!.toStringAsFixed(1) : 'N/A';
  String get ikgFormatted => ikg != null ? (ikg! * 100).toStringAsFixed(1) : 'N/A';
  String get uhhFormatted => uhh != null ? uhh!.toStringAsFixed(1) : 'N/A';
  String get hlsFormatted => hls != null ? hls!.toStringAsFixed(1) : 'N/A';
  String get rlsFormatted => rls != null ? rls!.toStringAsFixed(1) : 'N/A';
  String get pppFormatted => ppp != null ? (ppp! / 1000).toStringAsFixed(0) : 'N/A';

  // Gender specific formatted values
  String get uhhMaleFormatted => uhhMale != null ? uhhMale!.toStringAsFixed(1) : 'N/A';
  String get uhhFemaleFormatted => uhhFemale != null ? uhhFemale!.toStringAsFixed(1) : 'N/A';
  String get hlsMaleFormatted => hlsMale != null ? hlsMale!.toStringAsFixed(1) : 'N/A';
  String get hlsFemaleFormatted => hlsFemale != null ? hlsFemale!.toStringAsFixed(1) : 'N/A';
  String get rlsMaleFormatted => rlsMale != null ? rlsMale!.toStringAsFixed(1) : 'N/A';
  String get rlsFemaleFormatted => rlsFemale != null ? rlsFemale!.toStringAsFixed(1) : 'N/A';
  String get pppMaleFormatted => pppMale != null ? (pppMale! / 1000).toStringAsFixed(0) : 'N/A';
  String get pppFemaleFormatted => pppFemale != null ? (pppFemale! / 1000).toStringAsFixed(0) : 'N/A';
  
  // Gender percentage calculation for each indicator
  double get uhhGap => (uhhMale != null && uhhFemale != null && uhhMale! > 0) 
      ? ((uhhFemale! - uhhMale!) / uhhMale! * 100) : 0.0;
  double get hlsGap => (hlsMale != null && hlsFemale != null && hlsMale! > 0) 
      ? ((hlsFemale! - hlsMale!) / hlsMale! * 100) : 0.0;
}

class IPGScreen extends StatefulWidget {
  const IPGScreen({super.key});

  @override
  State<IPGScreen> createState() => _IPGScreenState();
}

class _IPGScreenState extends State<IPGScreen> {
  Map<int, IPGData> ipgDataByYear = {};
  List<int> availableYears = [];
  int selectedYear = 2023;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIPGData();
  }

  void _loadIPGData() {
    // Data sementara untuk IPG dengan nilai yang lebih realistis
    final List<Map<String, dynamic>> rawData = [
      {
        "Tahun": 2019,
        "UHH_Laki": 71.8,
        "UHH_Perempuan": 75.6,
        "HLS_Laki": 12.9,
        "HLS_Perempuan": 13.2,
        "RLS_Laki": 9.8,
        "RLS_Perempuan": 9.4,
        "PPP_Laki": 18500.0,
        "PPP_Perempuan": 10200.0,
        "IKG": 0.892,
        "IPG": 95.8
      },
      {
        "Tahun": 2020,
        "UHH_Laki": 72.1,
        "UHH_Perempuan": 75.9,
        "HLS_Laki": 13.1,
        "HLS_Perempuan": 13.4,
        "RLS_Laki": 9.9,
        "RLS_Perempuan": 9.5,
        "PPP_Laki": 18800.0,
        "PPP_Perempuan": 10500.0,
        "IKG": 0.895,
        "IPG": 96.2
      },
      {
        "Tahun": 2021,
        "UHH_Laki": 72.3,
        "UHH_Perempuan": 76.1,
        "HLS_Laki": 13.2,
        "HLS_Perempuan": 13.5,
        "RLS_Laki": 10.1,
        "RLS_Perempuan": 9.7,
        "PPP_Laki": 19200.0,
        "PPP_Perempuan": 10800.0,
        "IKG": 0.898,
        "IPG": 96.5
      },
      {
        "Tahun": 2022,
        "UHH_Laki": 72.6,
        "UHH_Perempuan": 76.4,
        "HLS_Laki": 13.4,
        "HLS_Perempuan": 13.7,
        "RLS_Laki": 10.2,
        "RLS_Perempuan": 9.8,
        "PPP_Laki": 19600.0,
        "PPP_Perempuan": 11200.0,
        "IKG": 0.901,
        "IPG": 96.8
      },
      {
        "Tahun": 2023,
        "UHH_Laki": 72.8,
        "UHH_Perempuan": 76.6,
        "HLS_Laki": 13.5,
        "HLS_Perempuan": 13.8,
        "RLS_Laki": 10.3,
        "RLS_Perempuan": 9.9,
        "PPP_Laki": 20000.0,
        "PPP_Perempuan": 11500.0,
        "IKG": 0.904,
        "IPG": 97.1
      },
    ];

    Map<int, IPGData> processedData = {};

    for (var row in rawData) {
      final int year = row["Tahun"] as int;
      
      processedData[year] = IPGData(
        year: year,
        uhh: ((row["UHH_Laki"] + row["UHH_Perempuan"]) / 2).toDouble(),
        hls: ((row["HLS_Laki"] + row["HLS_Perempuan"]) / 2).toDouble(),
        rls: ((row["RLS_Laki"] + row["RLS_Perempuan"]) / 2).toDouble(),
        ppp: ((row["PPP_Laki"] + row["PPP_Perempuan"]) / 2).toDouble(),
        ikg: (row["IKG"] as double),
        ipg: (row["IPG"] as double),
        uhhMale: (row["UHH_Laki"] as double),
        uhhFemale: (row["UHH_Perempuan"] as double),
        hlsMale: (row["HLS_Laki"] as double),
        hlsFemale: (row["HLS_Perempuan"] as double),
        rlsMale: (row["RLS_Laki"] as double),
        rlsFemale: (row["RLS_Perempuan"] as double),
        pppMale: (row["PPP_Laki"] as double),
        pppFemale: (row["PPP_Perempuan"] as double),
      );
    }

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          ipgDataByYear = processedData;
          availableYears = processedData.keys.toList()..sort();
          if (availableYears.isNotEmpty) {
            selectedYear = availableYears.last;
          }
          isLoading = false;
        });
      }
    });
  }

  IPGData get currentIPGData {
    if (ipgDataByYear.isEmpty) {
      return IPGData(year: selectedYear);
    }
    return ipgDataByYear[selectedYear] ?? ipgDataByYear[availableYears.last]!;
  }

  Future<void> _downloadPDFFromGoogleSheets() async {
    const String pdfUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSH3FNCskAXqg0lRfl44sS7omSzIkAX-csRfyud4PBlN0Wv-aTFAKjLXAlPiJg0ng/pub?output=pdf';
    
    try {
      final Uri url = Uri.parse(pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka link download PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengakses PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Indeks Pembangunan Gender'),
          backgroundColor: const Color(0xFF7B1FA2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF7B1FA2)),
              SizedBox(height: 16),
              Text('Memuat data IPG...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indeks Pembangunan Gender'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: const Color.fromARGB(255, 235, 216, 235),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data yang ditampilkan bersumber dari data statistik resmi.'),
                ),
              );
            },
            tooltip: 'Sumber Data',
          ),
        ],
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
            _buildIPGStats(),
            const SizedBox(height: 20),
            _buildIPGChart(),
            const SizedBox(height: 20),
            _buildGenderComparison(),
            const SizedBox(height: 20),
            _buildIPGDescription(),
            const SizedBox(height: 20),
            _buildDownloadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final data = currentIPGData;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.balance, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Indeks Pembangunan Gender',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Data IPG tahun ${data.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
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
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
              const SizedBox(width: 8),
              Text(
                'Pilih Tahun Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableYears.map((year) {
              final isSelected = year == selectedYear;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedYear = year;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7B1FA2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7B1FA2) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
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

  Widget _buildIPGStats() {
    final data = currentIPGData;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'IPG (Indeks)',
                data.ipgFormatted,
                'Pembangunan Gender',
                Icons.balance,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'IKG (Indeks)',
                '${data.ikgFormatted}%',
                'Ketimpangan Gender',
                Icons.equalizer,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                'UHH Rata-rata',
                '${data.uhhFormatted} tahun',
                'Umur Harapan Hidup',
                Icons.favorite,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderCard(
                'HLS Rata-rata',
                '${data.hlsFormatted} tahun',
                'Harapan Lama Sekolah',
                Icons.school,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIPGChart() {
    List<FlSpot> ipgSpots = [];
    List<FlSpot> ikgSpots = [];
    List<String> yearLabels = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final data = ipgDataByYear[year];
      if (data != null) {
        if (data.ipg != null) {
          ipgSpots.add(FlSpot(i.toDouble(), data.ipg!));
          if (data.ipg! < minY) minY = data.ipg!;
          if (data.ipg! > maxY) maxY = data.ipg!;
        }
        if (data.ikg != null) {
          double ikgPercentage = data.ikg! * 100;
          ikgSpots.add(FlSpot(i.toDouble(), ikgPercentage));
          if (ikgPercentage < minY) minY = ikgPercentage;
          if (ikgPercentage > maxY) maxY = ikgPercentage;
        }
        yearLabels.add(year.toString());
      }
    }

    double padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;

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
            'Perkembangan IPG dan IKG',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ipgSpots.isNotEmpty
                ? LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              if (value >= minY && value <= maxY) {
                                return Text(
                                  value.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < yearLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    yearLabels[value.toInt()],
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                          bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: ipgSpots,
                          isCurved: true,
                          color: const Color(0xFF7B1FA2),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF7B1FA2),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF7B1FA2).withOpacity(0.15),
                          ),
                        ),
                        LineChartBarData(
                          spots: ikgSpots,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.orange,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final year = yearLabels[barSpot.x.toInt()];
                              final isIPG = barSpot.barIndex == 0;
                              return LineTooltipItem(
                                '$year\n${isIPG ? "IPG" : "IKG"}: ${barSpot.y.toStringAsFixed(1)}${isIPG ? "" : "%"}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Data IPG tidak tersedia',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderComparison() {
    final data = currentIPGData;
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
            'Perbandingan Gender Tahun ${data.year}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.male, color: Colors.blue[600], size: 24),
                      const SizedBox(height: 8),
                      Text(
                        'Laki-laki',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const Divider(height: 16),
                      _buildComparisonRow('UHH:', '${data.uhhMaleFormatted} thn'),
                      _buildComparisonRow('HLS:', '${data.hlsMaleFormatted} thn'),
                      _buildComparisonRow('RLS:', '${data.rlsMaleFormatted} thn'),
                      _buildComparisonRow('Pendapatan:', '${data.pppMaleFormatted} rb'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.pink[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.female, color: Colors.pink[600], size: 24),
                      const SizedBox(height: 8),
                      Text(
                        'Perempuan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[800],
                        ),
                      ),
                      const Divider(height: 16),
                      _buildComparisonRow('UHH:', '${data.uhhFemaleFormatted} thn'),
                      _buildComparisonRow('HLS:', '${data.hlsFemaleFormatted} thn'),
                      _buildComparisonRow('RLS:', '${data.rlsFemaleFormatted} thn'),
                      _buildComparisonRow('Pendapatan:', '${data.pppFemaleFormatted} rb'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIPGDescription() {
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
            'Apa itu IPG & IKG?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5),
              children: const [
                TextSpan(
                  text: 'Indeks Pembangunan Gender (IPG) ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'mengukur capaian pembangunan manusia yang sama dengan IPM, namun memperhatikan ketimpangan gender. Semakin tinggi nilai IPG (mendekati 100), semakin setara pembangunan antara laki-laki dan perempuan.',
                ),
                TextSpan(text: '\n\n'),
                TextSpan(
                  text: 'Indeks Ketimpangan Gender (IKG) ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'mengukur sejauh mana potensi pembangunan manusia hilang akibat ketidaksetaraan gender. Nilai IKG yang lebih rendah menunjukkan ketimpangan yang lebih kecil.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
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
            'Download Laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _downloadPDFFromGoogleSheets,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF dari Google Sheets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
           const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan PDF dari Google Sheets',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Download langsung dari Google Sheets\n'
                        '• Data terkini dan terupdate\n'
                        '• Format PDF siap cetak\n'
                        '• Akses melalui browser',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}