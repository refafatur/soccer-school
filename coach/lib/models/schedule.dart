class Schedule {
  final int idSchedule;
  final String nameSchedule;
  final dynamic dateSchedule;
  final int statusSchedule;
  final int? waktuBermain;
  final String? namaLapangan;
  final String? namaPertandingan;

  Schedule({
    required this.idSchedule,
    required this.nameSchedule,
    required this.dateSchedule,
    required this.statusSchedule,
    this.waktuBermain,
    this.namaLapangan,
    this.namaPertandingan,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      idSchedule: json['id_schedule'] ?? 0,
      nameSchedule: json['name_schedule'] ?? '',
      dateSchedule: json['date_schedule'],
      statusSchedule: json['status_schedule'] ?? 0,
      waktuBermain: json['waktu_bermain'],
      namaLapangan: json['nama_lapangan'],
      namaPertandingan: json['nama_pertandingan'],
    );
  }
} 