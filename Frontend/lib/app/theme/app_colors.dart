import 'package:flutter/material.dart';

/// Token warna Gadaikan.
///
/// Sumber: DESIGN_Gadaikan.md bagian 2.1.
/// Jangan memakai gold untuk teks kecil di atas latar putih karena
/// kontrasnya rendah.
class AppColors {
  const AppColors._();

  // Primary navy blue
  static const Color primary = Color(0xFF173B66);
  static const Color primaryDark = Color(0xFF102B4C);
  static const Color primarySoft = Color(0xFFEAF1F8);

  // Accent gold
  static const Color gold = Color(0xFFD9A441);
  static const Color goldSoft = Color(0xFFFBF3E2);
  static const Color goldDark = Color(0xFFB8862F);

  // Backgrounds
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F3F8);

  // Text
  static const Color textPrimary = Color(0xFF17212F);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF16865B);
  static const Color successSoft = Color(0xFFE7F5EF);
  static const Color warning = Color(0xFFC98216);
  static const Color warningSoft = Color(0xFFFCF3E3);
  static const Color danger = Color(0xFFC83E4D);
  static const Color dangerSoft = Color(0xFFFBECEE);
  static const Color info = Color(0xFF3478C8);
  static const Color infoSoft = Color(0xFFEAF2FC);

  // Border / divider
  static const Color border = Color(0xFFE4E8EF);
  static const Color borderStrong = Color(0xFFCBD3DF);

  // Utility
  static const Color disabled = Color(0xFFB8C0CC);
  static const Color overlay = Color(0x6610212F);

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primary, Color(0xFF0B2038)],
  );
}
