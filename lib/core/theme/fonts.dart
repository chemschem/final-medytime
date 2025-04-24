import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Istok Web';

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFF4A4A4A), // النص بلون ثابت
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF4A4A4A),
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Color(0xFF4A4A4A),
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A4A4A),
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white, // نص الأزرار أبيض
  );
}
