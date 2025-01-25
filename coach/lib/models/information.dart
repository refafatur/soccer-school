class Information {
  final int? idInformation;
  final String nameInfo;
  final String info;
  final DateTime dateInfo;
  final int statusInfo;

  Information({
    this.idInformation,
    required this.nameInfo,
    required this.info,
    required this.dateInfo,
    required this.statusInfo,
  });

  Map<String, dynamic> toJson() => {
    'id_information': idInformation,
    'name_info': nameInfo,
    'info': info,
    'date_info': dateInfo.toIso8601String(),
    'status_info': statusInfo,
  };

  factory Information.fromJson(Map<String, dynamic> json) {
    return Information(
      idInformation: json['id_information'],
      nameInfo: json['name_info'] ?? '',
      info: json['info'] ?? '',
      dateInfo: DateTime.parse(json['date_info']),
      statusInfo: json['status_info'] ?? 0,
    );
  }
} 