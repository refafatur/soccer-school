class Aspect {
  final int? idAspect;
  final String? nameAspect;
  final String? ketAspect;

  Aspect({
    this.idAspect,
    this.nameAspect,
    this.ketAspect,
  });

  factory Aspect.fromJson(Map<String, dynamic> json) {
    try {
      print('Processing aspect JSON: $json');
      return Aspect(
        idAspect: json['id_aspect'] is String 
            ? int.tryParse(json['id_aspect']) 
            : json['id_aspect'],
        nameAspect: json['name_aspect']?.toString(),
        ketAspect: json['ket_aspect']?.toString(),
      );
    } catch (e) {
      print('Error parsing Aspect: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id_aspect': idAspect,
    'name_aspect': nameAspect,
    'ket_aspect': ketAspect,
  };
}