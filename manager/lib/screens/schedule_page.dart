// Import statements untuk library yang dibutuhkan
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Widget utama halaman jadwal
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

// State untuk halaman jadwal
class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  // Variabel state
  late List<Map<String, dynamic>> _events = [];
  String _selectedFilter = 'Semua';
  late AnimationController _animationController;
  bool _isLoading = false;
  bool _isCalendarView = false;

  // Controller untuk input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _waktuBermainController = TextEditingController();
  final TextEditingController _namaLapanganController = TextEditingController();
  final TextEditingController _namaPertandinganController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  // Metode lifecycle
  @override
  void initState() {
    super.initState();
    _setupInitialState();
  }

  // Fungsi untuk setup state awal
  void _setupInitialState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    initializeDateFormatting('id_ID', null).then((_) {
      _fetchSchedules();
    });
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Fungsi untuk dispose controller
  void _disposeControllers() {
    _animationController.dispose();
    _nameController.dispose();
    _waktuBermainController.dispose();
    _namaLapanganController.dispose();
    _namaPertandinganController.dispose();
    _dateController.dispose();
  }

  // Metode API
  // Fungsi untuk mengambil data jadwal
  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://hayy.my.id/api/schedule'));
      if (response.statusCode == 200) {
        _handleSuccessfulFetch(response);
      } else {
        _showErrorSnackBar('Gagal memuat jadwal');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan koneksi');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk menangani fetch data berhasil
  void _handleSuccessfulFetch(http.Response response) {
    setState(() {
      _events = List<Map<String, dynamic>>.from(json.decode(response.body));
      _events.sort((a, b) => DateTime.parse(a['date_schedule'].toString())
          .compareTo(DateTime.parse(b['date_schedule'].toString())));
    });
  }

  // Fungsi untuk menambah jadwal baru
  Future<void> _addEvent() async {
    try {
      final response = await http.post(
        Uri.parse('http://hayy.my.id/api/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_schedule': _nameController.text,
          'waktu_bermain': _waktuBermainController.text,
          'nama_lapangan': _namaLapanganController.text,
          'nama_pertandingan': _namaPertandinganController.text,
          'date_schedule': _dateController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessSnackBar('Jadwal berhasil ditambahkan');
        _fetchSchedules();
      } else {
        _showErrorSnackBar('Gagal menambahkan jadwal');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan koneksi');
    }
  }

  // Fungsi untuk update jadwal
  Future<void> _updateEvent(int id) async {
    try {
      final response = await http.put(
        Uri.parse('http://hayy.my.id/api/schedule/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_schedule': _nameController.text,
          'waktu_bermain': _waktuBermainController.text,
          'nama_lapangan': _namaLapanganController.text,
          'nama_pertandingan': _namaPertandinganController.text,
          'date_schedule': _dateController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Jadwal berhasil diperbarui');
        _fetchSchedules();
      } else {
        _showErrorSnackBar('Gagal memperbarui jadwal');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan koneksi');
    }
  }

  // Fungsi untuk menghapus jadwal
  Future<void> _deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://hayy.my.id/api/schedule/$id'),
      );
      if (response.statusCode == 200) {
        _handleSuccessfulDelete(id);
      } else {
        _showErrorSnackBar('Gagal menghapus jadwal');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan koneksi');
    }
  }

  // Fungsi untuk menangani penghapusan berhasil
  void _handleSuccessfulDelete(int id) {
    setState(() {
      _events.removeWhere((event) => event['id_schedule'] == id);
    });
    _showSuccessSnackBar('Jadwal berhasil dihapus');
  }

  // Metode Dialog
  // Fungsi untuk menampilkan dialog tambah jadwal
  Future<void> _showAddEventDialog() async {
    _clearControllers();
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.green[700], size: 30),
                  const SizedBox(width: 10),
                  const Text(
                    'Tambah Jadwal Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildEventForm(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    label: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _addEvent();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog edit jadwal
  Future<void> _showEditEventDialog(Map<String, dynamic> event) async {
    _populateControllers(event);
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_calendar, color: Colors.blue[700], size: 30),
                  const SizedBox(width: 10),
                  const Text(
                    'Edit Jadwal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildEventForm(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    label: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _updateEvent(event['id_schedule']);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.update),
                    label: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membangun form event
  Widget _buildEventForm() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormField(
              controller: _nameController,
              label: 'Nama Jadwal',
              icon: Icons.event_note,
              hint: 'Masukkan nama jadwal',
            ),
            const SizedBox(height: 15),
            _buildFormField(
              controller: _waktuBermainController,
              label: 'Waktu Bermain',
              icon: Icons.access_time,
              hint: 'Contoh: 15:00 - 17:00',
            ),
            const SizedBox(height: 15),
            _buildFormField(
              controller: _namaLapanganController,
              label: 'Nama Lapangan',
              icon: Icons.location_on,
              hint: 'Masukkan nama lapangan',
            ),
            const SizedBox(height: 15),
            _buildFormField(
              controller: _namaPertandinganController,
              label: 'Nama Pertandingan',
              icon: Icons.sports_soccer,
              hint: 'Masukkan nama pertandingan',
            ),
            const SizedBox(height: 15),
            _buildDateField(),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun field form
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.green[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  // Fungsi untuk membangun field tanggal
  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Tanggal',
        hintText: 'Pilih tanggal',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.green[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.green[700]!,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      style: const TextStyle(fontSize: 16),
    );
  }

  // Metode Helper UI
  // Fungsi untuk membersihkan controller
  void _clearControllers() {
    _nameController.clear();
    _waktuBermainController.clear();
    _namaLapanganController.clear();
    _namaPertandinganController.clear();
    _dateController.clear();
    _selectedDate = null;
  }

  // Fungsi untuk mengisi controller dengan data event
  void _populateControllers(Map<String, dynamic> event) {
    _nameController.text = event['name_schedule'].toString();
    _waktuBermainController.text = event['waktu_bermain'].toString();
    _namaLapanganController.text = event['nama_lapangan'].toString();
    _namaPertandinganController.text = event['nama_pertandingan'].toString();
    _dateController.text = event['date_schedule'].toString();
    _selectedDate = DateTime.parse(event['date_schedule'].toString());
  }

  // Metode Snackbar
  // Fungsi untuk menampilkan snackbar error
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(message, Colors.red[700]!, Icons.error_outline),
      );
    }
  }

  // Fungsi untuk menampilkan snackbar sukses
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(message, Colors.green[700]!, Icons.check_circle_outline),
      );
    }
  }

  // Fungsi untuk membangun snackbar
  SnackBar _buildSnackBar(String message, Color color, IconData icon) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      duration: const Duration(seconds: 3),
    );
  }

  // Metode Filter
  // Fungsi untuk mendapatkan event yang difilter
  List<Map<String, dynamic>> _getFilteredEvents() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    switch (_selectedFilter) {
      case 'Hari Ini':
        return _filterTodayEvents(now);
      case 'Minggu Ini':
        return _filterWeekEvents(startOfWeek, endOfWeek);
      default:
        return _events;
    }
  }

  // Fungsi untuk memfilter event hari ini
  List<Map<String, dynamic>> _filterTodayEvents(DateTime now) {
    return _events.where((event) {
      final eventDate = DateTime.parse(event['date_schedule'].toString());
      return eventDate.year == now.year &&
          eventDate.month == now.month &&
          eventDate.day == now.day;
    }).toList();
  }

  // Fungsi untuk memfilter event minggu ini
  List<Map<String, dynamic>> _filterWeekEvents(DateTime start, DateTime end) {
    return _events.where((event) {
      final eventDate = DateTime.parse(event['date_schedule'].toString());
      return eventDate.isAfter(start.subtract(const Duration(days: 1))) &&
          eventDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Metode Membangun View
  // Fungsi untuk membangun tampilan kalender
  Widget _buildCalendarView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.multi,
          selectedDayHighlightColor: Colors.green[700],
          weekdayLabels: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'],
          weekdayLabelTextStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          firstDayOfWeek: 1,
          controlsHeight: 50,
          controlsTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          dayTextStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          disabledDayTextStyle: TextStyle(
            color: Colors.grey[400],
          ),
          selectedDayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: _events
            .map((e) => DateTime.parse(e['date_schedule'].toString()))
            .toList(),
        onValueChanged: (dates) {},
      ),
    );
  }

  // Fungsi untuk membangun tampilan list
  Widget _buildListView() {
    final filteredEvents = _getFilteredEvents();

    if (filteredEvents.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) =>
            _buildAnimatedListItem(filteredEvents[index], index),
      ),
    );
  }

  // Fungsi untuk membangun tampilan kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada jadwal pertandingan',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan jadwal baru dengan tombol di bawah',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun item list yang dianimasi
  Widget _buildAnimatedListItem(Map<String, dynamic> event, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: _buildEventCard(event),
        ),
      ),
    );
  }

  // Fungsi untuk membangun kartu event
  Widget _buildEventCard(Map<String, dynamic> event) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(
        DateFormat('yyyy-MM-dd').parse(event['date_schedule'].toString()));

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _showEditEventDialog(event),
            backgroundColor: Colors.blue[600]!,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (context) => _confirmDelete(event['id_schedule']),
            backgroundColor: Colors.red[600]!,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: _buildCardContent(event, formattedDate),
    );
  }

  // Fungsi untuk membangun konten kartu
  Widget _buildCardContent(Map<String, dynamic> event, String formattedDate) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildExpandableTile(event, formattedDate),
      ),
    );
  }

  // Fungsi untuk membangun tile yang dapat diperluas
  Widget _buildExpandableTile(
      Map<String, dynamic> event, String formattedDate) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          event['name_schedule'].toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _buildEventTag(event['nama_pertandingan'].toString()),
        children: [_buildEventDetails(event)],
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // Fungsi untuk membangun tag event
  Widget _buildEventTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Fungsi untuk membangun detail event
  Widget _buildEventDetails(Map<String, dynamic> event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          Icons.access_time,
          'Waktu Bermain',
          event['waktu_bermain'].toString(),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          Icons.location_on,
          'Lokasi',
          event['nama_lapangan'].toString(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showEditEventDialog(event),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _confirmDelete(event['id_schedule']),
              icon: const Icon(Icons.delete, size: 20),
              label: const Text('Hapus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Fungsi untuk membangun baris detail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.green[700]),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Fungsi untuk menampilkan statistik jadwal
  Widget _buildScheduleStatistics() {
    int totalJadwal = _events.length;
    int jadwalHariIni = _events.where((event) {
      DateTime eventDate = DateTime.parse(event['date_schedule'].toString());
      DateTime now = DateTime.now();
      return eventDate.year == now.year &&
          eventDate.month == now.month &&
          eventDate.day == now.day;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Jadwal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatisticItem(
                'Total Jadwal',
                totalJadwal.toString(),
                Icons.calendar_month,
              ),
              _buildStatisticItem(
                'Jadwal Hari Ini',
                jadwalHariIni.toString(),
                Icons.today,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget item statistik
  Widget _buildStatisticItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Fungsi untuk ekspor jadwal ke PDF
  Future<void> _exportToPDF() async {
    try {
      // Implementasi ekspor PDF akan ditambahkan di sini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur ekspor PDF akan segera hadir!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Gagal mengekspor jadwal');
    }
  }

  // Fungsi untuk berbagi jadwal
  void _shareSchedule() {
    // Implementasi berbagi jadwal akan ditambahkan di sini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur berbagi jadwal akan segera hadir!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Fungsi untuk konfirmasi penghapusan
  // Fungsi untuk menampilkan dialog konfirmasi penghapusan jadwal
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 28),
            const SizedBox(width: 10),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: const Text(
          'Yakin ingin menghapus jadwal ini?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.grey[600]),
            label: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _deleteEvent(id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun tampilan utama aplikasi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Fungsi untuk membangun app bar aplikasi
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Jadwal Pertandingan',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.green[700],
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isCalendarView ? Icons.list : Icons.calendar_month,
            size: 28,
          ),
          onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
        ),
        IconButton(
          icon: const Icon(
            Icons.filter_list,
            size: 28,
          ),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  // Fungsi untuk membangun body utama aplikasi
  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[700]!, Colors.green[50]!],
        ),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            )
          : _isCalendarView
              ? _buildCalendarView()
              : _buildListView(),
    );
  }

  // Fungsi untuk membangun tombol floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddEventDialog,
      backgroundColor: Colors.green[700],
      elevation: 8,
      icon: const Icon(Icons.add, size: 24),
      label: const Text(
        'Tambah Jadwal',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan bottom sheet filter
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  // Fungsi untuk membangun tampilan bottom sheet filter
  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Filter Jadwal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ..._buildFilterOptions(),
        ],
      ),
    );
  }

  // Fungsi untuk membangun opsi-opsi filter
  List<Widget> _buildFilterOptions() {
    return ['Semua', 'Hari Ini', 'Minggu Ini']
        .map(
          (filter) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _selectedFilter == filter
                  ? Colors.green[50]
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                filter,
                style: TextStyle(
                  fontWeight: _selectedFilter == filter
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              leading: Radio(
                value: filter,
                groupValue: _selectedFilter,
                activeColor: Colors.green[700],
                onChanged: (value) {
                  setState(() => _selectedFilter = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        )
        .toList();
  }
}
