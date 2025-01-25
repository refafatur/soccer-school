class AspectSub {
  final int idAspectSub;
  final int idAspect;
  final String nameAspectSub;
  final String ketAspectSub;

  AspectSub({
    required this.idAspectSub,
    required this.idAspect,
    required this.nameAspectSub,
    required this.ketAspectSub,
  });

  factory AspectSub.fromJson(Map<String, dynamic> json) {
    print('Processing AspectSub JSON: $json');
    return AspectSub(
      idAspectSub: int.tryParse(json['id_aspect_sub'].toString()) ?? 0,
      idAspect: int.tryParse(json['id_aspect'].toString()) ?? 0,
      nameAspectSub: json['name_aspect_sub']?.toString() ?? 'Tidak tersedia',
      ketAspectSub: json['ket_aspect_sub']?.toString() ?? 'Tidak tersedia',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_aspect_sub': idAspectSub,
    'id_aspect': idAspect,
    'name_aspect_sub': nameAspectSub,
    'ket_aspect_sub': ketAspectSub,
  };
} 