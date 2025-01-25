class Coach {
  final int? idCoach;
  final String? nameCoach;
  final String? coachDepartment;
  final String? yearsCoach;
  final String? email;
  final String? nohp;
  final int? statusCoach;
  final String? license;
  final String? experience;
  final String? achievements;
  final String? photo;
  
  Coach({
    this.idCoach,
    this.nameCoach,
    this.coachDepartment,
    this.yearsCoach,
    this.email,
    this.nohp,
    this.statusCoach,
    this.license,
    this.experience,
    this.achievements,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_coach': idCoach,
      'name_coach': nameCoach,
      'coach_department': coachDepartment,
      'years_coach': yearsCoach,
      'email': email,
      'nohp': nohp,
      'status_coach': statusCoach,
      'license': license,
      'experience': experience,
      'achievements': achievements,
      'photo': photo,
    };
  }

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      idCoach: json['id_coach'],
      nameCoach: json['name_coach'],
      coachDepartment: json['coach_department'],
      yearsCoach: json['years_coach'],
      email: json['email'],
      nohp: json['nohp'],
      statusCoach: json['status_coach'],
      license: json['license'],
      experience: json['experience'],
      achievements: json['achievements'],
      photo: json['photo'],
    );
  }
} 