class TenagaKerjaData {
  String year;
  String angkatanKerja;
  double pengangguran;
  String pekerja;
  double tpak;
  ChangeData change;
  SectorsData sectors;
  double setengahPengangguran;
  ChangeTextData changeText;

  TenagaKerjaData({
    required this.year,
    required this.angkatanKerja,
    required this.pengangguran,
    required this.pekerja,
    required this.tpak,
    required this.change,
    required this.sectors,
    required this.setengahPengangguran,
    required this.changeText,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'angkatanKerja': angkatanKerja,
      'pengangguran': pengangguran,
      'pekerja': pekerja,
      'tpak': tpak,
      'change': change.toJson(),
      'sectors': sectors.toJson(),
      'setengahPengangguran': setengahPengangguran,
      'changeText': changeText.toJson(),
    };
  }

  factory TenagaKerjaData.fromJson(Map<String, dynamic> json) {
    return TenagaKerjaData(
      year: json['year'],
      angkatanKerja: json['angkatanKerja'],
      pengangguran: (json['pengangguran'] as num).toDouble(),
      pekerja: json['pekerja'],
      tpak: (json['tpak'] as num).toDouble(),
      change: ChangeData.fromJson(json['change']),
      sectors: SectorsData.fromJson(json['sectors']),
      setengahPengangguran: (json['setengahPengangguran'] as num).toDouble(),
      changeText: ChangeTextData.fromJson(json['changeText']),
    );
  }
}

class ChangeData {
  String angkatanKerja;
  String pengangguran;
  String pekerja;
  String tpak;

  ChangeData({
    required this.angkatanKerja,
    required this.pengangguran,
    required this.pekerja,
    required this.tpak,
  });

  Map<String, dynamic> toJson() {
    return {
      'angkatanKerja': angkatanKerja,
      'pengangguran': pengangguran,
      'pekerja': pekerja,
      'tpak': tpak,
    };
  }

  factory ChangeData.fromJson(Map<String, dynamic> json) {
    return ChangeData(
      angkatanKerja: json['angkatanKerja'],
      pengangguran: json['pengangguran'],
      pekerja: json['pekerja'],
      tpak: json['tpak'],
    );
  }
}

class SectorsData {
  double pertanian;
  double industri;
  double perdagangan;
  double jasa;

  SectorsData({
    required this.pertanian,
    required this.industri,
    required this.perdagangan,
    required this.jasa,
  });

  Map<String, dynamic> toJson() {
    return {
      'pertanian': pertanian,
      'industri': industri,
      'perdagangan': perdagangan,
      'jasa': jasa,
    };
  }

  factory SectorsData.fromJson(Map<String, dynamic> json) {
    return SectorsData(
      pertanian: (json['pertanian'] as num).toDouble(),
      industri: (json['industri'] as num).toDouble(),
      perdagangan: (json['perdagangan'] as num).toDouble(),
      jasa: (json['jasa'] as num).toDouble(),
    );
  }
}

class ChangeTextData {
  String tpak;
  String pengangguran;
  String setengahPengangguran;

  ChangeTextData({
    required this.tpak,
    required this.pengangguran,
    required this.setengahPengangguran,
  });

  Map<String, dynamic> toJson() {
    return {
      'tpak': tpak,
      'pengangguran': pengangguran,
      'setengahPengangguran': setengahPengangguran,
    };
  }

  factory ChangeTextData.fromJson(Map<String, dynamic> json) {
    return ChangeTextData(
      tpak: json['tpak'],
      pengangguran: json['pengangguran'],
      setengahPengangguran: json['setengahPengangguran'],
    );
  }
}