import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SDGSStatisticsPage extends StatefulWidget {
  const SDGSStatisticsPage({Key? key}) : super(key: key);

  @override
  State<SDGSStatisticsPage> createState() => _SDGSStatisticsPageState();
}

class _SDGSStatisticsPageState extends State<SDGSStatisticsPage> {
  int selectedYear = 2024;
  final List<int> years = [2020, 2021, 2022, 2023, 2024];

  // Data SDGs berdasarkan tahun
  Map<int, List<SDGSData>> sdgsDataByYear = {
    2020: [
      SDGSData('Kemiskinan', 9.78, Colors.red),
      SDGSData('Kelaparan', 7.4, Colors.orange),
      SDGSData('Kesehatan', 71.2, Colors.green),
      SDGSData('Pendidikan', 68.5, Colors.blue),
      SDGSData('Gender', 70.2, Colors.purple),
      SDGSData('Air Bersih', 72.8, Colors.cyan),
    ],
    2021: [
      SDGSData('Kemiskinan', 9.71, Colors.red),
      SDGSData('Kelaparan', 7.1, Colors.orange),
      SDGSData('Kesehatan', 72.5, Colors.green),
      SDGSData('Pendidikan', 70.1, Colors.blue),
      SDGSData('Gender', 71.5, Colors.purple),
      SDGSData('Air Bersih', 74.2, Colors.cyan),
    ],
    2022: [
      SDGSData('Kemiskinan', 9.54, Colors.red),
      SDGSData('Kelaparan', 6.8, Colors.orange),
      SDGSData('Kesehatan', 73.8, Colors.green),
      SDGSData('Pendidikan', 72.3, Colors.blue),
      SDGSData('Gender', 72.8, Colors.purple),
      SDGSData('Air Bersih', 75.6, Colors.cyan),
    ],
    2023: [
      SDGSData('Kemiskinan', 9.36, Colors.red),
      SDGSData('Kelaparan', 6.5, Colors.orange),
      SDGSData('Kesehatan', 75.1, Colors.green),
      SDGSData('Pendidikan', 74.5, Colors.blue),
      SDGSData('Gender', 74.1, Colors.purple),
      SDGSData('Air Bersih', 77.0, Colors.cyan),
    ],
    2024: [
      SDGSData('Kemiskinan', 9.03, Colors.red),
      SDGSData('Kelaparan', 6.2, Colors.orange),
      SDGSData('Kesehatan', 76.4, Colors.green),
      SDGSData('Pendidikan', 76.2, Colors.blue),
      SDGSData('Gender', 75.5, Colors.purple),
      SDGSData('Air Bersih', 78.4, Colors.cyan),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 58, 183, 58),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SDGs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Year Filter Section (sama seperti Kemiskinan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildYearSelector(),
            ),

            const SizedBox(height: 20),

            // Main Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Indikator SDGs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 58, 183, 58).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedYear.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 58, 183, 58),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) =>
                                  Colors.black87,
                              tooltipRoundedRadius: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${sdgsDataByYear[selectedYear]![groupIndex].name}\n${rod.toY.toStringAsFixed(2)}%',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final data = sdgsDataByYear[selectedYear]!;
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < data.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        data[value.toInt()]
                                            .name
                                            .substring(0, 3),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF8E92A4),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8E92A4),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.1),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: sdgsDataByYear[selectedYear]!
                              .asMap()
                              .entries
                              .map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.value,
                                  gradient: LinearGradient(
                                    colors: [
                                      entry.value.color,
                                      entry.value.color.withOpacity(0.6),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 24,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Indikator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...sdgsDataByYear[selectedYear]!.map((data) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: data.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForIndicator(data.name),
                              color: data.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Indikator SDGs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${data.value.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: data.color,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTrendColor(data.name)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getTrendIcon(data.name),
                                      size: 12,
                                      color: _getTrendColor(data.name),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${_getTrendValue(data.name)}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getTrendColor(data.name),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIndicator(String name) {
    switch (name) {
      case 'Kemiskinan':
        return Icons.attach_money;
      case 'Kelaparan':
        return Icons.restaurant;
      case 'Kesehatan':
        return Icons.favorite;
      case 'Pendidikan':
        return Icons.school;
      case 'Gender':
        return Icons.people;
      case 'Air Bersih':
        return Icons.water_drop;
      default:
        return Icons.analytics;
    }
  }

  Color _getTrendColor(String name) {
    if (name == 'Kemiskinan' || name == 'Kelaparan') {
      return Colors.green;
    }
    return Colors.blue;
  }

  IconData _getTrendIcon(String name) {
    if (name == 'Kemiskinan' || name == 'Kelaparan') {
      return Icons.trending_down;
    }
    return Icons.trending_up;
  }

  String _getTrendValue(String name) {
    if (name == 'Kemiskinan') return '3.5';
    if (name == 'Kelaparan') return '2.8';
    if (name == 'Kesehatan') return '5.2';
    if (name == 'Pendidikan') return '7.7';
    if (name == 'Gender') return '5.3';
    if (name == 'Air Bersih') return '5.6';
    return '0.0';
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 58, 183, 58).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 58, 183, 58),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pilih Tahun Data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final selectedIndex = selectedYear - 2020;
              final gapWidth = 8.0;
              final totalGaps = 4 * gapWidth;
              final itemWidth = (constraints.maxWidth - totalGaps) / 5;
              final indicatorLeft = selectedIndex * (itemWidth + gapWidth);
              
              return Stack(
                children: [
                  // Background gray for all buttons
                  Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Animated green indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    left: indicatorLeft,
                    top: 0,
                    child: Container(
                      width: itemWidth,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color.fromARGB(255, 58, 183, 58), Color.fromARGB(255, 76, 200, 76)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 58, 183, 58).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Year text buttons
                  Row(
                    children: List.generate(5, (index) {
                      final year = 2020 + index;
                      final isSelected = year == selectedYear;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedYear = year;
                              });
                            },
                            child: Container(
                              height: 36,
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black54,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 12,
                                ),
                                child: Text(year.toString()),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SDGSData {
  final String name;
  final double value;
  final Color color;

  SDGSData(this.name, this.value, this.color);
}