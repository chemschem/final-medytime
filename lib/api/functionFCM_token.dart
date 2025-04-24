import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class functionFCM_token {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =FlutterLocalNotificationsPlugin();

  ///Initialize Notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initializationSettings);
    }

  ///Request Notification Permissions
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notification permission granted.");
    } else {
      print("❌ Notification permission denied.");
    }
  }

  ///Get and Save FCM Token
  Future<void> getToken() async {
  String? token = await _firebaseMessaging.getToken();
  print("📌 FCM Token: $token");
  }
  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token == null) {
      print("❌ Error: Could not retrieve FCM token");
      return;
    }
    print("📌 Retrieved FCM Token: $token");

    await FirebaseFirestore.instance.collection('user').doc(userId).update({
      'fcmToken': token,
    }).then((_) {
      print("✅ FCM Token saved in Firestore");
    }).catchError((error) {
      print("❌ Error saving token to Firestore: $error");
    });
  }

  ///Listen for Incoming Messages
  void listenForMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Received a notification in foreground!");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      storeNotifications(
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No Body",
      );
      showNotification(message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Store Notification in Firestore
  Future<void> storeNotifications(String title, String body) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(), //timestamp of the server
      'id_notification':title+'_'+DateTime.now().toString(),
      'read': false, 
    }).then((_) {
      print("✅ Notification saved in Firestore");
    }).catchError((error) {
      print("❌ Error saving notification: $error");
    });
  }

  /// Show Local Notification
  Future<void> showNotification(String? title, String? body) async {
    if (title == null || body == null) return;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  ///Firestore Listener for Admin Updates (If you ever need automatic updates from Firestore 
  ///(for example, if another admin updates the database from a different device), you can always bring it back!)
  // void listenForAdminUpdates() {
  //   FirebaseFirestore.instance.collection('dates').snapshots().listen(
  //     (QuerySnapshot snapshot) {
  //       for (var change in snapshot.docChanges) {
  //         if (change.type == DocumentChangeType.added) {
  //           print("🔔 New document added: ${change.doc.data()}");
  //           sendNotificationToAllusers("New Appointment", "An admin added an appointment.");
  //         } else if (change.type == DocumentChangeType.modified) {
  //           print("🔔Appointment Updated : ${change.doc.data()}");
  //           sendNotificationToAllusers("Appointment Updated", "An admin modified an appointment.");
  //         } else if (change.type == DocumentChangeType.removed) {
  //           sendNotificationToAllusers("delete Appointment", "An admin delete an appointment.");
  //           sendNotificationToAllusers("Appointment Removed", "An admin deleted an appointment.");
  //         }
  //       }
  //     },
  //   );
  // }

  /// Send Notification to All users
  Future<void> sendNotificationToAllusers(String title, String body) async {
    QuerySnapshot userDocs = await FirebaseFirestore.instance.collection('user').get();
    for (var doc in userDocs.docs) {
      String? token = doc['fcmToken']; // Get stored FCM token
      if (token != null) {
        print("📲 Sending to token: $token");
        sendFcmNotification(token, title, body);
      }
    }
  }
 ///Send FCM Notification real push notifications!!!!!!!!!!!!
  Future<void> sendFcmNotification(String token, String title, String body) async {
    // ignore: deprecated_member_use
    await FirebaseMessaging.instance.sendMessage(
      to: token,
      data: {
        'title': title,
        'body': body,
      },
    );
  }
 

  /// ✅ Background Message Handler????????????????????????????????????????????????????????
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message received: ${message.messageId}");
}

  void markNotificationAsRead(String id_notification) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(id_notification)
        .update({'read': true}); // Update Firestore document
  }

}

