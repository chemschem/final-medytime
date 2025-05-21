import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditime/api/globals.dart' as globals;

class function_archiv {
  

Future<void> addDateToArchiv(String idDayclicked) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('dates')
          .where('id_date', isEqualTo: idDayclicked)
          .get();
      await firestore.collection('archiv').doc('${query.docs.first['id_date']}').set({
        'id_date': idDayclicked,
        'day': query.docs.first['day'],
        'start': query.docs.first['start'],
        'end': query.docs.first['end'],
        'limit': query.docs.first['limit'],
      });
      print('Date added to archiv collection successfully!');
    } catch (e) {
      print('Error adding date to archiv: $e');
    }
  }

  Future<void> addUserAndAppointmentsToArchiv(String idDayclicked) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc = await firestore
        .collection('user')
        .doc(globals.currentUserId)//Directly references a document by its ID because we alrady know it without fetching by where...
        .get();
    if (!userDoc.exists) {
      print('User data not found');
      return;
    }
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;//Convert the document data to a map for easy access
    await firestore
        .collection('archiv')
        .doc(idDayclicked)
        .collection('user')
        .doc(globals.currentUserId)
        .set({ // Add user data under the archiv 
      'name': userData['name'] ?? 'Unknown',
      'email': userData['email'] ?? 'Unknown',
      'phone': userData['phone'] ?? 'Unknown',
    });
    QuerySnapshot appointmentQuery = await firestore
        .collection('appointments')
        .where('id_date', isEqualTo: idDayclicked)
        .where('id_user', isEqualTo: globals.currentUserId)
        .get();
    for (var appointment in appointmentQuery.docs) { //Loops through each appointment and saves it under the user’s archived record.
      await firestore
          .collection('archiv')
          .doc(idDayclicked)
          .collection('user')
          .doc(globals.currentUserId)
          .collection('appointments')
          .doc(appointment.id) // Same appointment ID
          .set(appointment.data() as Map<String, dynamic>);
    }
    print('User and appointments added to archiv successfully!');
  } catch (e) {
    print('Error adding to archiv: $e');
  }
}
Future<List<Map<String, dynamic>>> fetchArchivData() async { //Returns a list of maps, each containing an archived date and its associated users & appointments.
  List<Map<String, dynamic>> archivData = [];//Empty list to store the fetched data
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot datesSnapshot = await firestore.collection('archiv').get();
    for (var dateDoc in datesSnapshot.docs) {
      Map<String, dynamic> dateData = dateDoc.data() as Map<String, dynamic>;
      // Create a base object for the date
      Map<String, dynamic> data = {
        'id_date': dateData['id_date'],
        'day': dateData['day'],
        'start': dateData['start'],
        'end': dateData['end'],
        'limit': dateData['limit'],
        'users': []
      };
      // Fetch Users
      QuerySnapshot userSnapshot = await firestore
          .collection('archiv')
          .doc(dateDoc.id)
          .collection('user')
          .get();
      for (var userDoc in userSnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Add user data
        Map<String, dynamic> userInfo = {
          'name': userData['name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'appointments': []
        };
        // Fetch Appointments for each user
        QuerySnapshot appointmentSnapshot = await firestore
            .collection('archiv')
            .doc(dateDoc.id)
            .collection('user')
            .doc(userDoc.id)
            .collection('appointments')
            .get();
        for (var appointment in appointmentSnapshot.docs) {
          userInfo['appointments'].add(appointment.data());
        }
        // Add userInfo to the list of users
        data['users'].add(userInfo);
      }
      // Add to the main list
      archivData.add(data);
    }
  } catch (e) {
    print('Error fetching data: $e');
  }
  return archivData;
}

}




