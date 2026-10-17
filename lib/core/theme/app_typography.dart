import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String display = 'SpaceGrotesk';
  static const String body = 'Archivo';

  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontSize: 40,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: AppColors.text,
      ),
      displayMedium: TextStyle(
        fontFamily: display,
        fontSize: 30,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.text,
      ),
      headlineMedium: TextStyle(
        fontFamily: display,
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.text,
      ),
      titleLarge: TextStyle(
        fontFamily: body,
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontFamily: body,
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(
        fontFamily: body,
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSoft,
      ),
      bodyMedium: TextStyle(
        fontFamily: body,
        fontSize: 13.5,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: AppColors.textSoft,
      ),
      labelLarge: TextStyle(
        fontFamily: body,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.text,
      ),
      labelSmall: TextStyle(
        fontFamily: body,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: AppColors.textSoft,
      ),
    );
  }

  static const TextStyle eyebrow = TextStyle(
    fontFamily: body,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.2,
    color: AppColors.textSoft,
  );
}
