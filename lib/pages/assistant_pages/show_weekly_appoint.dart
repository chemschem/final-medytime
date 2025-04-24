import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class show_weekly_appoint extends StatefulWidget {
  @override
  _show_weekly_appointState createState() => _show_weekly_appointState();
}

class _show_weekly_appointState extends State<show_weekly_appoint> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();//selected day
  DateTime _focusedDay = DateTime.now();//focused day
  late Stream<QuerySnapshot> _appointmentsStream;//stream of appointments

  @override
  void initState() {
    super.initState();
    _appointmentsStream = _getAppointmentsForDay(_selectedDay);
  }

  Stream<QuerySnapshot> _getAppointmentsForDay(DateTime day) {
    String formattedDay = DateFormat('EEEE').format(day); // استخراج اسم اليوم
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('day', isEqualTo: formattedDay)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📅 جدول المواعيد الأسبوعي')),
      body: Column(
        children: [
          // 🔹 التقويم
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _appointmentsStream = _getAppointmentsForDay(selectedDay);
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 قائمة المواعيد لليوم المحدد
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _appointmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('❌ لا يوجد مواعيد لهذا اليوم'));
                }

                var dates = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    var data = dates[index].data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          "📆 يوم: ${data['day']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "⏰ من: ${data['start']} - إلى: ${data['end']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        leading: const Icon(Icons.calendar_today, color: Colors.blue),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
