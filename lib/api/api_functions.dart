import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/models/user_model.dart';
//import 'modify_date.dart';


class api_functions {
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
  
 Future<void> addUserToAppoint(String id_dayClicked) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
     QuerySnapshot query = await FirebaseFirestore.instance
        .collection('dates')
        .where('id_date', isEqualTo: id_dayClicked)
        .get();
      await firestore.collection('appointments').doc('${query.docs.first['id_date']}_${globals.currentUserId}').set({
        'id_date': id_dayClicked,
        'id_user': globals.currentUserId,
        'order': await function_appoint().getNextOrderNumber(id_dayClicked),
        'consultinDdone': false,
      });
       await firestore
          .collection('dates')
          .doc(query.docs.first.id)
          .update({
        'usersHaveBooked':await function_appoint().getNextOrderNumber(id_dayClicked)-1,
      });
      await firestore
          .collection('dates')
          .doc(query.docs.first.id)
          .update({
        'usersWaiting': await function_appoint().getNextOrderNumber(id_dayClicked) - 1,
      });
      print('User added to appointUser collection successfully!');
      print('consultinDdone value: ${query.docs.first['consultinDdone']}');
    } catch (e) {
      print('Error adding user to appoint: $e');
    }
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
}
//end class api_functions