import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditime/api/functionFCM_token.dart';
import 'package:meditime/core/theme/colors.dart'; 

class notifications_patient extends StatefulWidget {
  const notifications_patient({super.key});

  @override
  notifications_patientState createState() => notifications_patientState();
}

class notifications_patientState extends State<notifications_patient> {
  Set<String> selectedNotifications = {}; // Store selected notifications in a set????
  
  String getTimeLabel(DateTime time) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(time); // needs intl package
  }
  // String getTimeLabel(DateTime time) {
//   DateTime now = DateTime.now();
//   DateTime today = DateTime(now.year, now.month, now.day);
//   DateTime yesterday = today.subtract(Duration(days: 1));
//   DateTime notificationDate = DateTime(time.year, time.month, time.day);

//   if (notificationDate.isAtSameMomentAs(today)) {
//     return "Today";
//   } else if (notificationDate.isAtSameMomentAs(yesterday)) {
//     return "Yesterday";
//   } else {
//     return "${time.day}/${time.month}/${time.year}";
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text("notifications", 
        style: TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold),      
      ),),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true) // order by timestamp
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications found"));
          }
          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];             
              String notificationId = notification.id; // Get document ID from snapshot
              String title = notification['title'] ?? "no title";
              String body = notification['body'] ?? "no body";
              Timestamp? timestamp = notification['timestamp'] as Timestamp?;
              bool isRead = notification['read'] ?? false; // Get read status from Firestore

              String timeLabel = timestamp != null
                  ? getTimeLabel(timestamp.toDate())
                  : "no time";


              return GestureDetector( //GestureDetector is a Flutter widget that detects user gestures, such as taps, swipes, and long presses.
                 onTap: () {// onTap is a function that is called when the user taps the widget.
                  setState(() {// is called to update the UI dynamically.
                  functionFCM_token().markNotificationAsRead(notificationId); 
                  });
                  Navigator.pushNamed(context,'/book_appoint',
                    arguments: {
                      'title': title,
                      'body': body,
                      'timeLabel': timeLabel,
                    },
                  );
                },
                child: Container(
                  color: isRead ? Colors.white : const Color.fromARGB(255, 226, 228, 255), // Change color on click
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          timeLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications, color: Colors.blue),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(body),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
