import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/functionFCM_token.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;                      // ← استيراد extra
import 'routers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1) تهيئة الـ timezones وتحديد الموقع المحلي
  tzData.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Algiers'));            // ← اختر الموقع المناسب

  // 2) تهيئة إشعارات الجهاز
  functionFCM_token fcmHandler = functionFCM_token();
  await fcmHandler.initializeNotifications();                       // داخلها: flutterLocalNotificationsPlugin.initialize()
  await fcmHandler.requestPermission();
  await fcmHandler.getToken();
  fcmHandler.listenForMessages();

   /// ✅ يجب أن تكون هنا فقط
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: appRouter.generateRoutes,
      initialRoute: '/',
    );
  }
}
