import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tenaga_kerja_data.dart';

class TenagaKerjaService {
  static const String _storageKey = 'tenaga_kerja_data';

  // Singleton pattern
  static final TenagaKerjaService _instance = TenagaKerjaService._internal();
  factory TenagaKerjaService() => _instance;
  TenagaKerjaService._internal();

  // Get all data
  Future<Map<String, TenagaKerjaData>> getAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        final defaultData = _getDefaultData();
        await saveAllData(defaultData);
        return defaultData;
      }

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final Map<String, TenagaKerjaData> result = {};

      jsonMap.forEach((key, value) {
        result[key] = TenagaKerjaData.fromJson(value);
      });

      return result;
    } catch (e) {
      print('Error loading tenaga kerja data: $e');
      return _getDefaultData();
    }
  }

  // Save all data
  Future<bool> saveAllData(Map<String, TenagaKerjaData> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> jsonMap = {};

      data.forEach((key, value) {
        jsonMap[key] = value.toJson();
      });

      final String jsonString = json.encode(jsonMap);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving tenaga kerja data: $e');
      return false;
    }
  }

  // Add new year data
  Future<bool> addYearData(TenagaKerjaData data) async {
    try {
      final allData = await getAllData();

      if (allData.containsKey(data.year)) {
        print('Year ${data.year} already exists');
        return false;
      }

      allData[data.year] = data;
      return await saveAllData(allData);
    } catch (e) {
      print('Error adding year data: $e');
      return false;
    }
  }

  // Update year data
  Future<bool> updateYearData(String year, TenagaKerjaData data) async {
    try {
      final allData = await getAllData();

      if (!allData.containsKey(year)) {
        print('Year $year not found');
        return false;
      }

      if (year != data.year) {
        allData.remove(year);
      }

      allData[data.year] = data;
      return await saveAllData(allData);
    } catch (e) {
      print('Error updating year data: $e');
      return false;
    }
  }

  // Delete year data
  Future<bool> deleteYearData(String year) async {
    try {
      final allData = await getAllData();

      if (!allData.containsKey(year)) {
        print('Year $year not found');
        return false;
      }

      allData.remove(year);
      return await saveAllData(allData);
    } catch (e) {
      print('Error deleting year data: $e');
      return false;
    }
  }

  // Get data by year
  Future<TenagaKerjaData?> getDataByYear(String year) async {
    try {
      final allData = await getAllData();
      return allData[year];
    } catch (e) {
      print('Error getting data by year: $e');
      return null;
    }
  }

  // Get available years
  Future<List<String>> getAvailableYears() async {
    try {
      final allData = await getAllData();
      final years = allData.keys.toList();
      years.sort((a, b) => b.compareTo(a)); // Sort descending
      return years;
    } catch (e) {
      print('Error getting available years: $e');
      return [];
    }
  }

  // Check if year exists
  Future<bool> yearExists(String year) async {
    try {
      final allData = await getAllData();
      return allData.containsKey(year);
    } catch (e) {
      print('Error checking year exists: $e');
      return false;
    }
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  // Reset to default data
  Future<bool> resetToDefault() async {
    try {
      final defaultData = _getDefaultData();
      return await saveAllData(defaultData);
    } catch (e) {
      print('Error resetting to default: $e');
      return false;
    }
  }

  // Default data (2020-2024)
  Map<String, TenagaKerjaData> _getDefaultData() {
    return {
      '2020': TenagaKerjaData(
        year: '2020',
        angkatanKerja: '138.22 Juta',
        pengangguran: 7.07,
        pekerja: '128.45 Juta',
        tpak: 67.77,
        change: ChangeData(
          angkatanKerja: '+0.5%',
          pengangguran: '+1.79%',
          pekerja: '-1.2%',
          tpak: '+0.12%',
        ),
        sectors: SectorsData(
          pertanian: 28.0,
          industri: 21.0,
          perdagangan: 24.0,
          jasa: 27.0,
        ),
        setengahPengangguran: 8.45,
        changeText: ChangeTextData(
          tpak: 'Perubahan +0.12% dari tahun sebelumnya',
          pengangguran: 'Perubahan +1.79% dari tahun sebelumnya',
          setengahPengangguran: 'Meningkat dari tahun sebelumnya',
        ),
      ),
      '2021': TenagaKerjaData(
        year: '2021',
        angkatanKerja: '140.15 Juta',
        pengangguran: 6.49,
        pekerja: '131.05 Juta',
        tpak: 68.02,
        change: ChangeData(
          angkatanKerja: '+1.4%',
          pengangguran: '-0.58%',
          pekerja: '+2.0%',
          tpak: '+0.25%',
        ),
        sectors: SectorsData(
          pertanian: 29.0,
          industri: 21.5,
          perdagangan: 24.5,
          jasa: 25.0,
        ),
        setengahPengangguran: 8.15,
        changeText: ChangeTextData(
          tpak: 'Perubahan +0.25% dari tahun sebelumnya',
          pengangguran: 'Perubahan -0.58% dari tahun sebelumnya',
          setengahPengangguran: 'Menurun dari tahun sebelumnya',
        ),
      ),
      '2022': TenagaKerjaData(
        year: '2022',
        angkatanKerja: '142.33 Juta',
        pengangguran: 5.86,
        pekerja: '133.94 Juta',
        tpak: 68.42,
        change: ChangeData(
          angkatanKerja: '+1.6%',
          pengangguran: '-0.63%',
          pekerja: '+2.2%',
          tpak: '+0.40%',
        ),
        sectors: SectorsData(
          pertanian: 29.5,
          industri: 22.0,
          perdagangan: 25.0,
          jasa: 23.5,
        ),
        setengahPengangguran: 7.87,
        changeText: ChangeTextData(
          tpak: 'Perubahan +0.40% dari tahun sebelumnya',
          pengangguran: 'Perubahan -0.63% dari tahun sebelumnya',
          setengahPengangguran: 'Menurun dari tahun sebelumnya',
        ),
      ),
      '2023': TenagaKerjaData(
        year: '2023',
        angkatanKerja: '143.72 Juta',
        pengangguran: 5.32,
        pekerja: '136.01 Juta',
        tpak: 68.77,
        change: ChangeData(
          angkatanKerja: '+0.98%',
          pengangguran: '-0.54%',
          pekerja: '+1.5%',
          tpak: '+0.35%',
        ),
        sectors: SectorsData(
          pertanian: 30.0,
          industri: 22.0,
          perdagangan: 25.0,
          jasa: 23.0,
        ),
        setengahPengangguran: 7.64,
        changeText: ChangeTextData(
          tpak: 'Perubahan +0.35% dari tahun sebelumnya',
          pengangguran: 'Perubahan -0.54% dari tahun sebelumnya',
          setengahPengangguran: 'Menurun dari tahun sebelumnya',
        ),
      ),
      '2024': TenagaKerjaData(
        year: '2024',
        angkatanKerja: '144.01 Juta',
        pengangguran: 4.82,
        pekerja: '137.05 Juta',
        tpak: 68.87,
        change: ChangeData(
          angkatanKerja: '+0.2%',
          pengangguran: '-0.50%',
          pekerja: '+0.76%',
          tpak: '+0.10%',
        ),
        sectors: SectorsData(
          pertanian: 29.0,
          industri: 23.0,
          perdagangan: 26.0,
          jasa: 22.0,
        ),
        setengahPengangguran: 7.35,
        changeText: ChangeTextData(
          tpak: 'Perubahan +0.10% dari tahun sebelumnya',
          pengangguran: 'Perubahan -0.50% dari tahun sebelumnya',
          setengahPengangguran: 'Menurun dari tahun sebelumnya',
        ),
      ),
    };
  }

  // Export to JSON
  Future<String> exportToJson() async {
    try {
      final allData = await getAllData();
      final Map<String, dynamic> jsonMap = {};

      allData.forEach((key, value) {
        jsonMap[key] = value.toJson();
      });

      return json.encode(jsonMap);
    } catch (e) {
      print('Error exporting to JSON: $e');
      return '';
    }
  }

  // Import from JSON
  Future<bool> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final Map<String, TenagaKerjaData> data = {};

      jsonMap.forEach((key, value) {
        data[key] = TenagaKerjaData.fromJson(value);
      });

      return await saveAllData(data);
    } catch (e) {
      print('Error importing from JSON: $e');
      return false;
    }
  }

  // Get statistics summary
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final allData = await getAllData();

      if (allData.isEmpty) {
        return {
          'totalYears': 0,
          'latestYear': '',
          'latestUnemployment': 0.0,
          'latestTPAK': 0.0,
        };
      }

      final years = allData.keys.toList();
      years.sort((a, b) => b.compareTo(a));

      final latestData = allData[years.first]!;

      return {
        'totalYears': allData.length,
        'latestYear': years.first,
        'latestUnemployment': latestData.pengangguran,
        'latestTPAK': latestData.tpak,
        'angkatanKerja': latestData.angkatanKerja,
        'pekerja': latestData.pekerja,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }
}