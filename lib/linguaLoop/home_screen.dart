import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_services.dart';
import 'statistics_data.dart';
import 'data_list_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'all_publications_screen.dart';
// Import screens for statistics categories
import 'tenaga_kerja_screen.dart';
import 'ipm_screen.dart';
import 'kemiskinana_screen.dart';
import 'inflasi_screen.dart';
import 'penduduk_screen.dart';
import 'pertumbuhan_ekonomi_screen.dart';
import 'ipg_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? latestStats;
  List<Publication> recentPublications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final stats = await _apiService.getLatestStatistics();
      final publications = await _apiService.getRecentPublications();

      setState(() {
        latestStats = stats;
        recentPublications =
            publications.map((json) => Publication.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const DataListScreen(),
          const MapScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF1976D2),
          flexibleSpace: const FlexibleSpaceBar(
            title: Text(
              'STATISTIK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildStatisticsIconsGrid(),
              const SizedBox(height: 30),
              _buildStatisticsSection(),
              const SizedBox(height: 20),
              _buildRecentPublications(),
              const SizedBox(height: 20),
              _buildInfographicsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Jelajahi data statistik Indonesia terlengkap dan terpercaya',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.analytics,
            color: Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsIconsGrid() {
  final List<Map<String, dynamic>> statisticsItems = [
    {
      'icon': Icons.work,
      'title': 'Tenaga Kerja',
      'color': Colors.blue,
      'screen': const TenagaKerjaScreen()
    },
    {
      'icon': Icons.trending_up,
      'title': 'IPM',
      'color': Colors.green,
      'screen': const IpmScreen()
    },
    // UBAH BAGIAN INI:
    {
      'icon': Icons.balance,
      'title': 'IPG',
      'color': Colors.purple,
      'screen': const IPGScreen(), // Ganti dari 'IPG' string menjadi IPGScreen()
    },
    {
      'icon': Icons.equalizer,
      'title': 'IDG',
      'color': Colors.orange,
      'screen': _buildComingSoonScreen(
          'IDG', 'Indeks Pemberdayaan Gender', Icons.equalizer, Colors.orange)
    },
    {
      'icon': Icons.pie_chart,
      'title': 'Rasio',
      'color': Colors.teal,
      'screen': _buildComingSoonScreen(
          'Rasio', 'Rasio Statistik', Icons.pie_chart, Colors.teal)
    },
    {
      'icon': Icons.trending_down,
      'title': 'Kemiskinan',
      'color': Colors.red,
      'screen': const KemiskinanScreen()
    },
    {
      'icon': Icons.attach_money,
      'title': 'Inflasi',
      'color': Colors.indigo,
      'screen': const InflasiScreen()
    },
    {
      'icon': Icons.show_chart,
      'title': 'Pertumbuhan Ekonomi',
      'color': Colors.cyan,
      'screen': const PertumbuhanEkonomiScreen()
    },
    {
      'icon': Icons.school,
      'title': 'Pendidikan',
      'color': Colors.deepPurple,
      'screen': _buildComingSoonScreen('Pendidikan', 'Statistik Pendidikan',
          Icons.school, Colors.deepPurple)
    },
    {
      'icon': Icons.people,
      'title': 'Penduduk',
      'color': Colors.brown,
      'screen': const PendudukScreen()
    },
  ];

  // Sisa kode tetap sama...
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey[200]!),
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
          'Kategori Statistik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 20,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: statisticsItems.length,
          itemBuilder: (context, index) {
            final item = statisticsItems[index];
            return _buildStatisticIcon(
              item['icon'],
              item['title'],
              item['color'],
              item['screen'],
            );
          },
        ),
      ],
    ),
  );
}

  Widget _buildStatisticIcon(
    IconData icon, String title, Color color, Widget screen) {
  return GestureDetector(
    onTap: () {
  // Langsung saja navigasi, karena kita sudah yakin 'screen' adalah Widget
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => screen),
  );
},
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildComingSoonScreen(
      String title, String description, IconData icon, Color color) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 30),
                        const SizedBox(width: 15),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(icon, color: color, size: 40),
                          const SizedBox(height: 10),
                          Text(
                            'Halaman dalam pengembangan',
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Data statistik akan segera tersedia',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    if (isLoading) {
      return _buildLoadingCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Terbaru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        _buildPopulationChart(),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Jumlah Penduduk', '272M', Icons.people, Colors.blue)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildStatCard('Tingkat Kemiskinan', '9.54%',
                    Icons.trending_down, Colors.orange)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Kepadatan', '149/km²', Icons.location_city, Colors.green)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildStatCard(
                    'Pertumbuhan', '5.31%', Icons.trending_up, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildPopulationChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(15),
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
            'Pertumbuhan Penduduk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
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
                          '${value.toInt()}M',
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
                        const years = ['2018', '2019', '2020', '2021', '2022'];
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
                      const FlSpot(0, 264),
                      const FlSpot(1, 266),
                      const FlSpot(2, 267),
                      const FlSpot(3, 270),
                      const FlSpot(4, 272),
                    ],
                    isCurved: true,
                    color: const Color(0xFF1976D2),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1976D2).withOpacity(0.1),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, color: color, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPublications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rilis Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllPublicationsScreen(),
                  ),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                  ),
                )
              : recentPublications.isEmpty
                  ? _buildEmptyPublicationsState()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 0),
                      itemCount: recentPublications.length > 5
                          ? 5
                          : recentPublications.length,
                      itemBuilder: (context, index) {
                        return _buildPublicationCard(recentPublications[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPublicationCard(Publication publication) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15),
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
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(
                Icons.description,
                size: 40,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publication.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  publication.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${publication.publishDate.day}/${publication.publishDate.month}/${publication.publishDate.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPublicationsState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada publikasi',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadHomeData,
            child: const Text(
              'Muat Ulang',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfographicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Infografis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                        Color(0xFF90CAF9),
                      ],
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Perkembangan Ekonomi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Indonesia 2022',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
      ),
    );
  }
}
