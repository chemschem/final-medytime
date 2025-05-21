import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/models/clinic_model.dart';
import 'package:meditime/models/user_model.dart';
//import 'modify_date.dart';


class api_functions {

static Future<void> updateClinicInFirestore(clinic_model clinic) async {
  if (clinic.id_clinic == null || clinic.id_clinic!.isEmpty) {
    print('❌ clinic.id_clinic is null or empty');
    return;
  }

  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('clinic').doc(clinic.id_clinic).update(clinic.toJson());
  } catch (e) {
    print('Error updating clinic: $e');
  }
}








  static Future<void> addUserToFirestore(user_model user) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('user').doc(user.id_user).set(user.toJson());
      //    print('user added successfully!');
      //    print(user.toJson());
    } catch (e) {
      //     print(user.toJson());
      print('Error adding user: $e');
    }
  }
  
 Future<void> addUserToAppoint(String idDayClicked) async {
  final firestore = FirebaseFirestore.instance;
  final dateDoc = (await firestore
      .collection('dates')
      .where('id_date', isEqualTo: idDayClicked)
      .get())
      .docs
      .first;

  final docRef = firestore
      .collection('appointments')
      .doc('${idDayClicked}_${globals.currentUserId}');

  await docRef.set({
    'id_date': idDayClicked.toString(),
  'id_user': globals.currentUserId.toString(),
  'order': int.parse(dateDoc['usersHaveBooked'].toString()) + 1,
  'consultinDone': false,
  });

  await firestore
      .collection('dates')
      .doc(dateDoc.id)
      .update({
        'usersHaveBooked': FieldValue.increment(1),
        'usersWaiting': FieldValue.increment(1),
      });
}


Future<Map<String, List<String>>> groupAppointmentsByDate() async {
  // key string: id_day , value list of id_user
  QuerySnapshot query = await FirebaseFirestore.instance.collection('appointments').get();
  //The result (query) is a QuerySnapshot, which contains a list of documents (query.docs).
  Map<String, List<String>> groupedData = {};
  //empty map to store the grouped data.
  for (var doc in query.docs) {
    String idDate = doc['id_date']; 
    String idUser = doc['id_user'];
    
    if (!groupedData.containsKey(idDate)) {//if the id_date is not already in the map, add it.
      groupedData[idDate] = [];
    }
    //loop and extract the id_date and id_user from each document.
    groupedData[idDate]!.add(idUser);//add the id_user to the list of id_users for the corresponding id_date.
  }
  return groupedData;
  //The number of lists inside the map equals the number of unique dates (id_date) in the appointUser collection.
}


// تم الاستغناء عن هذه الدالة 
Future<Map<String, List<Map<String, dynamic>>>> getAppointByDateOrder() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('appointments').get();
 //group the data by date and order
  //The result (querySnapshot) is a QuerySnapshot, which contains a list of documents (querySnapshot.docs).
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    String idDate = data['id_date'];   
   // Fetch the fullday from the 'dates' collection using the id_date
      DocumentSnapshot dateDoc = await FirebaseFirestore.instance.collection('dates').doc(idDate).get();
      Timestamp fulldayTimestamp = dateDoc.exists ? dateDoc['fullDate'] : null;      
      // ignore: unnecessary_null_comparison
      String fullday = fulldayTimestamp != null
      //toIso8601String method in dart convert datetime ojct to string according to ISO 8601 standard
          //-? fulldayTimestamp.toDate().toIso8601String()
          ? DateFormat('yyyy-MM-dd').format(fulldayTimestamp.toDate())
          : 'Unknown Day';
           String dayOfWeek = fulldayTimestamp != null
          ? DateFormat('EEEE').format(fulldayTimestamp.toDate()) // Get the day of the week
          : 'Unknown Day';
          //EEEE is a pattern used in Dart's intl package to format the date as the full name of the day of the week (e.g., Monday, Tuesday).

    // Combine the formatted date and day of the week
    String combineddate = '$dayOfWeek, $fullday'; //displaying
   // Group appointments by fullday
      if (!groupedData.containsKey(combineddate)) {
        groupedData[combineddate] = []; // Create a new list for this combineddate 
      }
    groupedData[combineddate]!.add({
      'order': data['order'],
      'id_user': data['id_user'],
    });
  }
  return groupedData;
}
 
 //fetch current user
Future<String> fetchCurrentUser() async {
  final doc = await FirebaseFirestore.instance.collection('user').doc(globals.currentUserId).get();
  return doc['name'] ?? 'User';
}
Future<Map<String, dynamic>> fetchUser() async {
  final doc = await FirebaseFirestore.instance.collection('user').doc(globals.currentUserId).get();
  if (doc.exists) {
    return doc.data() as Map<String, dynamic>; // Return all fields as a map
  } else {
    throw Exception('User not found');
  }
}

Future<void> updateUserData(Map<String, dynamic> updatedData) async {
  await FirebaseFirestore.instance
      .collection('user')
      .doc(globals.currentUserId)
      .update(updatedData);
}



}
//end class api_functions