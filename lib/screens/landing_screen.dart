import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/atlas_logo.dart';
import '../widgets/primary_button.dart';
import 'auth_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import '../widgets/animated_globe.dart';
// import '../widgets/atlas_text.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 90),

              
              const AtlasLogo(size: 170)
                .animate()
                .fade(
                  duration: 700.ms,
                  curve: Curves.easeOut,
                )
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.0, 1.0),
                  duration: 700.ms,
                  curve: Curves.easeOutCubic,
                ),

              const SizedBox(height: 30),


              Text(
                "The home for every",
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              )
                .animate(delay: 1200.ms)
                .fade(),
        


              Text(
                "memory.",
                style: AppText.subtitle,
                textAlign: TextAlign.center,
              )
                .animate(delay: 1200.ms)
                .fade(),


              const Spacer(),

              PrimaryButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthScreen(),
                    ),
                  );
                  HapticFeedback.lightImpact(); 
                },
              )
                .animate(delay: 1500.ms)
                .fade()
                .moveY(begin: 25),

              const SizedBox(height: 50),
            ],
          )
        ),
      ),
    );
  }
}