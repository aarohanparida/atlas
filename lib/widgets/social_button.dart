import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// A dark, pill-shaped button used for third-party sign-in options
/// (Apple, Google, Facebook, etc). Icon sits on the left, text is centered.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          foregroundColor: AppColors.buttonText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        // Stack lets us pin the icon to the left while keeping the text
        // centered in the button, independent of icon width.
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 22),
                child: icon,
              ),
            ),
            Text(text, style: AppText.button),
          ],
        ),
      ),
    );
  }
}