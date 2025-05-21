import 'package:flutter/material.dart';
import 'package:meditime/home.dart';
import 'package:meditime/pages/assistant_pages/settings/additional_settings.dart';
import 'package:meditime/pages/assistant_pages/settings/edit_defult_times.dart';
import 'package:meditime/pages/assistant_pages/settings/edit_limits.dart';
import 'package:meditime/pages/patient_pages/clinicInfo.dart';
import 'package:meditime/pages/assistant_pages/add_monthly_appoint.dart';
import 'package:meditime/pages/assistant_pages/settings/edit_clinic_info.dart';
import 'package:meditime/pages/assistant_pages/show_calendar.dart';
import 'package:meditime/pages/assistant_pages/consulting.dart';
import 'package:meditime/pages/assistant_pages/home_assistant.dart';
import 'package:meditime/pages/assistant_pages/setting_assistant.dart';
import 'package:meditime/pages/assistant_pages/show_archiv.dart';
import 'package:meditime/pages/patient_pages/appointment_state_patient.dart';
import 'package:meditime/pages/patient_pages/book_appoint.dart';
import 'package:meditime/pages/patient_pages/home_patient.dart';
import 'package:meditime/pages/patient_pages/notifications_patient.dart';
import 'package:meditime/pages/patient_pages/patient_profil.dart';
import 'package:meditime/pages/patient_pages/patient_settings.dart';
import 'package:meditime/routers/testcode.dart';
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
      
       case '/home_assistant':
       return MaterialPageRoute(builder: (_) => const home_assistant());
         case '/home_patient':
       return MaterialPageRoute(builder: (_) => const home_patient());
        case '/appointment_state_patient':
       return MaterialPageRoute(builder: (_) => const appointment_state_patient());
       case '/show_archiv':
       return MaterialPageRoute(builder: (_) => const show_archiv());
       case '/notifications_patient':
       return MaterialPageRoute(builder: (_) => const notifications_patient());
       case '/setting_assistant':
       return MaterialPageRoute(builder: (_) => const setting_assistant());
       case '/show_calendar':
       return MaterialPageRoute(builder: (_) => show_calendar());
       case '/consulting':
       return MaterialPageRoute(builder: (_) => const consulting());
       case '/add_monthly_appoint':
       return MaterialPageRoute(builder: (_) => add_monthly_appoint());
        case '/clinicInfo':
        return MaterialPageRoute(builder: (_) => const clinicInfo());
        case '/edit_clinic_info':
        return MaterialPageRoute(builder: (_) => const edit_clinic_info());
        case '/PatientProfil':
        return MaterialPageRoute(builder: (_) => const PatientProfil());
        case '/additional_settings':
        return MaterialPageRoute(builder: (_) => const additional_settings());
        case '/edit_limits':
        return MaterialPageRoute(builder: (_) => const edit_limits());
        case '/edit_defult_times':
        return MaterialPageRoute(builder: (_) => const edit_defult_times());
        case '/patient_settings':
        return MaterialPageRoute(builder: (_) => const patient_settings());
       



       case '/testcode':
       return MaterialPageRoute(builder: (_) => testcode());

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
