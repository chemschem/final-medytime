import 'package:flutter/material.dart';
import 'package:meditime/home.dart';
import 'package:meditime/pages/assistant_pages/add_monthly_appoint.dart';
import 'package:meditime/pages/assistant_pages/show_weekly_appoint.dart';
import 'package:meditime/pages/assistant_pages/consulting.dart';
import 'package:meditime/pages/assistant_pages/home_assistant.dart';
import 'package:meditime/pages/assistant_pages/setting_assistant.dart';
import 'package:meditime/pages/assistant_pages/show_appoint.dart';
import 'package:meditime/pages/assistant_pages/show_archiv.dart';
import 'package:meditime/pages/assistant_pages/show_dates_assist.dart';
import 'package:meditime/pages/patient_pages/appointment_state_patient.dart';
import 'package:meditime/pages/patient_pages/book_appoint.dart';
import 'package:meditime/pages/patient_pages/home_patient.dart';
import 'package:meditime/pages/patient_pages/notifications_patient.dart';
import '../pages/test_firebase.dart';
import '../pages/signup_page.dart';
import '../pages/login_page.dart';
import '../pages/assistant_pages/add_weekly_appoint.dart';

class AppRouter {
  Route generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
       return MaterialPageRoute(builder: (_) => const Home());
       case '/signup_page':
       return MaterialPageRoute(builder: (_) => const signup_page());
       case '/login_page':
       return MaterialPageRoute(builder: (_) => const login_page());       
       case '/add_weekly_appoint':
       return MaterialPageRoute(builder: (_) =>add_weekly_appoint());              
       case '/book_appoint':
       return MaterialPageRoute(builder: (_) =>book_appoint());
       case '/show_appoint':
       return MaterialPageRoute(builder: (_) => show_appoint());
       case '/home_assistant':
       return MaterialPageRoute(builder: (_) => home_assistant());
        case '/show_dates_assist':
       return MaterialPageRoute(builder: (_) => show_dates_assist());
        case '/home_patient':
       return MaterialPageRoute(builder: (_) => home_patient());
        case '/appointment_state_patient':
       return MaterialPageRoute(builder: (_) => appointment_state_patient());
       case '/show_archiv':
       return MaterialPageRoute(builder: (_) => show_archiv());
       case '/notifications_patient':
       return MaterialPageRoute(builder: (_) => notifications_patient());
       case '/setting_assistant':
       return MaterialPageRoute(builder: (_) => setting_assistant());
       case '/show_weekly_appoint':
       return MaterialPageRoute(builder: (_) => show_weekly_appoint());
       case '/consulting':
       return MaterialPageRoute(builder: (_) => consulting());
       case '/add_monthly_appoint':
       return MaterialPageRoute(builder: (_) => add_monthly_appoint());
       case 'test':
       return MaterialPageRoute(builder: (_) => const TestFireBase());
        // const Dart requires that const constructors must have all their fields marked as final and initialized.??
        //or Add const to the constructor.Make sure all fields are marked final and initialized.


      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
