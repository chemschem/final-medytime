import 'package:flutter/material.dart';
import 'package:meditime/api/function_session.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/pages/assistant_pages/settings/edit_clinic_info.dart';
import 'package:meditime/widgets/confirmeLogout.dart';
class setting_assistant extends StatelessWidget {
  const setting_assistant({super.key});

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
                automaticallyImplyLeading: false, // This removes the back arrow
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
                    child: Center(child: Text("General Settings")),
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
        _buildSectionHeader('Settings'),
        _buildSettingItem(
          icon: Icons.business,
          title: 'Edit Clinic Information',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => edit_clinic_info()),
            );
          },
        ),
       
        _buildSettingItem(
          icon: Icons.language,
          title: 'Change Language',
          onTap: () {
            // Add language change logic later
          },
        ),
        _buildSettingItem(
          icon: Icons.settings,
          title: 'additional settings',
          onTap: () {
            Navigator.pushNamed(context, '/additional_settings');
          },
        ),
        const Divider(height: 40),
        _buildSettingItem(
  icon: Icons.logout,
  title: 'Log Out',
  iconColor: AppColors.errorColor,
  textColor: AppColors.errorColor,
  onTap: () {
    final parentContext = context; // احفظ السياق الأساسي
    showDialog(
      context: parentContext,
      builder: (dialogContext) => ConfirmLogout(
        date: '', // احذفها إذا لم تكن مستخدمة
        onCancel: () => Navigator.of(dialogContext).pop(),
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          function_session().logout(parentContext); // استخدم السياق المحفوظ
        },
      ),
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