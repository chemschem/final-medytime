import 'package:flutter/material.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/api/function_session.dart';
import 'package:meditime/core/theme/colors.dart';
import '../../../core/theme/styles.dart'; // تأكد أنك تضيف ملف ستايلات الأزرار هنا لو تستعمله

class home_patient extends StatefulWidget {
  const home_patient({super.key});

  @override
  _home_patientState createState() => _home_patientState();
}

class _home_patientState extends State<home_patient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
       Padding(//one row
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Welcome text with icon
      Row(
        children: [
          const Icon(Icons.person, color: AppColors.primaryColor, size: 40),
          const SizedBox(width: 10),
          FutureBuilder<String>(
            future: api_functions().fetchCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              } else {
                return Text(
                  "Welcome, ${snapshot.data}!",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
            },
          ),
        ],
      ),
      // Notifications button
      IconButton(
        icon: const Icon(Icons.notifications, size: 40, color: AppColors.primaryColor),
        onPressed: () => Navigator.pushNamed(context, '/notifications_patient'),
      ),
    ],
  ),
  ),

            const SizedBox(height: 30),

            //Two colored boxes side by side
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSquareButton(
                    context,
                    color: AppColors.secondColor,
                    icon: Icons.event_note,
                    label: "My Appointment",
                    onTap: () => Navigator.pushNamed(context, '/appointment_state_patient'),
                  ),
                  _buildSquareButton(
                    context,
                    color: AppColors.primaryColor,
                    icon: Icons.info,
                    label: "About clinic",
                    onTap: () => Navigator.pushNamed(context, '/clinicInfo'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Centered image or content container
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.contain,
                    width: 200,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Bottom buttons (New Appointment + Logout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/book_appoint'),
                      style: AppStyles.HomebuttonStyle(AppColors.primaryColor),
                      child: const Text(
                        "NEW APPOINTMENT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                 
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
        currentIndex: 0, // Set the current index to highlight the active tab
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
               backgroundColor: AppColors.backgroundPrimary,

        onTap: (index) {
          // Handle navigation based on the selected index
          if (index == 0) {
            // Stay on the current page
          }  else if (index == 1) {
            Navigator.pushNamed(context, '/patient_settings');
          }
        },
      ),




    );
  }

  // 🔹 Customized square buttons
  Widget _buildSquareButton(BuildContext context,
      {required Color color, required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
