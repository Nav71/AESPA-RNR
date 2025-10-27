import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tenaga_kerja_data.dart';
import 'tenaga_kerja_service.dart';

class AddEditTenagaKerjaScreen extends StatefulWidget {
  final TenagaKerjaData? editData;
  final String? editYear;

  const AddEditTenagaKerjaScreen({
    Key? key,
    this.editData,
    this.editYear,
  }) : super(key: key);

  @override
  State<AddEditTenagaKerjaScreen> createState() =>
      _AddEditTenagaKerjaScreenState();
}

class _AddEditTenagaKerjaScreenState extends State<AddEditTenagaKerjaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TenagaKerjaService _service = TenagaKerjaService();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _yearController;
  late TextEditingController _angkatanKerjaController;
  late TextEditingController _pengangguranController;
  late TextEditingController _pekerjaController;
  late TextEditingController _tpakController;

  // Change controllers
  late TextEditingController _changeAngkatanKerjaController;
  late TextEditingController _changePengangguranController;
  late TextEditingController _changePekerjaController;
  late TextEditingController _changeTPAKController;

  // Sectors controllers
  late TextEditingController _pertanianController;
  late TextEditingController _industriController;
  late TextEditingController _perdaganganController;
  late TextEditingController _jasaController;

  // Others
  late TextEditingController _setengahPengangguranController;
  late TextEditingController _changeTextTPAKController;
  late TextEditingController _changeTextPengangguranController;
  late TextEditingController _changeTextSetengahController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.editData;

    _yearController = TextEditingController(text: data?.year ?? '');
    _angkatanKerjaController =
        TextEditingController(text: data?.angkatanKerja ?? '');
    _pengangguranController =
        TextEditingController(text: data?.pengangguran.toString() ?? '');
    _pekerjaController = TextEditingController(text: data?.pekerja ?? '');
    _tpakController = TextEditingController(text: data?.tpak.toString() ?? '');

    _changeAngkatanKerjaController =
        TextEditingController(text: data?.change.angkatanKerja ?? '');
    _changePengangguranController =
        TextEditingController(text: data?.change.pengangguran ?? '');
    _changePekerjaController =
        TextEditingController(text: data?.change.pekerja ?? '');
    _changeTPAKController =
        TextEditingController(text: data?.change.tpak ?? '');

    _pertanianController =
        TextEditingController(text: data?.sectors.pertanian.toString() ?? '');
    _industriController =
        TextEditingController(text: data?.sectors.industri.toString() ?? '');
    _perdaganganController =
        TextEditingController(text: data?.sectors.perdagangan.toString() ?? '');
    _jasaController =
        TextEditingController(text: data?.sectors.jasa.toString() ?? '');

    _setengahPengangguranController = TextEditingController(
        text: data?.setengahPengangguran.toString() ?? '');
    _changeTextTPAKController =
        TextEditingController(text: data?.changeText.tpak ?? '');
    _changeTextPengangguranController =
        TextEditingController(text: data?.changeText.pengangguran ?? '');
    _changeTextSetengahController = TextEditingController(
        text: data?.changeText.setengahPengangguran ?? '');
  }

  @override
  void dispose() {
    _yearController.dispose();
    _angkatanKerjaController.dispose();
    _pengangguranController.dispose();
    _pekerjaController.dispose();
    _tpakController.dispose();
    _changeAngkatanKerjaController.dispose();
    _changePengangguranController.dispose();
    _changePekerjaController.dispose();
    _changeTPAKController.dispose();
    _pertanianController.dispose();
    _industriController.dispose();
    _perdaganganController.dispose();
    _jasaController.dispose();
    _setengahPengangguranController.dispose();
    _changeTextTPAKController.dispose();
    _changeTextPengangguranController.dispose();
    _changeTextSetengahController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tenagaKerjaData = TenagaKerjaData(
        year: _yearController.text,
        angkatanKerja: _angkatanKerjaController.text,
        pengangguran: double.parse(_pengangguranController.text),
        pekerja: _pekerjaController.text,
        tpak: double.parse(_tpakController.text),
        change: ChangeData(
          angkatanKerja: _changeAngkatanKerjaController.text,
          pengangguran: _changePengangguranController.text,
          pekerja: _changePekerjaController.text,
          tpak: _changeTPAKController.text,
        ),
        sectors: SectorsData(
          pertanian: double.parse(_pertanianController.text),
          industri: double.parse(_industriController.text),
          perdagangan: double.parse(_perdaganganController.text),
          jasa: double.parse(_jasaController.text),
        ),
        setengahPengangguran:
            double.parse(_setengahPengangguranController.text),
        changeText: ChangeTextData(
          tpak: _changeTextTPAKController.text,
          pengangguran: _changeTextPengangguranController.text,
          setengahPengangguran: _changeTextSetengahController.text,
        ),
      );

      bool success;
      if (widget.editYear != null) {
        success =
            await _service.updateYearData(widget.editYear!, tenagaKerjaData);
      } else {
        success = await _service.addYearData(tenagaKerjaData);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(widget.editYear != null
                      ? 'Data berhasil diperbarui'
                      : 'Data berhasil ditambahkan'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: Text(
          widget.editYear != null
              ? 'Edit Data Tahun ${widget.editYear}'
              : 'Tambah Data Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDataUtamaSection(),
            const SizedBox(height: 16),
            _buildPerubahanSection(),
            const SizedBox(height: 16),
            _buildSektorSection(),
            const SizedBox(height: 16),
            _buildAnalisisSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUtamaSection() {
    return _buildSection(
      title: 'Data Utama',
      icon: Icons.info_outline,
      color: const Color(0xFF7C4DFF),
      children: [
        _buildTextField(
          controller: _yearController,
          label: 'Tahun',
          hint: '2024',
          enabled: widget.editYear == null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _angkatanKerjaController,
          label: 'Angkatan Kerja (contoh: 144.01 Juta)',
          hint: '144.01 Juta',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _pengangguranController,
          label: 'Tingkat Pengangguran (%)',
          hint: '4.82',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _pekerjaController,
          label: 'Jumlah Pekerja (contoh: 137.05 Juta)',
          hint: '137.05 Juta',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _tpakController,
          label: 'TPAK (%)',
          hint: '68.87',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _setengahPengangguranController,
          label: 'Setengah Pengangguran (%)',
          hint: '7.35',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPerubahanSection() {
    return _buildSection(
      title: 'Perubahan Year-over-Year',
      icon: Icons.trending_up,
      color: Colors.orange,
      children: [
        _buildTextField(
          controller: _changeAngkatanKerjaController,
          label: 'Perubahan Angkatan Kerja (contoh: +0.2%)',
          hint: '+0.2%',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _changePengangguranController,
          label: 'Perubahan Pengangguran (contoh: -0.50%)',
          hint: '-0.50%',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _changePekerjaController,
          label: 'Perubahan Pekerja (contoh: +0.76%)',
          hint: '+0.76%',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _changeTPAKController,
          label: 'Perubahan TPAK (contoh: +0.10%)',
          hint: '+0.10%',
        ),
      ],
    );
  }

  Widget _buildSektorSection() {
    return _buildSection(
      title: 'Distribusi Sektor (%)',
      icon: Icons.pie_chart,
      color: Colors.blue,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _pertanianController,
                label: 'Pertanian',
                hint: '29.0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _industriController,
                label: 'Industri',
                hint: '23.0',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _perdaganganController,
                label: 'Perdagangan',
                hint: '26.0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _jasaController,
                label: 'Jasa',
                hint: '22.0',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalisisSection() {
    return _buildSection(
      title: 'Deskripsi Analisis',
      icon: Icons.analytics,
      color: Colors.green,
      children: [
        _buildTextField(
          controller: _changeTextTPAKController,
          label: 'Deskripsi Perubahan TPAK',
          hint: 'Perubahan +0.10% dari tahun sebelumnya',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _changeTextPengangguranController,
          label: 'Deskripsi Perubahan Pengangguran',
          hint: 'Perubahan -0.50% dari tahun sebelumnya',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _changeTextSetengahController,
          label: 'Deskripsi Setengah Pengangguran',
          hint: 'Menurun dari tahun sebelumnya',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save),
                  const SizedBox(width: 8),
                  Text(
                    widget.editYear != null ? 'Perbarui Data' : 'Simpan Data',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}