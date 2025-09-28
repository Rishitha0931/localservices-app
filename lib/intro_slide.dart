import 'package:flutter/material.dart';
import 'animations.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              HandshakeFadeIn(
                assetPath: 'assets/animations/handshake.gif',
                height: 200,
              ),
              SizedBox(height: 40),
              Text(
                "TRUSTED Local Services",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Verified vendors.\nReal reviews.\nSafe bookings.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}