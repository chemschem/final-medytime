import 'package:flutter/material.dart';

class AppStyles {
  // ستايل زر تسجيل الدخول
  //static final ButtonStyle loginButtonStyle = ElevatedButton.styleFrom(
  static ButtonStyle buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(299, 78),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
  
  // Border Radius
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radius30 = BorderRadius.all(Radius.circular(30));
  static const BorderRadius radius55 = BorderRadius.all(Radius.circular(55));
  static const BorderRadius radius125 = BorderRadius.all(Radius.circular(125));

  // Padding
  static const EdgeInsets horizontalPadding32 =
      EdgeInsets.symmetric(horizontal: 32);
  static const EdgeInsets verticalPadding16 =
      EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets horizontalPadding24 =
      EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets verticalPadding28 =
      EdgeInsets.symmetric(vertical: 28);

  // Space
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space49 = 49;
  static const double space104 = 104;

  // Shadow
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
