import 'package:flutter/material.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/pages/assistant_pages/settings/edit_defult_times.dart';
import 'package:meditime/pages/assistant_pages/settings/edit_limits.dart';
import 'package:meditime/pages/assistant_pages/show_archiv.dart';
class additional_settings extends StatelessWidget {
  const additional_settings({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: isLargeScreen
            ? null
            : AppBar(
                automaticallyImplyLeading: false, // This removes the back arrows             
                centerTitle: true,
                backgroundColor: AppColors.primaryColor,
                iconTheme: const IconThemeData(color: AppColors.whiteColor),
              ),
        body: SafeArea(
          child: Row(
            children: [
              if (isLargeScreen)
                const SizedBox(
                  width: 200,
                  child: Drawer(
                    child: Center(child: Text("Settings")),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 40 : 16,
                    vertical: 20,
                  ),
                  child: _buildSettingsList(context),
                ),
              ),
            ],
          ),
        ),


        // Bottom Navigation Bar

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
currentIndex: 2, // Set the current index to highlight the active tab
  selectedItemColor: Colors.blue, // Color for the selected item
  unselectedItemColor: Colors.grey, // Color for unselected items
               backgroundColor: AppColors.backgroundColor,

       onTap: (index) {
        // Handle navigation based on the selected index
        if (index == 0) {
          Navigator.pushNamed(context, '/home_assistant');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/show_calendar');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/setting_assistant');
        }
        

      },
    ),
    
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return ListView(
      children: [
        _buildSectionHeader('Additional settings'),
        _buildSettingItem(
          icon: Icons.numbers,
          title: 'Paients limits',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => edit_limits()),
            );
          },
        ),
       
        _buildSettingItem(
          icon: Icons.hourglass_bottom,
          title: 'Default times',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => edit_defult_times()),
            );
          },
        ),
        _buildSettingItem(
          icon: Icons.archive,
          title: 'Achived appointments',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => show_archiv()),
            );
          },
        ),     
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.primaryColor,
    Color textColor = AppColors.textColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        onTap: onTap,
      ),
    );
  }
}