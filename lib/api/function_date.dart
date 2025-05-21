import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:meditime/api/functionFCM_token.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/models/date_model.dart';

class function_date {
  
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
   static Future<bool> addDateToFirestore(date_model date,BuildContext context) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Check if the selected day already exists in Firestore
    QuerySnapshot query = await firestore
        .collection('dates')
        .where('fullDate', isEqualTo: date.fullDate)
        .get();
    if (query.docs.isNotEmpty) {
      print('The day ${date.fullDate} is already added!');
      return false; 
    }
    // Add the date to Firestore if it doesn't exist      
      await firestore.collection('dates').doc(date.id_date).set(date.toJson());     
      print('date added successfully!');
      String title = "New updates!!";
      String body = "New dates were added!";
      // Send notification to all users when an admin modifies an appointment
      await functionFCM_token().sendNotificationToAllusers(title, body);
      await functionFCM_token().storeNotifications(title, body);
      return true;
    } catch (e) {
      //     print(user.toJson());
      print('Error adding date: $e');
    }
    return false;
  }


  //add multiple dates: 
  Future<void> addMultiDate(String day, String start, String end, int limit, {required DateTime fullDate, required String description}) async {
  
  
  
  final docId = '$day$start-$end-$limit';
  final docRef = FirebaseFirestore.instance.collection('dates').doc(docId);
  final exists = await docRef.get();
  if (exists.exists) {
    return; // Already exists, skip
  }
  await docRef.set({
    'id_date':docId,
    'day': day,
    'start': start,
    'end': end,
    'limit': limit,
    'fullDate': fullDate,
    'usersHaveBooked': 0,
    'usersWaiting': 0,
    'description': description,

  });
}


  //Function to fetch dates as a stream
  Stream<QuerySnapshot> getdate() {
    return FirebaseFirestore.instance.collection('dates').snapshots();
  }
  //Fetch a specific date
  Future<String> fetchDate(String idDayclicked) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('dates')
        .where('id_date', isEqualTo: idDayclicked)
        .get();
    // نفترض أن fullDate من نوع Timestamp
Timestamp timestamp = query.docs.first['fullDate'];
DateTime dateTime = timestamp.toDate();
// تنسيق التاريخ ليظهر بالشكل المطلوب: May 12, 2025
String formattedDate = DateFormat('MMMM d, y').format(dateTime);
print('Formatted Date from fetchDate : $formattedDate');


    return '${query.docs.first['day']}, $formattedDate , from: ${query.docs.first['start']} am, to: ${query.docs.first['end']}pm';
  }
  

  // -----------------------------------------Modify----------------------------------------------- 
  
  //Function to delete a single date
  Future<void> deleteDate(String docId) async {
    try {
      //get the date to be deleted
      DocumentSnapshot dateToDelete= await FirebaseFirestore.instance.collection('dates').doc(docId).get();
      await FirebaseFirestore.instance.collection('dates').doc(docId).delete();
      print('Document deleted successfully');
      String title = "New updates!!";
      String body = "Date: ${dateToDelete['day']} was deleted!";
      // Send notification to all users when an admin modifies an appointment
      await functionFCM_token().sendNotificationToAllusers(title, body);
      await functionFCM_token().storeNotifications(title, body);
    } catch (e) {
      print('Failed to delete document: $e');
    }
  }

  //Function to delete all dates
  Future<void> deleteAllDates() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance.collection('dates').get();
      // Loop through and delete each document
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      print('All documents deleted successfully');
      String title = "New updates!!";
      String body = "Dates were deleted!";
      // Send notification to all users when an admin modifies an appointment
      await functionFCM_token().sendNotificationToAllusers(title, body);
      await functionFCM_token().storeNotifications(title, body);
    } catch (e) {
      print('Failed to delete all documents: $e');
    }
  }
  //Function to modify a date and send a notification to all users
  Future<void> modifyDate(String idDayclicked, Map<String, dynamic> updates, bool islimitchanged) async {
    try {
      // Update the date in Firestore
      await FirebaseFirestore.instance
          .collection('dates')
          .doc(idDayclicked)
          .update(updates);
      print('✅ Document updated successfully');
      String title = "New updates!!";
      String body;
      body = "Appointment has been updated: ${updates['day']} from ${updates['start']} to ${updates['end']}.";
      if (islimitchanged) {  
      body += " Limit has been increased!";
      }
      else {
        body += " Limit has been decreased!";
      }
      
      // Send notification to all users when an admin modifies an appointment
      await functionFCM_token().sendNotificationToAllusers(title, body);
      await functionFCM_token().storeNotifications(title, body);
    } catch (e) {
      print('Failed to update document: $e');
    }
  }
 

  //Show Modify Dialog - Allows admin to modify appointment details
  // Show Modify Dialog - Allows admin to modify appointment details
Future<bool?> showModifyDialog(BuildContext context, String docId, String currentDay, int currentStart, int currentEnd, int currentLimit) async {
  TextEditingController controllerStart = TextEditingController(text: currentStart.toString());
  TextEditingController controllerEnd = TextEditingController(text: currentEnd.toString());
  TextEditingController controllerLimit = TextEditingController(text: currentLimit.toString());

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Modify Day'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controllerStart,
            decoration: const InputDecoration(labelText: 'New Start'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controllerEnd,
            decoration: const InputDecoration(labelText: 'New End'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controllerLimit,
            decoration: const InputDecoration(labelText: 'New Limit'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // إرجاع false عند الإلغاء
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            int newStart = int.tryParse(controllerStart.text.trim()) ?? 0;
            int newEnd = int.tryParse(controllerEnd.text.trim()) ?? 0;
            int newLimit = int.tryParse(controllerLimit.text.trim()) ?? 0;

            if (newStart > 0 && newEnd > 0 && newLimit > 0) {
              bool islimitchanged = newLimit > currentLimit;
              await modifyDate(docId, {
                'day': currentDay,
                'start': newStart,
                'end': newEnd,
                'limit': newLimit
              }, islimitchanged);

              Navigator.pop(context, true); // ✅ إرجاع true عند النجاح
            } else {
              Navigator.pop(context, false); // إرجاع false لو القيم غير صحيحة
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> deleteOldDates() async {
  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // اليوم بدون الوقت

    QuerySnapshot query = await FirebaseFirestore.instance.collection('dates').get();

    for (var doc in query.docs) {
      Timestamp timestamp = doc['fullDate'];
      DateTime date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
      
      if (date.isBefore(today)) {
        await doc.reference.delete();
        print('✅ Deleted past date: ${doc.id}');
      }
    }
    print('✅ Old dates cleanup completed');
  } catch (e) {
    print('❌ Error deleting old dates: $e');
  }
}


}

