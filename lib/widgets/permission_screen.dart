import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'primary_button.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String iconPath;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 90),

              SvgPicture.asset(
                iconPath,
                width: 150,
              ),

              const SizedBox(height: 40),

              Text(
                title,
                style: AppText.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                subtitle,
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              PrimaryButton(
                text: buttonText,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onPressed();
                },
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}