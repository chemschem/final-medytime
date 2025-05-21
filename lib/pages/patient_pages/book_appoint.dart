import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_archiv.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/widgets/confirme_dailog.dart';
import 'package:meditime/widgets/confirmed_dailog.dart';
import 'package:table_calendar/table_calendar.dart';

class book_appoint extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Pass user ID from the login page to booking page here, but we dont need because we use a global var
  book_appoint({super.key});
  @override
  State<book_appoint> createState() => _book_appointState();
}
class _book_appointState extends State<book_appoint> {
  bool isOverLimit = false; // Define the variable to avoid the error
  // Responsible for triggering the fetch after booking!!!!!!
  //we use it to make work easy insted of using fetchBookingLimits directly
  //_updateBookingState needs to call setState, it must be inside a StatefulWidget, as setState is only available within a State class.
  //so we can not separate it.

  DateTime focusedDay = DateTime.now();//initialize
  DateTime? selectedDay;
  List<String> myBookedDateIds = [];


  void updateBookingState(String dateId) async {
    List<bool> limits = await function_appoint().fetchBookingLimits(dateId);
    setState(() {
      isOverLimit = limits[0];
    });
  }
   List<QueryDocumentSnapshot> getAppointmentsForDay( //fetch appoint related with selcted day
      DateTime day, List<QueryDocumentSnapshot> allDocs) {
    return allDocs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime date = (data['fullDate'] as Timestamp).toDate();
      return isSameDay(date, day);//isSameDay from calendar table Check if the date matches the selected day
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
    // إعادة تعيين focusedDay حتى يعيد بناء TableCalendar
    focusedDay = DateTime.now(); 
    //means you're resetting focusedDay to the current date and time — the exact moment that line is executed.
    //DateTime.now() creates a DateTime object representing the current time ,focusedDay now points to today, with the current time included.
    // value actually changes, forces calendar to redraw, and shows green dates correctly.

    //   focusedDay = focusedDay.add(const Duration(days: 0)); // trigger calendar rebuilds
    //does not actually change the value of focusedDay. It creates a new DateTime with the same value, 
    //and TableCalendar thinks nothing changed, so it doesn't rebuild.Duration(days: 0) means "add zero days", so:just assigns focusedDay to itself.
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,        
        automaticallyImplyLeading: false, // This removes the back arrow

        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('booking', 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            
          ],
        ),
      ),
      body:   StreamBuilder<QuerySnapshot>(
      stream: function_date().getdate(),
          // StreamBuilder listens to changes in Firestore
              //Unlike FutureBuilder (which fetches data once), StreamBuilder listens for real-time changes in Firestore.
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while fetching data
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Show message if no data is available
                  return const Center(child: Text('No Appointments Found'));
                }
                var appointments = snapshot.data!.docs; // All documents in the collection
                 return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (_selectedDay, _focusedDay) {//callback function called whenever the user taps on a day,what to do when a date is picked.
                  setState(() {//_selectedDay and _focusedDay passed automatically from the calendar.
                    selectedDay = _selectedDay;//If the calendar is showing April, and you tap on May 1st, selectedDay will shift to May.
                    focusedDay = _focusedDay;//If the calendar is showing April, and you tap on May 1st, focusedDay will shift to May.
                  });
                },
calendarBuilders: CalendarBuilders(
  selectedBuilder: (context, day, focusedDay) {
    // Check if the selected day is one of the booked dates
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
    // Keep green
  }
}


    if (matchingDocs.isNotEmpty) {
      var data = matchingDocs.first.data() as Map<String, dynamic>;
      String id = data['id_date'];
      if (myBookedDateIds.contains(id)) {
        // Selected day is booked -> keep it green
        return Container(
          margin: const EdgeInsets.all(6.0),
          decoration: const BoxDecoration(
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

    // If not booked, fallback to default selected style (e.g., gray)
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: const BoxDecoration(
        color: AppColors.selectionColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
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
          decoration: const BoxDecoration(
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
          decoration: const BoxDecoration(
            color: Colors.blue,
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


todayBuilder: (context, day, focusedDay) {
  DateTime localDay = DateTime(day.year, day.month, day.day);

  // نحاول نلاقي موعد في هذا اليوم
  var matchingDocs = appointments.where((doc) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime date = (data['fullDate'] as Timestamp).toDate();
    DateTime localAppointmentDay = DateTime(date.year, date.month, date.day);
    return localDay == localAppointmentDay;
  }).toList();

  if (matchingDocs.isNotEmpty) {
    var data = matchingDocs.first.data() as Map<String, dynamic>;
    String id = data['id_date'];

    // فقط لو المستخدم حجز هذا اليوم، نلون بالأخضر
    if (myBookedDateIds.contains(id)) {
      return Container(
        margin: const EdgeInsets.all(6.0),
        decoration: const BoxDecoration(
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

  // اليوم لم يتم حجزه من المستخدم
  return Container(
    margin: const EdgeInsets.all(6.0),
    decoration: BoxDecoration(
      border: Border.all(color:AppColors.primaryColor),
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      '${day.day}',
      style: const TextStyle(color:AppColors.primaryColor),
    ),
  );
},
),



                calendarStyle: const CalendarStyle(
                                  // إزالة النقطة السوداء تحت الأيام
                 markerDecoration: BoxDecoration(color: Colors.transparent),
                 // الأنماط الأخرى التي لديك...
                 selectedDecoration: BoxDecoration(
                   color: Colors.grey,
                   shape: BoxShape.circle,
                 ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                return getAppointmentsForDay(day, appointments);
             }
              ),

              const SizedBox(height: 10),

              Expanded(
  child: selectedDay == null
      ? const Center(child: Text('Select a day to view appointments'))
      : ListView(
          children: getAppointmentsForDay(selectedDay!, appointments).map((doc) {
            var data = doc.data() as Map<String, dynamic>;

return Container(
  margin: const EdgeInsets.only(bottom: 20),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Day: ${data['day']}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.secondColor),
          const SizedBox(width: 8),
          Text(
            "Start: ${data['start']} - End: ${data['end']}",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 5),
      FutureBuilder<String>(
        future: function_appoint().fetchUsersWaiting(data['id_date']).then((count) => count.toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading waiting list...');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No users waiting');
          } else {
            return Row(
              children: [
                const Icon(Icons.people, color: AppColors.textColor),
                const SizedBox(width: 5),
                Text(
                  'Waiting: ${snapshot.data}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textColor),
                ),
              ],
            );
          }
        },
      ),
      const SizedBox(height: 15),
      FutureBuilder<List<bool>>(
        future: Future.wait([
          function_appoint().isUsersOverLimit(data['id_date']),
          function_appoint().CanBookHowMuchDates(),
          function_appoint().ifBookedThisDay(data['id_date']),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('Loading...'),
            );
          }
          if (!snapshot.hasData) {
            return ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
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
        ? Colors.grey
        : Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  onPressed: (isOverLimit || alreadyBookedDay || !canBookMore)
      ? null
      : () async {
          if (!mounted) return;

          // احفظ السياق الأساسي قبل أي await
          final parentContext = context;

          showDialog(
            context: parentContext,
            builder: (dialogContext) => ConfirmDialog(
              date: data['day'].toString(),
              onCancel: () => Navigator.of(dialogContext).pop(),
              onConfirm: () async {
                // أغلق مربع التأكيد
                Navigator.of(dialogContext).pop();

                // تنفيذ الحجز
                await api_functions().addUserToAppoint(data['id_date']);
                await function_archiv().addUserAndAppointmentsToArchiv(data['id_date']);

                if (!mounted) return;

                updateBookingState(data['id_date']);
                fetchUserAppointments();

                int turnNumber = data['order'] ?? 1;

                // عرض مربع التأكيد النهائي باستخدام السياق المحفوظ
                if (mounted) {
                  showDialog(
                    context: parentContext,
                    builder: (_) => ConfirmedDialog(turnNumber: turnNumber),
                  );
                }
              },
            ),
          );
        },
  child: Text(
    isOverLimit
        ? "Fully Booked"
        : (!canBookMore
            ? "Booking Limit Reached"
            : (alreadyBookedDay
                ? "Already Booked"
                : "Book Appointment")),
    style: TextStyle(
      color: (isOverLimit || alreadyBookedDay || !canBookMore)
          ? AppColors.textColor
          : Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
);

    
        },
      ),
    ],
  ),
);

          }).toList(),
        ),
),

              const Padding(padding: EdgeInsets.all(16)),
            ],
          );
        },
      ),


        bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
        currentIndex: 1, // Set the current index to highlight the active tab
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: (index) {
          // Handle navigation based on the selected index
          if (index == 0) {
            Navigator.pushNamed(context, '/home_patient');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/book_appoint');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/patient_settings');
          }
        },
      ),

      );
  }
}
