import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/atlas_logo.dart';
import '../widgets/social_button.dart';

import '../screens/permissions/photos_permission_screen.dart';
import 'email_auth_screen.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

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
              const SizedBox(height: 60),

              const Center(
                child: AtlasLogo(size: 140),
              ),

              const SizedBox(height: 40),

              const Text(
                "Your memories are waiting.",
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              SocialButton(
                icon: SvgPicture.asset(
                  'assets/images/apple.svg',
                  width: 22,
                  height: 22,
                ),
                text: "Continue with Apple",
                onPressed: () {
                  // TODO: hook up Apple sign-in
                  HapticFeedback.lightImpact();
                },
              ),

              const SizedBox(height: 16),

              SocialButton(
                icon: SvgPicture.asset(
                  'assets/images/google.svg',
                  width: 20,
                  height: 20,
                ),
                text: "Continue with Google",
                onPressed: () {
                  HapticFeedback.lightImpact();
                }
              ),

              const SizedBox(height: 16),

              SocialButton(
                icon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                text: "Continue with Email",
                onPressed: () {
                  HapticFeedback.lightImpact();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmailAuthScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Text(
                "By continuing, you agree to the Terms of Service and Privacy Policy.",
                textAlign: TextAlign.center,
                style: AppText.subtitle.copyWith(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}