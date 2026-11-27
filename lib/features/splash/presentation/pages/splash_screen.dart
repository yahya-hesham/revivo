import 'package:flutter/material.dart';

/// Placeholder entry screen. Will be implemented in the Auth/Splash milestone.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Revivo',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
