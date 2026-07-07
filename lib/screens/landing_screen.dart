import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/atlas_logo.dart';
import '../widgets/primary_button.dart';
import 'auth_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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

              
              Hero(
                tag: 'atlasLogo',
                child: const AtlasLogo(size: 140)
                    .animate()
                    .fade(duration: 700.ms)
                    .rotate(
                      begin: -0.25, // -90°
                      end: 0,
                      duration: 900.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
          

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "The home for every",
                  style: AppText.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),

              const Center(
                child: Text(
                  "memory.",
                  style: AppText.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              PrimaryButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                  HapticFeedback.lightImpact(); 
                },
              ),

              const SizedBox(height: 50),
            ],
          )
        ),
      ),
    );
  }
}