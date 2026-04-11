import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final int navIndex;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.navIndex,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(title,
          style: const TextStyle(
            fontFamily: 'Poppins', color: Colors.white,
            fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: navIndex),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64,
              color: AppColors.primary.withOpacity(0.25)),
            const SizedBox(height: 16),
            Text(title,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 20,
                fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Text('Coming soon',
              style: TextStyle(fontFamily: 'Poppins',
                fontSize: 13, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}