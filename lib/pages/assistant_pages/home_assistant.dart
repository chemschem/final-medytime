import 'package:flutter/material.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';

class home_assistant extends StatefulWidget {
  const home_assistant({super.key});

  @override
  State<home_assistant> createState() => _home_assistantState();
}

class _home_assistantState extends State<home_assistant> {
  //updating dates
  // This function will be called when the widget is first created
  @override
  void initState() {
    super.initState();
    function_date().deleteOldDates();// This will delete old dates
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          automaticallyImplyLeading: false, // This removes the back arrow
        title: const Text(
          'Home',
          style: TextStyle(
          color: AppColors.whiteColor,
          fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
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
                
Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                 child: Padding(
      padding: const EdgeInsets.all(100.0), // Adjust the value as needed
      child: Image.asset(
        "assets/images/logo.png",
        fit: BoxFit.contain,
        width: 400,
      ),
    ),
                ),
              ),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildCard(context, 'Add Appointments', Icons.calendar_today, '/add_weekly_appoint'),
                    _buildCard(context, 'Appointments', Icons.view_week, '/show_calendar'),
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

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0, // Set the current index to highlight the active tab
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        backgroundColor: AppColors.backgroundColor,
        onTap: (index) {
          // Handle navigation based on the selected index
          if (index == 0) {
            // Stay on the current page
          } else if (index == 1) {
            Navigator.pushNamed(context, '/show_calendar');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/setting_assistant');
          }
        },
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
        splashColor: AppColors.primaryColor.withOpacity(0.2),
        highlightColor: AppColors.primaryColor.withOpacity(0.1),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryColor),
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
      
    );
  }
}