import 'package:flutter/material.dart';
import 'package:meditime/api/function_session.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/core/theme/colors.dart';

class home_patient extends StatefulWidget {
  const home_patient({Key? key});

  @override
  _home_patientState createState() => _home_patientState();
}

class _home_patientState extends State<home_patient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'User ID: ${globals.currentUserId}',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildCard(context, 'Book Appointment', Icons.event_note, '/book_appoint'),
                    _buildCard(context, 'My Appointments', Icons.calendar_today, '/appointment_state_patient'),
                    _buildCardWithIcon(context, 'Notifications', Icons.notifications, '/notifications_patient'),
                    _buildCardWithIcon(context, 'Logout', Icons.logout, '/logout', isLogout: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بطاقة مع الأيقونات والنصوص
  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withOpacity(0.2),
        highlightColor: AppColors.primary.withOpacity(0.1),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بطاقة تسجيل الخروج مع أيقونة خاصة
  Widget _buildCardWithIcon(BuildContext context, String title, IconData icon, String route, {bool isLogout = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: isLogout ? Colors.red.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
        highlightColor: isLogout ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
        onTap: () {
          if (isLogout) {
            function_session().logout(context);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isLogout ? Colors.red : AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.red : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
