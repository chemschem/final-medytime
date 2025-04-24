import 'package:flutter/material.dart';
import 'package:meditime/api/function_session.dart';


class setting_assistant extends StatefulWidget {
  const setting_assistant({Key? key}) : super(key: key);

  @override
  setting_assistantState createState() => setting_assistantState();
}

class setting_assistantState extends State<setting_assistant> { 
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          menuItem(Icons.person, "Profile", () {
            Navigator.pushNamed(context, "/profile");
          }),
          menuItem(Icons.event, "Appointments", () {
            Navigator.pushNamed(context, "/appointments");
          }),
          menuItem(Icons.exit_to_app, "Logout", () {         
          function_session().logout(context);  
          }),              
        ],
      ),
    );
  }

  // Menu item widget
  Widget menuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}