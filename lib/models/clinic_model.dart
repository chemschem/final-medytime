class clinic_model {
  final String? id_clinic;
  final String? name_clinic;
  final String? email_clinic;
  final String? addresse_clinic;
  final String? doctor_name;
  final String? doctor_des;
  final int? clinic_phone;
  
  clinic_model({
    this.id_clinic,
    this.name_clinic,
    this.email_clinic,
    this.addresse_clinic,
    this.doctor_name,
    this.clinic_phone,
    this.doctor_des,
  });
  factory clinic_model.fromJson(Map<String, dynamic> json) {
    return clinic_model(
      id_clinic: json['id_clinic'],
      name_clinic: json['name_clinic'],
      doctor_name: json['doctor_name'],
      email_clinic: json['email_clinic'],
      addresse_clinic: json['addresse_clinic'],
      clinic_phone: json['clinic_phone'],
      doctor_des: json['doctor_des'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_clinic': id_clinic,
      'name_clinic': name_clinic,
      'doctor_name': doctor_name,
      'email_clinic': email_clinic,
      'addresse_clinic': addresse_clinic,
      'clinic_phone': clinic_phone,
      'doctor_des': doctor_des,

    };
  }
}
