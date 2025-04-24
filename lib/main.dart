import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/functionFCM_token.dart';
import 'routers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  functionFCM_token fcmHandler = functionFCM_token();
  await fcmHandler.initializeNotifications();
  await fcmHandler.requestPermission();
  fcmHandler.getToken();
  fcmHandler.listenForMessages(); 
  //fcmHandler.listenForAdminUpdates(); //  go to functionFCM_token.dart to see the implementation

  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,//remove debug banner
      onGenerateRoute: appRouter.generateRoutes,
      initialRoute: '/',
    );
  }
}
