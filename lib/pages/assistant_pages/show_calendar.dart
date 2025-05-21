import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_date.dart';
import 'package:intl/intl.dart'; // للاستفادة من DateFormat
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/core/theme/styles.dart';
import 'package:table_calendar/table_calendar.dart';

class show_calendar extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  show_calendar({super.key});

  @override
  State<show_calendar> createState() => show_calendarState();
}

class show_calendarState extends State<show_calendar> {
  Set<DateTime> selectedDates = {};
  Set<DateTime> AddedDates = {};
  bool isWeekly = true;
  DateTime? focusedDayBelow;
  String dateInfo = ''; // لتخزين تاريخ اليوم

  final startController = TextEditingController();
  final endController = TextEditingController();
  final limitController = TextEditingController();
  final descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _setTodayDate(); // تعيين تاريخ اليوم
    _searchController.addListener(_filterDates);
  }

  void _setTodayDate() {
    final DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, y').format(now);  // تنسيق التاريخ
    setState(() {
      dateInfo = 'Today: $formattedDate';  // تعيين تاريخ اليوم
    });
  }

  void _filterDates() {
    // يمكنك إضافة وظائف للتصفية هنا إذا كنت بحاجة لذلك
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'search dates..',
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: const Icon(Icons.search, color:AppColors.primaryColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Appointments", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false, // This removes the back arrow
        centerTitle: true,


      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // إضافة حقل البحث
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: _searchDecoration(),
              ),
            ),
            const SizedBox(height: 20),
            // جدول المواعيد (التقويم)
            StreamBuilder<QuerySnapshot>(
              stream: function_date().getdate(),
              builder: (context, snapshot) {
                Set<DateTime> bookedDates = {};

                if (snapshot.hasData) {
                  bookedDates = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ts = data['fullDate'] as Timestamp;
                    final dt = ts.toDate();
                    return DateTime(dt.year, dt.month, dt.day);
                  }).toSet();
                }

                return TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    final normalized = DateTime(day.year, day.month, day.day);
                    return selectedDates.contains(normalized);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    function_appoint().checkAndGoToAppointments(context, selectedDay);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: AppColors.primaryColor, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                    markerDecoration: BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                    outsideDaysVisible: false,
                  ),
                  eventLoader: (day) {
                    final normalized = DateTime(day.year, day.month, day.day);
                    return bookedDates.contains(normalized) ? ['booked'] : [];
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                );
              },
            ),
const SizedBox(height: 20),

// Button to delete all days
Center(
  child: SizedBox(
    width: double.infinity, // Makes the button take the full width of the page
    child: ElevatedButton.icon(
      onPressed: () async {
        await function_date().deleteAllDates(); // Delete dates from the 'dates' collection
        await function_appoint().deleteAllAppointments(); // Delete appointments from 'appointments'
        setState(() {}); // Update the UI
      },
      icon: const Icon(Icons.delete_forever, color: Colors.white),
      label: const Text("Delete All Days",style: TextStyle(color: Colors.white),),
      style:AppStyles.OtherbuttonStyle(Colors.red),
    ),
  ),
),

const SizedBox(height: 20),

// Button to add new appointments
Center(
  child: SizedBox(
    width: double.infinity, // Makes the button take the full width of the page
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/add_weekly_appoint');
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text("Add New Appointments Here", style: TextStyle(color: Colors.white),),
      style:AppStyles.OtherbuttonStyle(AppColors.primaryColor),

    ),
  ),
),

          
          ],
        ),
      ),

// Bottom Navigation Bar

   bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
currentIndex: 1, // Set the current index to highlight the active tab
  selectedItemColor: Colors.blue, // Color for the selected item
  unselectedItemColor: Colors.grey, // Color for unselected items
       onTap: (index) {
        // Handle navigation based on the selected index
        if (index == 0) {
          Navigator.pushNamed(context, '/home_assistant');
        } else if (index == 1) {
          // Stay on the current page 
        } else if (index == 2) {
          Navigator.pushNamed(context, '/setting_assistant');
        }
      },
    ),
  );
} 
}