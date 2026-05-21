import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SideScreen extends StatelessWidget {
  const SideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final drawerBg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF4F3FF);
    final textColor = isDark ? Colors.white : Colors.black54;
    final subTextColor = isDark ? Colors.white60 : Colors.white70;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Drawer(
      backgroundColor: drawerBg,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PROFILE HEADER ---
          InkWell(
            onTap: () {
              Navigator.pop(context);
              final profileRoute = user?.role == 'club' ? '/profile/club' : '/profile/student';
              Navigator.pushReplacementNamed(context, profileRoute);
            },
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: subTextColor,
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- POSTS ---
          ListTile(
            leading: const Icon(Icons.article_rounded, color: AppColors.primary),
            title: Text('Posts', style: TextStyle(fontFamily: 'Poppins', color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
          Divider(height: 1, color: dividerColor),

          // --- CALENDAR ---
          ExpansionTile(
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.primary,
            leading: const Icon(Icons.calendar_month, color: AppColors.primary),
            title: Text('Calendar', style: TextStyle(fontFamily: 'Poppins', color: textColor)),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 40),
                title: Text('Monthly', style: TextStyle(fontFamily: 'Poppins', color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/calendar');
                },
              ),
            ],
          ),
          Divider(height: 1, color: dividerColor),

          // --- PROFILE ---
          ListTile(
            leading: const Icon(Icons.person_rounded, color: AppColors.primary),
            title: Text('Profile', style: TextStyle(fontFamily: 'Poppins', color: textColor)),
            onTap: () {
              Navigator.pop(context);
              final profileRoute = user?.role == 'club' ? '/profile/club' : '/profile/student';
              Navigator.pushReplacementNamed(context, profileRoute);
            },
          ),
          Divider(height: 1, color: dividerColor),

          if (user?.role == 'club') ...[
            ListTile(
              leading: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
              title: Text('Create Post', style: TextStyle(fontFamily: 'Poppins', color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/post/pick');
              },
            ),
            Divider(height: 1, color: dividerColor),
          ],

          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: Text('Settings', style: TextStyle(fontFamily: 'Poppins', color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings'); 
            },
          ),

          const Spacer(),
          Divider(height: 1, color: dividerColor),

          // --- LOGOUT ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
