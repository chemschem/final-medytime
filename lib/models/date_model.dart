
class date_model {
  final String? id_date;
  final String? day;  
  final int? start;
  final int? end;
  final int? limit;
  final DateTime? fullDate;
  final int? usersHaveBooked;
  final int? usersWaiting;
  String? description;

  date_model({
    this.id_date,
    this.day,
    this.start,
    this.end,
    this.limit,
    this.fullDate,
    this.usersHaveBooked,
    this.usersWaiting,
    this.description,
  });
  factory date_model.fromJson(Map<String, dynamic> json) {
    return date_model(
      id_date: json['id_date'],
      day: json['day'],
      start: json['start'],
      end: json['end'],
      limit: json['limit'],    
      fullDate: json['fullDate'],     
      usersHaveBooked: json['usersHaveBooked'],
      usersWaiting: json['usersWaiting'],
      description: json['description'],



      //no list------------------------------------------
      // user_booked: user_model.fromJson(json['user']),
      //json['person']
      // ليس نصًا أو رقمًا،
      // JSONبل هو كائن 
      // آخر، لذا لا يمكننا تخزينه مباشرةً.
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_date': id_date,
      'day': day,
      'start': start,
      'end': end,
      'limit': limit,
      'fullDate': fullDate,
      'usersHaveBooked': usersHaveBooked,
      'usersWaiting': usersWaiting,
      'description': description,
      // 'user': user_booked.toJson(),
    };
  }
}
