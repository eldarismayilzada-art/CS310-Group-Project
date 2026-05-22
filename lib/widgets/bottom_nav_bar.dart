import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; 
import '../providers/auth_provider.dart'; 
import '../utils/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavBar({super.key, required this.currentIndex});

  void _onTap(NavigatorState navigator, String? role, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0: 
        final profileRoute = role == 'club' ? '/profile/club' : '/profile/student';
        navigator.pushReplacementNamed(profileRoute); 
        break;
      case 1: 
        navigator.pushReplacementNamed('/calendar'); 
        break;
      case 2: 
        navigator.pushReplacementNamed('/home'); 
        break;
      case 3:
        if (role == 'club')
        {
          navigator.pushReplacementNamed('/post/pick');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final auth = context.watch<AuthProvider>();
    final userRole = auth.userModel?.role; 

    final barBgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final unselectedColor = isDark ? Colors.white38 : const Color(0xFFAAAAAA);
    final shadowColor = isDark ? Colors.black26 : Colors.black.withOpacity(0.08);

    final items = [
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
      _NavItem(icon: Icons.calendar_month_rounded, label: 'Calendar'),
      _NavItem(icon: Icons.article_rounded, label: 'Posts'),
      if (userRole == 'club')
        _NavItem(icon: Icons.add_circle_rounded, label: 'Create'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: barBgColor, 
        boxShadow: [
          BoxShadow(
            color: shadowColor, 
            blurRadius: 12, 
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(Navigator.of(context), userRole, i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          items[i].icon,
                          color: active ? AppColors.primary : unselectedColor, 
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label, 
                        style: TextStyle(
                          fontFamily: 'Poppins', 
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? AppColors.primary : unselectedColor, 
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
