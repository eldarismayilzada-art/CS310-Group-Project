import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, fontFamily: 'Poppins',
  );
  static const body = TextStyle(
    fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Poppins',
  );
  static const muted = TextStyle(
    fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins',
  );
}