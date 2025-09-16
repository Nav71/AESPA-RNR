import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui';

class SemarangData {
  final int year;
  final int? population;
  final double? area;
  final int? density;
  final int? districts;
  final int? villages;
  final int? malePopulation;
  final int? femalePopulation;
  final double? growthRate;

  SemarangData({
    required this.year,
    this.population,
    this.area,
    this.density,
    this.districts,
    this.villages,
    this.malePopulation,
    this.femalePopulation,
    this.growthRate,
  });

  // Helper methods for formatted display
  String get populationFormatted => population != null ? population.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') : 'N/A';
  String get malePopulationFormatted => malePopulation != null ? malePopulation.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') : 'N/A';
  String get femalePopulationFormatted => femalePopulation != null ? femalePopulation.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') : 'N/A';
  String get densityFormatted => density != null ? density.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') : 'N/A';
  
  // Helper for million format
  String get populationInMillions => population != null ? (population! / 1000000.0).toStringAsFixed(3) : 'N/A';
  String get malePopulationInMillions => malePopulation != null ? (malePopulation! / 1000000.0).toStringAsFixed(3) : 'N/A';
  String get femalePopulationInMillions => femalePopulation != null ? (femalePopulation! / 1000000.0).toStringAsFixed(3) : 'N/A';
  
  // Gender percentage calculation
  double get malePercentage => (population != null && malePopulation != null && population! > 0) 
      ? (malePopulation! / population! * 100) : 0.0;
  double get femalePercentage => (population != null && femalePopulation != null && population! > 0) 
      ? (femalePopulation! / population! * 100) : 0.0;
}

class PendudukScreen extends StatefulWidget {
  const PendudukScreen({super.key});

  @override
  _PendudukScreenState createState() => _PendudukScreenState();
}

class _PendudukScreenState extends State<PendudukScreen> {
  Map<int, SemarangData> semarangDataByYear = {};
  List<int> availableYears = [];
  int selectedYear = 2024;
  bool isLoading = true;
  bool isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  void _loadLocalData() {
    // Data akurat dari PDF yang dilampirkan
    final List<Map<String, dynamic>> rawData = [
      {
        "Tahun": 2020,
        "Laki Laki": "818,441",
        "Perempuan": "835,083",
        "Total Penduduk": "1,653,524",
        "Luas Wilayah": "373.7",
        "Kepadatan": "4,425"
      },
      {
        "Tahun": 2021,
        "Laki Laki": "819,785",
        "Perempuan": "836,779",
        "Total Penduduk": "1,656,564",
        "Luas Wilayah": "374",
        "Kepadatan": "4,433"
      },
      {
        "Tahun": 2022,
        "Laki Laki": "821,305",
        "Perempuan": "838,670", // Diperbaiki dari "838,67"
        "Total Penduduk": "1,659,975",
        "Luas Wilayah": "374",
        "Kepadatan": "4,442"
      },
      {
        "Tahun": 2023,
        "Laki Laki": "838,437",
        "Perempuan": "856,306",
        "Total Penduduk": "1,694,743",
        "Luas Wilayah": "374",
        "Kepadatan": "4,535"
      },
      {
        "Tahun": 2024,
        "Laki Laki": "845,177",
        "Perempuan": "863,656",
        "Total Penduduk": "1,708,833",
        "Luas Wilayah": "374",
        "Kepadatan": "4,573"
      },
    ];

    Map<int, SemarangData> processedData = {};

    // Function to parse numbers with comma separators
    int parsePopulationNumber(String value) {
      return int.parse(value.replaceAll(',', ''));
    }

    int parseDensityNumber(String value) {
      return int.parse(value.replaceAll(',', ''));
    }

    // Calculate growth rates
    Map<int, double> growthRates = {};
    for (int i = 1; i < rawData.length; i++) {
      final currentYear = rawData[i]["Tahun"];
      final currentPop = parsePopulationNumber(rawData[i]["Total Penduduk"]);
      final previousPop = parsePopulationNumber(rawData[i - 1]["Total Penduduk"]);
      
      final growthRate = ((currentPop - previousPop) / previousPop * 100);
      growthRates[currentYear] = growthRate;
    }

    for (var row in rawData) {
  final int year = row["Tahun"];
  final int totalPop = parsePopulationNumber(row["Total Penduduk"]);
  final int malePop = parsePopulationNumber(row["Laki Laki"]);
  final int femalePop = parsePopulationNumber(row["Perempuan"]);

  processedData[year] = SemarangData(
    year: year,
    population: totalPop,
    malePopulation: malePop,
    femalePopulation: femalePop,
    area: double.tryParse(row["Luas Wilayah"].toString()),
    density: parseDensityNumber(row["Kepadatan"]),
    districts: 16, // Konstanta untuk Kota Semarang
    villages: 177, // Konstanta untuk Kota Semarang
    growthRate: growthRates[year],
  );
}

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          semarangDataByYear = processedData;
          availableYears = processedData.keys.toList()..sort();
          if (availableYears.isNotEmpty) {
            selectedYear = availableYears.last;
          }
          isLoading = false;
        });
      }
    });
  }

  SemarangData get currentSemarangData {
    if (semarangDataByYear.isEmpty) {
      return SemarangData(year: selectedYear, districts: 16, villages: 177);
    }
    return semarangDataByYear[selectedYear] ?? semarangDataByYear[availableYears.last]!;
  }

  Future<void> _generateComprehensivePDFReport() async {
    setState(() {
      isGeneratingPDF = true;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              _buildPDFCurrentYearData(),
              pw.SizedBox(height: 20),
              _buildPDFComprehensiveTable(),
              pw.SizedBox(height: 20),
              _buildPDFGrowthAnalysis(),
              pw.SizedBox(height: 30),
              _buildPDFFooter(),
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingPDF = false;
        });
      }
    }
  }

  pw.Widget _buildPDFHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.brown700,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Icon(pw.IconData(0xe0c8), size: 30, color: PdfColors.white),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN LENGKAP DATA KEPENDUDUKAN',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Kota Semarang - Tahun ${availableYears.first} - ${availableYears.last}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  'Sumber Data: Dokumen Lokal (PDF)',
                  style: pw.TextStyle(
                    color: PdfColor(1, 1, 1, 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFCurrentYearData() {
    final data = currentSemarangData;
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RINGKASAN DATA TAHUN ${data.year}',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _buildPDFTableRow('Indikator', 'Nilai', true),
              _buildPDFTableRow('Total Penduduk', '${data.populationFormatted} jiwa'),
              _buildPDFTableRow('Penduduk Laki-laki', '${data.malePopulationFormatted} jiwa'),
              _buildPDFTableRow('Penduduk Perempuan', '${data.femalePopulationFormatted} jiwa'),
              _buildPDFTableRow('Luas Wilayah', data.area != null ? '${data.area!.toStringAsFixed(1)} km²' : 'N/A'),
              _buildPDFTableRow('Kepadatan Penduduk', '${data.densityFormatted} jiwa/km²'),
              _buildPDFTableRow('Jumlah Kecamatan', '${data.districts} Kecamatan'),
              _buildPDFTableRow('Jumlah Kelurahan', '${data.villages} Kelurahan'),
              if (data.growthRate != null)
                _buildPDFTableRow('Laju Pertumbuhan', '${data.growthRate!.toStringAsFixed(2)}%'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFComprehensiveTable() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DATA LENGKAP SEMUA TAHUN',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Tahun', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Total Penduduk', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Laki-laki', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Perempuan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Kepadatan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Pertumbuhan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  ),
                ],
              ),
              ...availableYears.map((year) {
                final data = semarangDataByYear[year]!;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(year.toString(), style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(data.populationFormatted, style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(data.malePopulationFormatted, style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(data.femalePopulationFormatted, style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(data.densityFormatted, style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        data.growthRate != null ? '${data.growthRate!.toStringAsFixed(2)}%' : '-',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFGrowthAnalysis() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ANALISIS LAJU PERTUMBUHAN',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Berdasarkan data 2020-2024, tren pertumbuhan penduduk Kota Semarang menunjukkan pola yang relatif stabil dengan variasi laju pertumbuhan tahunan. Pertumbuhan tertinggi terjadi pada tahun 2023.',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CATATAN:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '• Data bersumber dari dokumen PDF yang disediakan.\n'
            '• Kepadatan dalam satuan jiwa per km².\n'
            '• Laju pertumbuhan dihitung berdasarkan tahun sebelumnya.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Laporan dibuat pada: ${DateTime.now().toString().substring(0, 19)}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildPDFTableRow(String label, String value, [bool isHeader = false]) {
    return pw.TableRow(
      decoration: isHeader ? pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: isHeader
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
                : const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: isHeader
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
                : const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Penduduk Kota Semarang'),
          backgroundColor: const Color(0xFF795548),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF795548)),
              SizedBox(height: 16),
              Text('Memuat data lokal...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Penduduk Kota Semarang'),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data yang ditampilkan bersumber dari dokumen lokal.'),
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
            _buildPopulationStats(),
            const SizedBox(height: 20),
            _buildPopulationChart(),
            const SizedBox(height: 20),
            _buildGenderDistribution(),
            const SizedBox(height: 20),
            _buildAdministrativeData(),
            const SizedBox(height: 20),
            _buildDownloadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final data = currentSemarangData;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF795548), Color(0xFF8D6E63)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_city, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kota Semarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Data kependudukan tahun ${data.year}',
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
                    color: isSelected ? const Color(0xFF795548) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF795548) : Colors.grey[300]!,
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

  Widget _buildPopulationStats() {
    final data = currentSemarangData;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Penduduk',
                '${data.populationInMillions} Juta',
                '${data.populationFormatted} jiwa',
                Icons.groups,
                Colors.brown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Kepadatan',
                '${data.densityFormatted}',
                'jiwa per km²',
                Icons.location_city,
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
                'Laki-laki',
                '${data.malePopulationInMillions} Juta',
                '${data.malePercentage.toStringAsFixed(1)}%',
                Icons.male,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderCard(
                'Perempuan',
                '${data.femalePopulationInMillions} Juta',
                '${data.femalePercentage.toStringAsFixed(1)}%',
                Icons.female,
                Colors.pink,
              ),
            ),
          ],
        ),
        if (data.growthRate != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.trending_up, color: Colors.green[600], size: 24),
                const SizedBox(height: 8),
                Text(
                  '${data.growthRate!.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  'Laju Pertumbuhan Tahun ${data.year}',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildGenderCard(String title, String value, String percentage, IconData icon, Color color) {
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
            percentage,
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

  Widget _buildPopulationChart() {
    List<FlSpot> spots = [];
    List<String> yearLabels = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final semarangData = semarangDataByYear[year];
      if (semarangData?.population != null) {
        // Convert to millions for chart display with higher precision
        double populationInMillions = semarangData!.population! / 1000000.0;
        spots.add(FlSpot(i.toDouble(), populationInMillions));
        yearLabels.add(year.toString());
        
        if (populationInMillions < minY) minY = populationInMillions;
        if (populationInMillions > maxY) maxY = populationInMillions;
      }
    }

    // Add some padding to Y axis range
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
            'Pertumbuhan Penduduk Kota Semarang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: spots.isNotEmpty
                ? LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 0.02, // More precise grid lines
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
                            reservedSize: 45,
                            interval: 0.02,
                            getTitlesWidget: (value, meta) {
                              // Show precise values based on actual data
                              if (value >= minY && value <= maxY) {
                                return Text(
                                  '${value.toStringAsFixed(2)}M',
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
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFF795548),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF795548),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF795548).withOpacity(0.15),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final year = yearLabels[barSpot.x.toInt()];
                              final population = (barSpot.y * 1000000).toInt();
                              final formattedPop = population.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                                (match) => '${match[1]},'
                              );
                              return LineTooltipItem(
                                '$year\n$formattedPop jiwa',
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
                          'Data populasi tidak tersedia',
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

  Widget _buildGenderDistribution() {
    final data = currentSemarangData;
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
            'Luas Wilayah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.square_foot, color: Colors.green[600], size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.area != null ? '${data.area!.toStringAsFixed(1)} km²' : 'N/A',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      'Total Luas Wilayah Daratan',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrativeData() {
    final data = currentSemarangData;
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
            'Data Administrasi Kota Semarang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance, color: Colors.purple[600], size: 24),
                      const SizedBox(height: 8),
                      Text(
                        data.districts != null ? '${data.districts}' : '-',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                      Text(
                        'Kecamatan',
                        style: TextStyle(fontSize: 12, color: Colors.purple[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.teal[600], size: 24),
                      const SizedBox(height: 8),
                      Text(
                        data.villages != null ? '${data.villages}' : '-',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      Text(
                        'Kelurahan',
                        style: TextStyle(fontSize: 12, color: Colors.teal[600]),
                      ),
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
              onPressed: isGeneratingPDF ? null : _generateComprehensivePDFReport,
              icon: isGeneratingPDF
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(isGeneratingPDF ? 'Membuat PDF...' : 'Download Laporan Lengkap PDF'),
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
                        'Laporan PDF Lengkap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Data lengkap semua tahun (${availableYears.first}-${availableYears.last})\n'
                        '• Ringkasan dan tabel komprehensif\n'
                        '• Analisis laju pertumbuhan\n'
                        '• Siap untuk presentasi atau arsip',
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