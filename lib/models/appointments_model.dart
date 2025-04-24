// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:meditime/models/date_model.dart';
import 'package:meditime/models/user_model.dart';

class appointments_model {
date_model id_date;
user_model id_user;
final int? order;
bool? consultinDdone;

  appointments_model({
    required this. id_date,
    required this.id_user,
    this.order,
    this.consultinDdone,
  });

  factory appointments_model.fromJson(Map<String, dynamic> json) {
    return appointments_model(
       id_date: date_model.fromJson(json[' id_date']),
      id_user: user_model.fromJson(json['id_user']),
      order: json['order'],
      consultinDdone: json['consultinDdone'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      ' id_date':  id_date.toJson(),
      'id_user': id_user.toJson(),
      'order': order,
      'consultinDdone': consultinDdone,
    };
  }
}
