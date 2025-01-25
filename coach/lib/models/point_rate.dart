class PointRate {
  final int? idPointRate;
  final int pointRate;
  final String rate;

  PointRate({
    this.idPointRate,
    required this.pointRate,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
    'id_point_rate': idPointRate,
    'point_rate': pointRate,
    'rate': rate,
  };

  factory PointRate.fromJson(Map<String, dynamic> json) {
    return PointRate(
      idPointRate: json['id_point_rate'],
      pointRate: json['point_rate'],
      rate: json['rate'] ?? '',
    );
  }
} 