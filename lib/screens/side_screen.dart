import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../screens/add_event_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/day_detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/club_profile_screen.dart';
import '../screens/student_profile_screen.dart';

class SideScreen extends StatelessWidget {
  const SideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isClub = auth.userModel?.role == 'club';

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
              if (isClub) {
                Navigator.pushNamed(context, '/profile/club');
              } else {
                Navigator.pushNamed(context, '/profile/student');
              }
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      auth.userModel?.username ?? 'Profile',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.article_rounded, color: AppColors.primary),
                  title: const Text('Posts'),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                
                ExpansionTile(
                  leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                  title: const Text('Calendar'),
                  shape: const Border(), 
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40),
                      title: const Text('Monthly'),
                      onTap: () {
                        Navigator.pop(context); 
                        Navigator.pushNamed(context, '/calendar');
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40),
                      title: const Text('Daily'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => DayDetailScreen(day: DateTime.now(), events: const [])));
                      },
                    ),
                  ],
                ),

                // --- CREATE POSTS ---
                if (isClub)
                  ListTile(
                    leading: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                    title: const Text('Create Posts'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/post/pick');
                    },
                  ),

                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),

          // --- SIGN OUT ---
          const Divider(indent: 20, endIndent: 20), // Sadece çıkış butonunun üstünde ince bir çizgi
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.pop(context);
              await auth.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
