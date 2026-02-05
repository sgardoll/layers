import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final Widget child;
  final bool isInitialized;

  const SplashScreen({
    super.key,
    required this.child,
    required this.isInitialized,
  });

  static const Color backgroundColor = Color(0xFF010136);

  @override
  Widget build(BuildContext context) {
    if (isInitialized) {
      return child;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Image.asset(
          'assets/splash.gif',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
