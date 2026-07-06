import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.public,
                size: 120,
              ),

              SizedBox(height: 30),

              Text(
                "ATLAS",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Your life, organized intelligently.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 60),

              ElevatedButton(
                onPressed: () {},

                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  child: Text("Get Started"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}