import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class CustomTextField_1 extends StatelessWidget {
  final TextEditingController controller;
    final bool isadd;

  final String labelText;
  final bool obscureText;
  final Widget? suffixIcon; // ✅ جديد
  const CustomTextField_1({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon, // ✅ جديد
    this.isadd = false,


  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 78,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: const TextStyle(
              color: Color.fromARGB(255, 147, 147, 147),
              fontSize: 15,
              fontWeight: FontWeight.normal),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: AppColors.strokeColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: AppColors.fieldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

