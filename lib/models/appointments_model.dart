// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:meditime/models/date_model.dart';
import 'package:meditime/models/user_model.dart';

class appointments_model {
date_model id_date;
user_model id_user;
final int? order;
bool? consultinDone;

  appointments_model({
    required this. id_date,
    required this.id_user,
    this.order,
    this.consultinDone,
  });

  factory appointments_model.fromJson(Map<String, dynamic> json) {
    return appointments_model(
       id_date: date_model.fromJson(json[' id_date']),
      id_user: user_model.fromJson(json['id_user']),
      order: json['order'],
      consultinDone: json['consultinDone'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      ' id_date':  id_date.toJson(),
      'id_user': id_user.toJson(),
      'order': order,
      'consultinDone': consultinDone,
    };
  }
}
