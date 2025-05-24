import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/pages/assistant_pages/DayDetailsPage.dart';
import 'package:meditime/widgets/showMessage.dart';

class function_appoint{

Future<int> getNextOrderNumber(String idDayclicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('appointments')
      .where('id_date', isEqualTo: idDayclicked)
      .get();
  // Order = Number of existing users on that date + 1
  return query.docs.length + 1;
}

Future<List<Map<String, dynamic>>> fetchMyAppointments() async {
  //return a Future that resolves to a List of Map<String, dynamic>.
  //List<Map<String, dynamic>> :A list of maps, where each map contains key-value pairs
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('id_user', isEqualTo: globals.currentUserId)
        .get();//Fetch all appointments where the id_user is the current user.
    return query.docs.map((doc) => { // Convert each document to a map
      'id_date': doc['id_date'],
      'order': doc['order'],
      'consultinDone': doc['consultinDone'],

    }).toList();// Convert the list of maps to a list
  } catch (e) {
    print('Error fetching appointments: $e');
    return [];
  }
 //exemple: two maps in the list
 // {'id_date': '', 'order': },
 // {'id_date': '', 'order': },
}

Future<bool> isUsersOverLimit(String idDayClicked) async {
  try { FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Fetch limit from dates collection
    DocumentSnapshot dateDoc = await firestore.collection('dates').doc(idDayClicked).get();
    if (!dateDoc.exists) {
      print("Date not found!");
      return false;
    }
    int limit = dateDoc['limit'] ?? 0;
    int order = await getNextOrderNumber(idDayClicked);
    return order > limit;
  } catch (e) {
    print("Error checking booking status: $e");
    return false;
  }
}

Future<bool> CanBookHowMuchDates() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('id_user', isEqualTo: globals.currentUserId)
        .get();
    int userBookings = snapshot.docs.length;// Count the number of bookings
    return userBookings < globals.maxBookings; // Returns true if booking is allowed
  } catch (e) {
    print('Error fetching booking count: $e');
    return false; // Assume false to prevent errors
  }
}

Future<List<bool>> fetchBookingLimits(String dateId) async {//fetchBookingLimits returns a Future that resolves to a List of bools.
  bool isOverLimit = await isUsersOverLimit(dateId); 
  bool canBookMore = await CanBookHowMuchDates();
  return [isOverLimit, canBookMore];
  //Immediate UI updates: After a booking action, _updateBookingState ensures that the button updates instantly
  // without waiting for a full page refresh.
  //This prevents unnecessary calls and ensures we only fetch data once when needed.

}
Future<int> fetchUsersHaveBooked(String idDayclicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('dates')
      .where('id_date', isEqualTo: idDayclicked)
      .get(); 
  // Assuming the `usersHaveBooked` field exists in the document
  return query.docs.first['usersHaveBooked'];

}
Future<int> fetchUsersWaiting(String idDayclicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('dates')
      .where('id_date', isEqualTo: idDayclicked)
      .get(); 
  // Assuming the `usersHaveBooked` field exists in the document
  return query.docs.first['usersWaiting'];
}

Future<bool> fetchConsultinDone(String idDayclicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('appointments')
      .where('id_date', isEqualTo: idDayclicked)
      .where('consultinDone', isEqualTo: true) // Check the consultinDdone field ??
      .get(); 
  return query.docs.isNotEmpty; 
}


Future<bool> ifBookedThisDay(String idDayClicked) async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('id_user', isEqualTo: globals.currentUserId)
        .where('id_date', isEqualTo: idDayClicked)
        .get();

    return query.docs.isNotEmpty;
  } catch (e) {
    print('Error checking if user already booked this day: $e');
    return false; // Safe default: allow booking if error
  }
}


Future<void> checkAndGoToAppointments(BuildContext context, DateTime selectedDate) async {
  Timestamp selectedTimestamp = Timestamp.fromDate(
    DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
  );

  try {
    // 1. جلب مستند التاريخ من مجموعة dates
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('dates')
        .where('fullDate', isEqualTo: selectedTimestamp)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final dateDoc = querySnapshot.docs.first;
      final idDate = dateDoc['id_date'];
      final Map<String, dynamic> dateData = dateDoc.data() as Map<String, dynamic>;
      dateData['id'] = idDate; // Add the document ID to the date data
      print("📦 dateData: $dateData");

      // 2. جلب معلومات التاريخ
      final dateHelper = function_date();
      String dateInfo = await dateHelper.fetchDate(idDate);

      // 3. جلب جميع المواعيد لهذا التاريخ
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('id_date', isEqualTo: idDate)
          .get();

      // 4. دمج كل موعد مع معلومات المستخدم المرتبطة به
      List<Map<String, dynamic>> enrichedAppointments = [];

      for (var doc in appointmentsSnapshot.docs) {
        Map<String, dynamic> appointmentData = doc.data() as Map<String, dynamic>;
        final userId = appointmentData['id_user'];

        try {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('user')
              .doc(userId)
              .get();

          if (userSnapshot.exists) {
            Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
            appointmentData['name'] = userData['name'] ?? 'no name';
            appointmentData['email'] = userData['email'] ?? 'no email';
            appointmentData['age'] = userData['age'] ?? 'no age';
            appointmentData['phone'] = userData['phone'] ?? 'no phone';
            appointmentData['address'] = userData['address'] ?? 'no address';


          } else {
            appointmentData['name'] = 'no name';
            appointmentData['email'] = '---';
            appointmentData['age'] = '---';
            appointmentData['phone'] = '---';
            appointmentData['address'] = '---';
          }
        } catch (e) {
          appointmentData['name'] = 'خطأ في جلب الاسم';
          appointmentData['email'] = '---';
          appointmentData['age'] = '---';
          appointmentData['phone'] = '---';
          appointmentData['address'] = '---';
        }

        enrichedAppointments.add(appointmentData);
      }

      // في البداية، تم جلب بيانات الموعد من appointmentsSnapshot ووضعها في متغير appointmentData.
      // ثم قمت بجلب بيانات المستخدم المرتبطة بالموعد، وإذا تم العثور عليها، أضفتها إلى appointmentData.
      // بعدها، يتم إضافة appointmentData (التي تحتوي على بيانات الموعد بالإضافة إلى بيانات المستخدم) إلى قائمة enrichedAppointments.

      // 5. الانتقال إلى صفحة التفاصيل
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DayDetailsPage(
            dateInfo: dateInfo, // تم تحديث dateInfo هنا
            dateData: dateData,
            appointmentsAndUsers: enrichedAppointments,
            appointments: appointmentsSnapshot.docs.map((doc) => doc.data()).toList(),
          ),
        ),
      );
    } else {
      ShowMessage.showError(context, "no appointments found for this date");
    }
  } catch (e) {
    print("error: $e");
    ShowMessage.showError(context, 'error fetching appointments: $e');

  }
}




// ----------------------assistant ----------------------------------------------------------
Future<void> deleteAppoointAssaigndwithDay(String idDayclicked) async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('id_date', isEqualTo: idDayclicked)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    print('All appointments deleted successfully');
  } catch (e) {
    print('Failed to delete appointments: $e');
  }
}

Future<void> deleteAllAppointments() async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('appointments')
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    print('All appointments deleted successfully');
  } catch (e) {
    print('Failed to delete appointments: $e');
  }
}
}