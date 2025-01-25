class AssessmentSetting {
  final int? idAssessmentSetting;
  final String yearAcademic;
  final String yearAssessment;
  final int idCoach;
  final int idAspectSub;
  final int bobot;

  AssessmentSetting({
    this.idAssessmentSetting,
    required this.yearAcademic,
    required this.yearAssessment,
    required this.idCoach,
    required this.idAspectSub,
    required this.bobot,
  });

  factory AssessmentSetting.fromJson(Map<String, dynamic> json) {
    return AssessmentSetting(
      idAssessmentSetting: json['id_assessment_setting'],
      yearAcademic: json['year_academic'] ?? '',
      yearAssessment: json['year_assessment'] ?? '',
      idCoach: json['id_coach'] ?? 0,
      idAspectSub: json['id_aspect_sub'] ?? 0,
      bobot: json['bobot'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_assessment_setting': idAssessmentSetting,
    'year_academic': yearAcademic,
    'year_assessment': yearAssessment,
    'id_coach': idCoach,
    'id_aspect_sub': idAspectSub,
    'bobot': bobot,
  };
} 