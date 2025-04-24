import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:intl/intl.dart';
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
     //Used only to highlight dates in calendar
@override
void initState() {
  super.initState();
  loadBookedDatesFromDates();
}

Future<void> loadBookedDatesFromDates() async {
  try {
    final snapshot = await function_date().getdate().first; // Use your existing stream
    final docs = snapshot.docs;
    setState(() {
      AddedDates = docs.map((doc) {
        final Timestamp ts = doc['fullDate'];
        final DateTime dt = ts.toDate();
        return DateTime(dt.year, dt.month, dt.day); // Normalize to date only
      }).toSet();
    });
  } catch (e) {
    print("Error loading booked dates: $e");
  }
}






  final startController = TextEditingController();
  final endController = TextEditingController();
  final limitController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDate;//what ???
  String? selectedDay;

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Weekly Appointments')),
      body: Column(
        children: [
          Text('User ID: ${globals.currentUserId}'),


                      StreamBuilder<QuerySnapshot>(
               stream: function_date().getdate(),
               builder: (context, snapshot) {
                 // collect all booked dates into a Set for fast lookup
                 Set<DateTime> bookedDates = {};
             
                 if (snapshot.hasData) {
                   for (var doc in snapshot.data!.docs) {
                     var data = doc.data() as Map<String, dynamic>;
                     Timestamp timestamp = data['fullDate'];
                     DateTime fullDate = timestamp.toDate();
                     bookedDates.add(DateTime(fullDate.year, fullDate.month, fullDate.day)); // normalize
                   }
                 }
             
                   return TableCalendar(
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
                     if (bookedDates.contains(normalized)) return; // block already added
                 
                     setState(() {
                       if (selectedDates.contains(normalized)) {
                         selectedDates.remove(normalized);
                       } else {
                         selectedDates.add(normalized);
                       }
                     });
                   },
                 
                   calendarStyle: CalendarStyle(
                     todayDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                     selectedDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                     markerDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
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


          const SizedBox(height: 10),

          TextField(controller: startController, decoration: const InputDecoration(labelText: 'Start Time')),
          TextField(controller: endController, decoration: const InputDecoration(labelText: 'End Time')),
          TextField(controller: limitController, decoration: const InputDecoration(labelText: 'Limit')),
          TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 20),


          
            ElevatedButton(
            onPressed: () async {
              if (selectedDates.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one day.")));
                return;
              }
          
              final start = startController.text.trim();
              final end = endController.text.trim();
              final limit = int.tryParse(limitController.text.trim());
              final description=descriptionController.text.trim();
          
              if (start.isEmpty || end.isEmpty || limit == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all time fields correctly.")));
                return;
              }
          
              Set<DateTime> newAdded = {}; // Temporary list for added dates
          
          for (var date in selectedDates) {
            String day = weekdays[date.weekday - 1];
            await function_date().addMultiDate(day, start, end, limit, fullDate: date, description: description);
          
            // Normalize date (remove time) and store in temporary list
            newAdded.add(DateTime(date.year, date.month, date.day));
          }
          
          // Add new added dates to the UI highlight list
          setState(() {
            AddedDates.addAll(newAdded); // 🔥 trigger calendar UI update
            selectedDates.clear();       // ✅ Clear selected days after saving
          });
          
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointments added.")));
            },
            child: const Text("Add All Selected Days"),
          ),         
          const SizedBox(height: 20),

          // Display Appointments from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: function_date().getdate(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Appointments Found'));
                }
                var dates = snapshot.data!.docs;
                
                return ListView.builder(
                  itemCount: dates.length, 
                  itemBuilder: (context, index) {
                    var data = dates[index].data() as Map<String, dynamic>; 
                    
                    return Card(
                      child: ListTile(
                        title: Text("Day: ${data['day']}"),
                        subtitle: Text(
                          "Start: ${data['start']} - End: ${data['end']}\nDate: ${DateFormat('yyyy-MM-dd').format((data['fullDate'] as Timestamp).toDate())}"
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







    //        ElevatedButton.icon(
    //        onPressed: () {
    //       if (dayController.text.isEmpty || startController.text.isEmpty || endController.text.isEmpty|| limitController.text.isEmpty) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Please fill in all fields'))
    //       );
    //       return; // Exit function early
    //       }
    //       date = date_model(
    //       id_date: dayController.text+startController.text+'-'+endController.text+'-'+limitController.text,
    //       day: dayController.text,
    //       start: int.tryParse(startController.text),
    //       end: int.tryParse(endController.text),
    //       limit: int.tryParse(limitController.text),
    //       );
    //       function_date.addDateToFirestore(date);
    //           dayController.text = '';
    //           startController.text = '';
    //           endController.text = '';
    //           limitController.text = ''; 
    //       // Add date to archive
    //       if (date.id_date != null) {
    //         function_archiv().addDateToArchiv(date.id_date!);
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(content: Text('Date ID is null'))
    //         );
    //       }          
    //         },
    //         icon: const Icon(Icons.create, color: Colors.blue),
    //         label: const Text('Add date'),
    //       ),
    //       ],
    //     ),
    //   ),
    // );
