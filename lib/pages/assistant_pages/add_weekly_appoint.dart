import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/core/theme/styles.dart';
import 'package:meditime/pages/assistant_pages/add_monthly_appoint.dart';
import 'package:meditime/widgets/CustomTextField_1.dart';
import 'package:table_calendar/table_calendar.dart';

class add_weekly_appoint extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  add_weekly_appoint({super.key});

  @override
  State<add_weekly_appoint> createState() => add_weekly_appointState();
}

class add_weekly_appointState extends State<add_weekly_appoint> {
  Set<DateTime> selectedDates = {};
  Set<DateTime> AddedDates = {};
  bool isWeekly = true;
  DateTime? focusedDayBelow;

  final startController = TextEditingController();
  final endController = TextEditingController();
  final limitController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    loadBookedDatesFromDates();
    
  // Set default values here
  startController.text = globals.defaultStartTime;
  endController.text = globals.defaultEndTime;
  limitController.text = globals.defaultLimit;
  descriptionController.text = globals.defaultDescription;

 
  }

  Future<void> loadBookedDatesFromDates() async {
    try {
      final snapshot = await function_date().getdate().first;
      final docs = snapshot.docs;
      setState(() {
        AddedDates = docs.map((doc) {
          final Timestamp ts = doc['fullDate'];
          final DateTime dt = ts.toDate();
          return DateTime(dt.year, dt.month, dt.day);
        }).toSet();
      });
    } catch (e) {
      print("Error loading booked dates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: const Text('Add Appointments', style: TextStyle(
          color: AppColors.whiteColor,
          fontWeight: FontWeight.bold,
        ),
        
        ),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // زر التبديل بين weekly و monthly
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isWeekly = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isWeekly ? AppColors.primaryColor : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_view_week,
                              color: isWeekly ? Colors.white : Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Weekly',
                            style: TextStyle(
                              color: isWeekly ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => add_monthly_appoint()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !isWeekly ? Colors.blue : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month,
                              color: !isWeekly ? Colors.white : Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Monthly',
                            style: TextStyle(
                              color: !isWeekly ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // جدول المواعيد (التقويم)
            StreamBuilder<QuerySnapshot>(
              stream: function_date().getdate(),
              builder: (context, snapshot) {
                Set<DateTime> bookedDates = {};

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    Timestamp timestamp = data['fullDate'];
                    DateTime fullDate = timestamp.toDate();
                    bookedDates.add(DateTime(fullDate.year, fullDate.month, fullDate.day));
                  }
                }

                return TableCalendar(
  enabledDayPredicate: (day) {
  final today = DateTime.now();
  final todayNormalized = DateTime(today.year, today.month, today.day);
  return !day.isBefore(todayNormalized);
},
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) {
                    final normalized = DateTime(day.year, day.month, day.day);
                    return selectedDates.contains(normalized);
                  },
                  onDaySelected: (selected, focused) {
                     final normalized = DateTime(selected.year, selected.month, selected.day);
  final today = DateTime.now();
  final todayNormalized = DateTime(today.year, today.month, today.day);

  // Prevent selecting old dates
  if (normalized.isBefore(todayNormalized)) return;
  if (AddedDates.contains(normalized)) return;

                    if (AddedDates.contains(normalized)) return;
                    setState(() {
                      if (selectedDates.contains(normalized)) {
                        selectedDates.remove(normalized);
                      } else {
                        selectedDates.add(normalized);
                      }
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration:
                        BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                    selectedDecoration:
                        BoxDecoration(color: AppColors.selectionColor, shape: BoxShape.circle),
                    markerDecoration:
                        BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    outsideDaysVisible: false,
                  ),
                  eventLoader: (day) {
                    final normalized = DateTime(day.year, day.month, day.day);
                    return AddedDates.contains(normalized) ? ['booked'] : [];
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // حقول الإدخال

           CustomTextField_1(controller: startController,
                labelText: 'From',),
            CustomTextField_1(controller: endController,
                labelText: 'To',),            
            CustomTextField_1(controller: limitController,
                labelText: 'Limit',),            
            CustomTextField_1(controller: descriptionController,
                labelText: 'Descreption',),
// Centered button for "Add All Selected Days"
Center(
  child: SizedBox(
    width: double.infinity, // Makes the button take the full width of the page
    child: _buildElevatedButton(
      label: 'Add All Selected Days',
      onPressed: () async {
        if (selectedDates.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select at least one day.")),
          );
          return;
        }

        final start = startController.text.trim();
        final end = endController.text.trim();
        final limit = int.tryParse(limitController.text.trim());
        final description = descriptionController.text.trim();

        if (start.isEmpty || end.isEmpty || limit == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all time fields correctly.")),
          );
          return;
        }

        Set<DateTime> newAdded = {};
        for (var date in selectedDates) {
          String day = weekdays[date.weekday - 1];
          await function_date().addMultiDate(
            day,
            start,
            end,
            limit,
            fullDate: date,
            description: description,
          );
          newAdded.add(DateTime(date.year, date.month, date.day));
        }

        setState(() {
          AddedDates.addAll(newAdded);
          selectedDates.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointments added.")),
        );
      },
    ),
  ),
),

const SizedBox(height: 20),

// Centered button for "See appointments"
Center(
  child: SizedBox(
    width: double.infinity, // Makes the button take the full width of the page
    child: _buildElevatedButton(
      label: 'See appointments',
      onPressed: () {
        Navigator.pushNamed(context, '/show_calendar');
      },
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
          icon: Icon(Icons.add),
          label: 'Add',
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

 
  // Widget for elevated button with consistent styling
  Widget _buildElevatedButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: AppStyles.OtherbuttonStyle(AppColors.primaryColor),

    child: Text(
      label,
      style:
       const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );
}

}
