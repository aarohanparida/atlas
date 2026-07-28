import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/primary_button.dart';

class CreateMemoryScreen extends StatelessWidget {
  const CreateMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "New Memory",
          style: AppText.title,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Memory Title",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 8),
              _textField(
                hint: "Trip to Rhode Island",
              ),

              const SizedBox(height: 24),

              const Text(
                "Description",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 8),
              _textField(
                hint: "Tell the story...",
                maxLines: 5,
              ),

              const SizedBox(height: 24),

              const Text(
                "Photos",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 42,
                        ),
                        SizedBox(height: 12),
                        Text("Add Photos"),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Date",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 8),
              _textField(
                hint: "July 13, 2026",
              ),

              const SizedBox(height: 24),

              const Text(
                "Location",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 8),
              _textField(
                hint: "South Windsor, CT",
              ),

              const SizedBox(height: 24),

              const Text(
                "People",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 8),
              _textField(
                hint: "Add friends or family",
              ),

              const SizedBox(height: 24),

              const Text(
                "Tags",
                style: AppText.subtitle,
              ),
              const SizedBox(height: 8),
              _textField(
                hint: "Vacation, Beach, Summer",
              ),

              const SizedBox(height: 40),

              PrimaryButton(
                text: "Save Memory",
                onPressed: () {
                  // TODO: Save later
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _textField({
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}