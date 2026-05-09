import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; 

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    switch (index) {
      case 0:
        final auth = context.read<AuthProvider>();
        if (auth.userModel?.role == 'club') {
          Navigator.pushNamed(context, '/profile/club');
        } else {
          Navigator.pushNamed(context, '/profile/student');
        }
        break;
      case 1: Navigator.pushNamed(context, '/calendar'); break;
      case 2: Navigator.pushNamed(context, '/home'); break;
      case 3: Navigator.pushNamed(context, '/post/pick'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>(); 
    
    final bool isClub = auth.userModel?.role == 'club';
    final bool isDark = themeProvider.isDarkMode;

    // Temaya göre renkleri belirle
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final inactiveColor = isDark ? Colors.white54 : const Color(0xFFAAAAAA);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);

    final items = [
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
      _NavItem(icon: Icons.calendar_month_rounded, label: 'Calendar'),
      _NavItem(icon: Icons.article_rounded, label: 'Posts'),
    ];

    if (isClub) {
      items.add(_NavItem(icon: Icons.add_circle_rounded, label: 'Create'));
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor, 
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
                  onTap: () => _onTap(context, i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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
                          child: Icon(items[i].icon,
                              color: active
                                  ? AppColors.primary
                                  : inactiveColor, 
                              size: 24),
                        ),
                        const SizedBox(height: 2),
                        Text(items[i].label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w400,
                              color: active
                                  ? AppColors.primary
                                  : inactiveColor, 
                            )),
                      ],
                    ),
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
