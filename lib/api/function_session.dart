 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:meditime/widgets/showMessage.dart';

class function_session{

 Future<bool> login(String email, String password, BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (email.isEmpty || password.isEmpty) {
     ShowMessage.showError(context, "Please enter email and password");
      return false;
    }

    try {
      var userQuery = await firestore
          .collection("user")
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password)
          .get();
      if (userQuery.docs.isNotEmpty) {
         ShowMessage.showValid(context, "Login Successful");
        return true;
      } else {
         ShowMessage.showError(context, "Invalid Email or Password");
        return false;
      }
    } catch (e) {
       ShowMessage.showError(context, "Error: ${e.toString()}");
      return false;
    }
  }
 


   Future<void> go_page(BuildContext context, String email, String password, String currentUserId) async {
    if(email == 'admin' && password == 'admin'){
      Navigator.pushReplacementNamed(context,'/home_assistant');
    }else{
      Navigator.pushReplacementNamed(context,'/home_patient');      
  }
}

Future<String?> fetchUserId(String email) async {
  try {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();
        //Store the ID globally
        if (query.docs.isNotEmpty) {     
          globals.currentUserId= query.docs.first['id_user'];
          print('User ID fetched and stored globally: ${globals.currentUserId}');
          return globals.currentUserId;
        }
      } catch (e) {
        print('Error fetching user ID: $e');
      }
      return null;
    }
    
  void logout(BuildContext context) {
    //Clear global user ID

    globals.currentUserId = null;
    // Clear any locally stored data (optional)
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    //Navigate to login page
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login_page', 
      (route) => false, // Remove all previous routes from the stack
    );
  }
}