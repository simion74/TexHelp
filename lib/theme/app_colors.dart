import 'package:flutter/material.dart';

/// সব ক্যালকুলেটরে ব্যবহৃত কমন কালার প্যালেট।
/// (মূল HTML ফাইলগুলোর CSS ভ্যারিয়েবল থেকে হুবহু নেওয়া, যেন ডিজাইন একই থাকে)
class AppColors {
  AppColors._();

  static const Color darkGreen = Color(0xFF114232);
  static const Color green = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF8BC34A); // lime
  static const Color limeLight = Color(0xFFC0E85A);
  static const Color teal = Color(0xFF00A9FF);
  static const Color tealLight = Color(0xFF4FC3F7);
  static const Color darkTeal = Color(0xFF0D3B2F);
  static const Color darkTealLight = Color(0xFF00796B);
  static const Color purple = Color(0xFF845EC2);
  static const Color purpleLight = Color(0xFFB39DDB);
  static const Color orange = Color(0xFFFF9A56);
  static const Color pink = Color(0xFFFF6F91);

  static const Color gradeAGreen = Color(0xFF2E7D32);
  static const Color gradeAGreenBg = Color(0xFFE8F9D2);
  static const Color gradeBYellow = Color(0xFFF57F17);
  static const Color gradeBYellowBg = Color(0xFFFFFDE7);
  static const Color gradeCRed = Color(0xFFC62828);
  static const Color gradeCRedBg = Color(0xFFFFEBEE);

  static const Color cardBg = Color(0xE0FFFFFF); // rgba(255,255,255,0.88)
  static const Color inputBg = Color(0xFFFAFAFA);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color unitBg = Color(0xFFF3F4F6);
  static const Color dotKeyBg = Color(0xFFE8F9D2);
  static const Color screenBg = Color(0xFFF0F2F5);

  static const LinearGradient homeBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F3D2E), Color(0xFF15563D), Color(0xFF1C7A56)],
  );

  static const LinearGradient homeButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, pink, purple],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA9DF46), green],
  );

  static const LinearGradient resetButtonGradient = LinearGradient(
    colors: [Color(0xFF87A922), Color(0xFF65B741)],
  );

  static const LinearGradient greenIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, green],
  );
  static const LinearGradient tealIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealLight, teal],
  );
  static const LinearGradient darkTealIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTealLight, darkTeal],
  );
  static const LinearGradient limeIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [limeLight, lightGreen],
  );
  static const LinearGradient purpleIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleLight, purple],
  );
}
