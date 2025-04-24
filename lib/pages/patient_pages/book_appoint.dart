import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_archiv.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class book_appoint extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  book_appoint({super.key});

  @override
  State<book_appoint> createState() => _book_appointState();
}

class _book_appointState extends State<book_appoint> {
  bool isOverLimit = false;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<String> myBookedDateIds = [];

  void updateBookingState(String dateId) async {
    List<bool> limits = await function_appoint().fetchBookingLimits(dateId);
    setState(() {
      isOverLimit = limits[0];
    });
  }

  List<QueryDocumentSnapshot> getAppointmentsForDay(
      DateTime day, List<QueryDocumentSnapshot> allDocs) {
    return allDocs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime date = (data['fullDate'] as Timestamp).toDate();
      return isSameDay(date, day);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchUserAppointments();
  }

  void fetchUserAppointments() async {
    var appointments = await function_appoint().fetchMyAppointments();
    setState(() {
      myBookedDateIds = appointments.map((a) => a['id_date'] as String).toList();
      focusedDay = DateTime.now(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book an Appointment'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: function_date().getdate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Appointments Found'));
          }
          var appointments = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (_selectedDay, _focusedDay) {
                    setState(() {
                      selectedDay = _selectedDay;
                      focusedDay = _focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, day, focusedDay) {
                      var matchingDocs = appointments.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        DateTime date = (data['fullDate'] as Timestamp).toDate();
                        return isSameDay(date, day);
                      }).toList();

                      if (matchingDocs.isNotEmpty) {
                        var matchedDoc = matchingDocs.first;
                        var data = matchedDoc.data() as Map<String, dynamic>;
                        String id = data['id_date'];

                        if (myBookedDateIds.contains(id)) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      }

                      return null; 
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      var validDocs = appointments.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        DateTime date = (data['fullDate'] as Timestamp).toDate();
                        return isSameDay(day, date);
                      }).toList();

                      if (validDocs.isNotEmpty) {
                        var matchedDoc = validDocs.first;
                        var data = matchedDoc.data() as Map<String, dynamic>;
                        String id = data['id_date'];
                        if (myBookedDateIds.contains(id)) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      }
                      return null;
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color.fromARGB(255, 132, 132, 132),
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    return getAppointmentsForDay(day, appointments);
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: selectedDay == null
                      ? const Center(child: Text('Select a day to view appointments'))
                      : ListView(
                          children: getAppointmentsForDay(selectedDay!, appointments)
                              .map((doc) {
                            var data = doc.data() as Map<String, dynamic>;

                            return Card(
                              elevation: 4.0,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                title: Text("Day: ${data['day']}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Start: ${data['start']} - End: ${data['end']}"),
                                    FutureBuilder<String>(
                                      future: function_appoint().fetchUsersHaveBooked(data['id_date']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading users...');
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No users have booked');
                                        } else {
                                          return Text('Users Have Booked: ${snapshot.data}');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                leading: const Icon(Icons.calendar_today, color: AppColors.primaryColor),
                                trailing: SizedBox(
                                  width: 150,
                                  child: FutureBuilder<List<bool>>(
                                    future: Future.wait([
                                      function_appoint().isUsersOverLimit(data['id_date']),
                                      function_appoint().CanBookHowMuchDates(),
                                      function_appoint().ifBookedThisDay(data['id_date']),
                                    ]),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return ElevatedButton(
                                          onPressed: null,
                                          child: const Text('Loading...'),
                                        );
                                      }
                                      if (!snapshot.hasData) {
                                        return ElevatedButton(
                                          onPressed: null,
                                          child: const Text('Error'),
                                        );
                                      }

                                      var results = snapshot.data!;
                                      bool isOverLimit = results[0];
                                      bool canBookMore = results[1];
                                      bool alreadyBookedDay = results[2];

                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (isOverLimit || alreadyBookedDay || !canBookMore)
                                              ? Colors.red
                                              : AppColors.primaryColor,
                                        ),
                                        onPressed: (isOverLimit || alreadyBookedDay || !canBookMore)
                                            ? null
                                            : () async {
                                                await api_functions().addUserToAppoint(data['id_date']);
                                                await function_archiv().addUserAndAppointmentsToArchiv(data['id_date']);
                                                updateBookingState(data['id_date']);
                                                fetchUserAppointments();
                                              },
                                        child: Text(
                                          isOverLimit
                                              ? "Fully Booked"
                                              : (!canBookMore
                                                  ? "Booking Limit Reached"
                                                  : (alreadyBookedDay
                                                      ? "Already Booked"
                                                      : "Book")),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
