import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ✅ دالة استقبال الرسائل في الخلفية (توضع خارج الكلاس)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message received: ${message.messageId}");
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message received: ${message.messageId}");
}


class functionFCM_token {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// تهيئة الإشعارات
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initializationSettings);
  }

  /// طلب صلاحيات الإشعارات
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

  /// جلب الـ FCM Token
  Future<void> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("📌 FCM Token: $token");
  }

  /// حفظ الـ Token في قاعدة البيانات
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

  /// الاستماع للرسائل داخل التطبيق
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

   
  }

  /// حفظ الإشعارات في Firestore
  Future<void> storeNotifications(String title, String body) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'id_notification': '${title}_${DateTime.now()}',
      'read': false,
    }).then((_) {
      print("✅ Notification saved in Firestore");
    }).catchError((error) {
      print("❌ Error saving notification: $error");
    });
  }

  /// عرض إشعار محلي
  Future<void> showNotification(String? title, String? body) async {
    if (title == null || body == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  /// إرسال إشعار لكل المستخدمين (يتطلب Cloud Functions للإرسال الحقيقي)
  Future<void> sendNotificationToAllusers(String title, String body) async {
    QuerySnapshot userDocs = await FirebaseFirestore.instance.collection('user').get();

    for (var doc in userDocs.docs) {
      String? token = doc['fcmToken'];
      if (token != null) {
        print("📲 Sending to token: $token");
        sendFcmNotification(token, title, body);
      }
    }
  }

  /// ⚠️ هذه الدالة لا ترسل إشعار فعلي. استخدم Cloud Functions أو API لهذا الغرض.
  Future<void> sendFcmNotification(String token, String title, String body) async {
    print("📤 [Simulated] Send to: $token => $title | $body");
    // هنا يمكن الربط مع Cloud Functions مستقبلًا
  }

  /// تعليم الإشعار كمقروء
  void markNotificationAsRead(String idNotification) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(idNotification)
        .update({'read': true});
  }
}
