import 'package:flutter/material.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/api/function_session.dart';

class home_assistant extends StatelessWidget {
  const home_assistant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Home Assistant',
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
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildCard(context, 'Show Booked Appointments', Icons.event_note, '/show_appoint'),
                    _buildCard(context, 'Add Weekly Appointments', Icons.calendar_today, '/add_weekly_appoint'),
                    _buildCard(context, 'Add Monthly Appointments', Icons.calendar_month, '/add_monthly_appoint'),
                    _buildCard(context, 'Dates To Be Confirmed', Icons.watch_later_outlined, '/show_dates_assist'),
                    _buildCard(context, 'Archive', Icons.archive, '/show_archiv'),
                    _buildCard(context, 'Settings', Icons.settings, '/setting_assistant'),
                    _buildCard(context, 'Show Weekly Appointments', Icons.view_week, '/show_weekly_appoint'),
                    _buildCard(context, 'Consulting', Icons.chat_bubble_outline, '/consulting'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLogoutCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بطاقة بقية الأقسام
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

  // بطاقة تسجيل الخروج
  Widget _buildLogoutCard(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.red.withOpacity(0.2),
        highlightColor: Colors.red.withOpacity(0.1),
        onTap: () => function_session().logout(context),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
