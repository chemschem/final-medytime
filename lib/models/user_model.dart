class user_model {
  final String? id_user;
  final String? name;
  final String? email;
  final String? password;
  final String? age;
  final int? phone;
  
  user_model({
    this.id_user,
    this.name,
    this.email,
    this.password,
    this.age,
    this.phone,
  });
  factory user_model.fromJson(Map<String, dynamic> json) {
    return user_model(
      id_user: json['id_user'],
      name: json['name'],
      age: json['age'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_user': id_user,
      'name': name,
      'age': age,
      'email': email,
      'password': password,
      'phone': phone,

    };
  }
}
