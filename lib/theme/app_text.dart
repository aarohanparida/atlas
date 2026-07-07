import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  static const TextStyle title = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: 8,
    color: AppColors.text,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    color: AppColors.secondaryText,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );
}