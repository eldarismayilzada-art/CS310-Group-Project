import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../screens/calendar_screen.dart';
import '../screens/day_detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/student_profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/create_post_screen.dart';

class SideScreen extends StatelessWidget {
  const SideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Drawer(
      backgroundColor: const Color(0xFFF4F3FF),
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PROFILE HEADER ---
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentProfileScreen()),
              );
            },
            child: DrawerHeader(
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
                      ? const Icon(Icons.person,
                          color: Colors.white, size: 30)
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
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
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
            leading: const Icon(Icons.article_rounded,
              color: AppColors.primary),
            title: const Text('Posts',
              style: TextStyle(fontFamily: 'Poppins')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          const Divider(),

          // --- CALENDAR ---
          ExpansionTile(
            leading: const Icon(Icons.calendar_month,
              color: AppColors.primary),
            title: const Text('Calendar',
              style: TextStyle(fontFamily: 'Poppins')),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 40),
                title: const Text('Monthly',
                  style: TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalendarScreen()),
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 40),
                title: const Text('Daily',
                  style: TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DayDetailScreen(
                        day: DateTime.now(),
                        events: [],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          // --- PROFILE ---
          ListTile(
            leading: const Icon(Icons.person_rounded,
              color: AppColors.primary),
            title: const Text('Profile',
              style: TextStyle(fontFamily: 'Poppins')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentProfileScreen()),
              );
            },
          ),
          const Divider(),

          // --- CREATE POST ---
          ListTile(
            leading: const Icon(Icons.add_photo_alternate_rounded,
              color: AppColors.primary),
            title: const Text('Create Post',
              style: TextStyle(fontFamily: 'Poppins')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen()),
              );
            },
          ),
          const Divider(),

          // --- SETTINGS ---
          ListTile(
            leading: const Icon(Icons.settings_outlined,
              color: AppColors.primary),
            title: const Text('Settings',
              style: TextStyle(fontFamily: 'Poppins')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen()),
              );
            },
          ),

          const Spacer(),
          const Divider(),

          // --- LOGOUT ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              )),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}