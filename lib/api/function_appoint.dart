import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditime/api/globals.dart' as globals;

class function_appoint{

Future<int> getNextOrderNumber(String id_dayClicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('appointments')
      .where('id_date', isEqualTo: id_dayClicked)
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
Future<String> fetchUsersHaveBooked(String id_dayClicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('dates')
      .where('id_date', isEqualTo: id_dayClicked)
      .get(); 
  // Assuming the `usersHaveBooked` field exists in the document
  return query.docs.first['usersHaveBooked'].toString();

}
Future<String> fetchUsersWaiting(String id_dayClicked) async {
  QuerySnapshot query = await FirebaseFirestore.instance
      .collection('dates')
      .where('id_date', isEqualTo: id_dayClicked)
      .get(); 
  // Assuming the `usersHaveBooked` field exists in the document
  return query.docs.first['usersWaiting'].toString();
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


// ----------------------assistant ----------------------------------------------------------
Future<void> deleteAppoointAssaigndwithDay(String id_dayClicked) async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('id_date', isEqualTo: id_dayClicked)
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