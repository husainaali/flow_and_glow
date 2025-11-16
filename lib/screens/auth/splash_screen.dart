import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Image.asset(
          'assets/images/FlowGlowLogo.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
