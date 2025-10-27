import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Cache formatted values to avoid repeated calculations
  late final String populationFormatted;
  late final String malePopulationFormatted;
  late final String femalePopulationFormatted;
  late final String densityFormatted;
  late final String populationInMillions;
  late final String malePopulationInMillions;
  late final String femalePopulationInMillions;
  late final double malePercentage;
  late final double femalePercentage;

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
  }) {
    // Pre-calculate all formatted values once
    populationFormatted = population?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') ?? 'N/A';
    malePopulationFormatted = malePopulation?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') ?? 'N/A';
    femalePopulationFormatted = femalePopulation?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},') ?? 'N/A';
    densityFormatted = density?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.') ?? 'N/A';
    populationInMillions = population != null ? (population! / 1000000.0).toStringAsFixed(3) : 'N/A';
    malePopulationInMillions = malePopulation != null ? (malePopulation! / 1000000.0).toStringAsFixed(3) : 'N/A';
    femalePopulationInMillions = femalePopulation != null ? (femalePopulation! / 1000000.0).toStringAsFixed(3) : 'N/A';
    malePercentage = (population != null && malePopulation != null && population! > 0) 
        ? (malePopulation! / population! * 100) : 0.0;
    femalePercentage = (population != null && femalePopulation != null && population! > 0) 
        ? (femalePopulation! / population! * 100) : 0.0;
  }
}

class DistrictDensity {
  final String name;
  final int density;
  final double population;

  // Cache formatted values
  late final String densityFormatted;
  late final String populationFormatted;

  DistrictDensity({required this.name, required this.density, required this.population}) {
    densityFormatted = density.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
    populationFormatted = population.toStringAsFixed(2);
  }
}

class PendudukScreen extends StatefulWidget {
  const PendudukScreen({super.key});

  @override
  State<PendudukScreen> createState() => _PendudukScreenState();
}

class _PendudukScreenState extends State<PendudukScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  Map<int, SemarangData> semarangDataByYear = {};
  Map<int, List<DistrictDensity>> districtDensityByYear = {};
  List<int> availableYears = [];
  int selectedYear = 2024;
  bool isLoading = true;

  // Cache commonly used values
  List<FlSpot> _cachedSpots = [];
  Map<int, List<PieChartSectionData>> _cachedPieDataByYear = {};
  Map<int, Map<String, dynamic>> _ageDataByYear = {};
  List<Color> _districtColors = [];
  
  // Animation controller only for pie chart
  late AnimationController _pieChartAnimationController;
  late Animation<double> _pieChartAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // Only pie chart animation controller
    _pieChartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true); // Continuous animation for pie chart only
    
    _pieChartAnimation = CurvedAnimation(
      parent: _pieChartAnimationController,
      curve: Curves.easeInOut,
    );
    
    _initializeColors();
    _loadLocalData();
  }

  @override
  void dispose() {
    _pieChartAnimationController.dispose();
    super.dispose();
  }

  void _initializeColors() {
    _districtColors = [
      const Color(0xFF8B4513),
      const Color(0xFF8B4513),
      const Color(0xFF8B4513),
      const Color(0xFF9E9E9E),
      const Color(0xFF9E9E9E),
    ];
    
    // Age data by year from the PDF
    _ageDataByYear = {
      2020: {
        'usiaMuda': {'total': 367018, 'percentage': 22.20},
        'usiaProduktif': {'total': 1182010, 'percentage': 71.48},
        'usiaTua': {'total': 104496, 'percentage': 6.32},
        'totalPopulation': 1653524,
        'details': [
          {'range': '0-4', 'laki': 59956, 'perempuan': 57129, 'total': 117085},
          {'range': '5-9', 'laki': 62916, 'perempuan': 60072, 'total': 122988},
          {'range': '10-14', 'laki': 65339, 'perempuan': 61606, 'total': 126945},
          {'range': '15-19', 'laki': 67286, 'perempuan': 63530, 'total': 130816},
          {'range': '20-24', 'laki': 65164, 'perempuan': 62662, 'total': 127826},
          {'range': '25-29', 'laki': 65090, 'perempuan': 64926, 'total': 130016},
          {'range': '30-34', 'laki': 65816, 'perempuan': 66879, 'total': 132695},
          {'range': '35-39', 'laki': 66900, 'perempuan': 68394, 'total': 135294},
          {'range': '40-44', 'laki': 65889, 'perempuan': 68271, 'total': 134160},
          {'range': '45-49', 'laki': 58527, 'perempuan': 61788, 'total': 120315},
          {'range': '50-54', 'laki': 51278, 'perempuan': 55567, 'total': 106845},
          {'range': '55-59', 'laki': 43285, 'perempuan': 47881, 'total': 91166},
          {'range': '60-64', 'laki': 34843, 'perempuan': 38034, 'total': 72877},
          {'range': '65-69', 'laki': 24313, 'perempuan': 27697, 'total': 52010},
          {'range': '70-74', 'laki': 11895, 'perempuan': 14301, 'total': 26196},
          {'range': '75+', 'laki': 9944, 'perempuan': 16346, 'total': 26290},
        ],
      },
      2021: {
        'usiaMuda': {'total': 363757, 'percentage': 21.96},
        'usiaProduktif': {'total': 1182986, 'percentage': 71.41},
        'usiaTua': {'total': 109821, 'percentage': 6.63},
        'totalPopulation': 1656564,
        'details': [
          {'range': '0-4', 'laki': 59504, 'perempuan': 56673, 'total': 116177},
          {'range': '5-9', 'laki': 62324, 'perempuan': 59608, 'total': 121932},
          {'range': '10-14', 'laki': 64596, 'perempuan': 61052, 'total': 125648},
          {'range': '15-19', 'laki': 66546, 'perempuan': 62632, 'total': 129178},
          {'range': '20-24', 'laki': 64040, 'perempuan': 61511, 'total': 125551},
          {'range': '25-29', 'laki': 64617, 'perempuan': 64356, 'total': 128973},
          {'range': '30-34', 'laki': 65580, 'perempuan': 66547, 'total': 132127},
          {'range': '35-39', 'laki': 67039, 'perempuan': 68197, 'total': 135236},
          {'range': '40-44', 'laki': 66165, 'perempuan': 68233, 'total': 134398},
          {'range': '45-49', 'laki': 59085, 'perempuan': 62225, 'total': 121310},
          {'range': '50-54', 'laki': 51914, 'perempuan': 56164, 'total': 108078},
          {'range': '55-59', 'laki': 44172, 'perempuan': 48986, 'total': 93158},
          {'range': '60-64', 'laki': 35730, 'perempuan': 39247, 'total': 74977},
          {'range': '65-69', 'laki': 25328, 'perempuan': 28949, 'total': 54277},
          {'range': '70-74', 'laki': 12696, 'perempuan': 15245, 'total': 27941},
          {'range': '75+', 'laki': 10449, 'perempuan': 17154, 'total': 27603},
        ],
      },
      2022: {
        'usiaMuda': {'total': 360777, 'percentage': 21.73},
        'usiaProduktif': {'total': 1183941, 'percentage': 71.32},
        'usiaTua': {'total': 115257, 'percentage': 6.94},
        'totalPopulation': 1659975,
        'details': [
          {'range': '0-4', 'laki': 59101, 'perempuan': 56283, 'total': 115384},
          {'range': '5-9', 'laki': 61865, 'perempuan': 59196, 'total': 121061},
          {'range': '10-14', 'laki': 63815, 'perempuan': 60517, 'total': 124332},
          {'range': '15-19', 'laki': 65937, 'perempuan': 61897, 'total': 127834},
          {'range': '20-24', 'laki': 62965, 'perempuan': 60391, 'total': 123356},
          {'range': '25-29', 'laki': 64097, 'perempuan': 63745, 'total': 127842},
          {'range': '30-34', 'laki': 65280, 'perempuan': 66154, 'total': 131434},
          {'range': '35-39', 'laki': 67209, 'perempuan': 68102, 'total': 135311},
          {'range': '40-44', 'laki': 66353, 'perempuan': 68052, 'total': 134405},
          {'range': '45-49', 'laki': 59709, 'perempuan': 62734, 'total': 122443},
          {'range': '50-54', 'laki': 52471, 'perempuan': 56642, 'total': 109113},
          {'range': '55-59', 'laki': 45089, 'perempuan': 50074, 'total': 95163},
          {'range': '60-64', 'laki': 36590, 'perempuan': 40450, 'total': 77040},
          {'range': '65-69', 'laki': 26271, 'perempuan': 30137, 'total': 56408},
          {'range': '70-74', 'laki': 13534, 'perempuan': 16252, 'total': 29786},
          {'range': '75+', 'laki': 11019, 'perempuan': 18044, 'total': 29063},
        ],
      },
      2023: {
        'usiaMuda': {'total': 359130, 'percentage': 21.19},
        'usiaProduktif': {'total': 1207250, 'percentage': 71.23},
        'usiaTua': {'total': 128400, 'percentage': 7.58},
        'totalPopulation': 1694780,
        'details': [
          {'range': '0-4', 'laki': 58280, 'perempuan': 55860, 'total': 114140},
          {'range': '5-9', 'laki': 61670, 'perempuan': 58660, 'total': 120330},
          {'range': '10-14', 'laki': 64070, 'perempuan': 60590, 'total': 124660},
          {'range': '15-19', 'laki': 66360, 'perempuan': 62600, 'total': 128960},
          {'range': '20-24', 'laki': 66330, 'perempuan': 63130, 'total': 129460},
          {'range': '25-29', 'laki': 64290, 'perempuan': 63340, 'total': 127630},
          {'range': '30-34', 'laki': 65090, 'perempuan': 65770, 'total': 130860},
          {'range': '35-39', 'laki': 66060, 'perempuan': 67250, 'total': 133310},
          {'range': '40-44', 'laki': 66630, 'perempuan': 68570, 'total': 135200},
          {'range': '45-49', 'laki': 62770, 'perempuan': 65730, 'total': 128500},
          {'range': '50-54', 'laki': 54660, 'perempuan': 58680, 'total': 113340},
          {'range': '55-59', 'laki': 46880, 'perempuan': 51970, 'total': 98850},
          {'range': '60-64', 'laki': 38220, 'perempuan': 42920, 'total': 81140},
          {'range': '65-69', 'laki': 28670, 'perempuan': 32670, 'total': 61340},
          {'range': '70-74', 'laki': 17020, 'perempuan': 20600, 'total': 37620},
          {'range': '75+', 'laki': 11450, 'perempuan': 17990, 'total': 29440},
        ],
      },
      2024: {
        'usiaMuda': {'total': 356758, 'percentage': 20.88},
        'usiaProduktif': {'total': 1214892, 'percentage': 71.09},
        'usiaTua': {'total': 137183, 'percentage': 8.03},
        'totalPopulation': 1708833,
        'details': [
          {'range': '0-4', 'laki': 57967, 'perempuan': 55667, 'total': 113634},
          {'range': '5-9', 'laki': 61120, 'perempuan': 58045, 'total': 119165},
          {'range': '10-14', 'laki': 63672, 'perempuan': 60287, 'total': 123959},
          {'range': '15-19', 'laki': 65890, 'perempuan': 62137, 'total': 128027},
          {'range': '20-24', 'laki': 66726, 'perempuan': 63426, 'total': 130152},
          {'range': '25-29', 'laki': 64245, 'perempuan': 62935, 'total': 127180},
          {'range': '30-34', 'laki': 64864, 'perempuan': 65434, 'total': 130298},
          {'range': '35-39', 'laki': 65815, 'perempuan': 66913, 'total': 132728},
          {'range': '40-44', 'laki': 66510, 'perempuan': 68283, 'total': 134793},
          {'range': '45-49', 'laki': 64015, 'perempuan': 66896, 'total': 130911},
          {'range': '50-54', 'laki': 55857, 'perempuan': 59760, 'total': 115617},
          {'range': '55-59', 'laki': 48110, 'perempuan': 53216, 'total': 101326},
          {'range': '60-64', 'laki': 39315, 'perempuan': 44545, 'total': 83860},
          {'range': '65-69', 'laki': 29897, 'perempuan': 34122, 'total': 64019},
          {'range': '70-74', 'laki': 18681, 'perempuan': 22742, 'total': 41423},
          {'range': '75+', 'laki': 12493, 'perempuan': 19248, 'total': 31741},
        ],
      },
    };
    
    // Pre-calculate pie chart data for each year
    _cachedPieDataByYear = {};
    for (int year in _ageDataByYear.keys) {
      final ageData = _ageDataByYear[year]!;
      _cachedPieDataByYear[year] = [
        PieChartSectionData(
          color: Colors.blue[400]!,
          value: ageData['usiaMuda']['percentage'].toDouble(),
          title: '${ageData['usiaMuda']['percentage']}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.green[400]!,
          value: ageData['usiaProduktif']['percentage'].toDouble(),
          title: '${ageData['usiaProduktif']['percentage']}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.orange[400]!,
          value: ageData['usiaTua']['percentage'].toDouble(),
          title: '${ageData['usiaTua']['percentage']}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }
  }

  void _loadLocalData() {
    // Static data - no need to parse repeatedly
    final processedData = <int, SemarangData>{
      2020: SemarangData(
        year: 2020,
        population: 1653524,
        malePopulation: 818441,
        femalePopulation: 835083,
        area: 373.7,
        density: 4425,
        districts: 16,
        villages: 177,
      ),
      2021: SemarangData(
        year: 2021,
        population: 1656564,
        malePopulation: 819785,
        femalePopulation: 836779,
        area: 374.0,
        density: 4433,
        districts: 16,
        villages: 177,
        growthRate: 0.18,
      ),
      2022: SemarangData(
        year: 2022,
        population: 1659975,
        malePopulation: 821305,
        femalePopulation: 838670,
        area: 374.0,
        density: 4442,
        districts: 16,
        villages: 177,
        growthRate: 0.21,
      ),
      2023: SemarangData(
        year: 2023,
        population: 1694743,
        malePopulation: 838437,
        femalePopulation: 856306,
        area: 374.0,
        density: 4535,
        districts: 16,
        villages: 177,
        growthRate: 2.09,
      ),
      2024: SemarangData(
        year: 2024,
        population: 1708833,
        malePopulation: 845177,
        femalePopulation: 863656,
        area: 374.0,
        density: 4573,
        districts: 16,
        villages: 177,
        growthRate: 0.83,
      ),
    };

    // Pre-calculate chart spots - growth rates for each year
    _cachedSpots = [
      const FlSpot(0, 0), // 2020 - baseline
      const FlSpot(1, 0.0018), // 2021
      const FlSpot(2, 0.0021), // 2022
      const FlSpot(3, 0.0209), // 2023
      const FlSpot(4, 0.0083), // 2024
    ];

    // Static district data
    final districtData = <int, List<DistrictDensity>>{
      2020: [
        DistrictDensity(name: "Pedurungan", density: 9322, population: 193.151),
        DistrictDensity(name: "Tembalang", density: 4291, population: 189.680),
        DistrictDensity(name: "Semarang Barat", density: 6848, population: 148.879),
        DistrictDensity(name: "Banyumanik", density: 5530, population: 142.076),
        DistrictDensity(name: "Ngaliyan", density: 3731, population: 141.727),
      ],
      2021: [
        DistrictDensity(name: "Pedurungan", density: 9321, population: 193.128),
        DistrictDensity(name: "Tembalang", density: 4334, population: 191.560),
        DistrictDensity(name: "Semarang Barat", density: 6802, population: 147.885),
        DistrictDensity(name: "Ngaliyan", density: 3741, population: 142.131),
        DistrictDensity(name: "Banyumanik", density: 5515, population: 141.689),
      ],
      2022: [
        DistrictDensity(name: "Tembalang", density: 4377, population: 193.480),
        DistrictDensity(name: "Pedurungan", density: 9321, population: 193.125),
        DistrictDensity(name: "Semarang Barat", density: 6758, population: 146.915),
        DistrictDensity(name: "Ngaliyan", density: 3752, population: 142.553),
        DistrictDensity(name: "Banyumanik", density: 5501, population: 141.319),
      ],
      2023: [
        DistrictDensity(name: "Tembalang", density: 4499, population: 198.862),
        DistrictDensity(name: "Pedurungan", density: 9485, population: 196.526),
        DistrictDensity(name: "Semarang Barat", density: 6869, population: 149.326),
        DistrictDensity(name: "Ngaliyan", density: 3830, population: 145.495),
        DistrictDensity(name: "Banyumanik", density: 5583, population: 143.433),
      ],
      2024: [
        DistrictDensity(name: "Tembalang", density: 4566, population: 201.821),
        DistrictDensity(name: "Pedurungan", density: 9530, population: 197.468),
        DistrictDensity(name: "Semarang Barat", density: 6869, population: 149.327),
        DistrictDensity(name: "Ngaliyan", density: 3860, population: 146.628),
        DistrictDensity(name: "Banyumanik", density: 5595, population: 143.746),
      ],
    };

    // Simulate loading with shorter delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          semarangDataByYear = processedData;
          districtDensityByYear = districtData;
          availableYears = [2020, 2021, 2022, 2023, 2024];
          selectedYear = 2024;
          isLoading = false;
        });
        // Animations already running continuously
      }
    });
  }

  SemarangData get currentSemarangData {
    return semarangDataByYear[selectedYear] ?? semarangDataByYear[2024]!;
  }

  List<DistrictDensity> get currentDistrictDensity {
    return districtDensityByYear[selectedYear] ?? [];
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
    super.build(context);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF5EE),
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
      backgroundColor: const Color.fromARGB(255, 249, 242, 250),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          _buildYearSelector(),
          const SizedBox(height: 20),
          _buildPopulationStats(),
          const SizedBox(height: 20),
          _buildPopulationChart(),
          const SizedBox(height: 20),
          _buildAgeDistributionChart(),
          const SizedBox(height: 20),
          _buildAdministrativeData(),
          const SizedBox(height: 20),
          _buildDistrictDensitySection(),
          const SizedBox(height: 20),
          _buildDownloadSection(),
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloadPDFFromGoogleSheets,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  "Download PDF dari Google Sheets",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 212, 3, 3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdministrativeData() {
    final data = currentSemarangData;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Administrasi Kota Semarang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
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
                          '${data.districts}',
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
                          '${data.villages}',
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
                  'Penduduk',
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
          alignment: WrapAlignment.start,
          children: availableYears.map((year) {
            final isSelected = year == selectedYear;
            return SizedBox(
              width: 63,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedYear = year;
                  });
                  // No need to restart animations - they run continuously
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color.fromARGB(255, 121, 85, 72) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color.fromARGB(255, 121, 85, 72) : Colors.grey[300]!,
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
                '${data.populationInMillions} Juta jiwa',
                '${data.populationFormatted} jiwa',
                Icons.groups,
                Colors.brown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDensityCard(data),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                'Laki-laki',
                '${data.malePopulationInMillions} Juta jiwa',
                '${data.malePercentage.toStringAsFixed(1)}%',
                Icons.male,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderCard(
                'Perempuan',
                '${data.femalePopulationInMillions} Juta jiwa',
                '${data.femalePercentage.toStringAsFixed(1)}%',
                Icons.female,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
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
      ),
    );
  }

  Widget _buildDensityCard(SemarangData data) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_city, color: Colors.blue, size: 24),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.densityFormatted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212529),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'jiwa per km²',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Kepadatan',
              style: TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                'Luas: ${data.area?.toStringAsFixed(1) ?? 'N/A'} km²',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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
  return Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laju Pertumbuhan Penduduk Kota Semarang (%)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 0.025,
                minX: 0,
                maxX: 4,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.0025,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFFE9ECEF),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 0.0025, 
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value <= 0.025) {
                          return Text(
                            '${(value * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 9, color: Color(0xFF6C757D)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const years = [2020, 2021, 2022, 2023, 2024];
                        int index = value.toInt();
                        if (index >= 0 && index < years.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              years[index].toString(),
                              style: const TextStyle(fontSize: 10, color: Color(0xFF6C757D)),
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
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE9ECEF), width: 1),
                    bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _cachedSpots, // No animation
                    isCurved: true,
                    color: const Color(0xFF795548),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
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
                        const years = [2020, 2021, 2022, 2023, 2024];
                        final int index = barSpot.x.toInt();

                        if (index < 0 || index >= years.length) return null;
                        
                        final originalY = _cachedSpots[index].y;
                        if (originalY == 0) return null;

                        final year = years[index];
                        final growthPercent = (originalY * 100).toStringAsFixed(2);
                        
                        return LineTooltipItem(
                          '$year\n$growthPercent %',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).where((item) => item != null).map((item) => item!).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAgeDistributionChart() {
  return Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Umur Penduduk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Center(
              child: SizedBox(
                height: 160,
                width: 160,
                child: AnimatedBuilder(
                  animation: _pieChartAnimation,
                  builder: (context, child) {
                    // Create a subtle pulsing effect (0.95 to 1.05 scale)
                    final animationValue = 0.95 + (_pieChartAnimation.value * 0.1);
                    final sections = _cachedPieDataByYear[selectedYear] ?? [];
                    return PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: sections.map((section) {
                          return PieChartSectionData(
                            color: section.color,
                            value: section.value,
                            title: section.title,
                            radius: 60 * animationValue, // Pulsing radius
                            titleStyle: section.titleStyle,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Usia Muda (0-14)', Colors.blue[400]!),
              const SizedBox(height: 8),
              _buildLegendItem('Usia Produktif (15-64)', Colors.green[400]!),
              const SizedBox(height: 8),
              _buildLegendItem('Usia Tua (65+)', Colors.orange[400]!),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildLegendItem(String title, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF212529),
        ),
      ),
    ],
  );
}

  Widget _buildDistrictDensitySection() {
    final districts = currentDistrictDensity;
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '5 Kecamatan Terpadat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 16),
            if (districts.isNotEmpty) ...[
              ...districts.asMap().entries.map((entry) {
                final index = entry.key;
                final district = entry.value;
                final ranking = index + 1;
                final circleColor = _districtColors[index];
                
                // Calculate percentage based on total population
                final totalCityPopulation = currentSemarangData.population ?? 1708833;
                final districtPopulationCount = (district.population * 1000).toInt();
                final percentage = (districtPopulationCount / totalCityPopulation * 100);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$ranking',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              district.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212529),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${district.populationFormatted} Ribu',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, size: 48, color: Color(0xFFADB5BD)),
                      const SizedBox(height: 8),
                      Text(
                        'Data kecamatan tidak tersedia untuk tahun $selectedYear',
                        style: const TextStyle(color: Color(0xFF6C757D), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}