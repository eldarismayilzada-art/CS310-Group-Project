import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; 
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
    final themeProvider = context.watch<ThemeProvider>(); 
    
    final bool isClub = auth.userModel?.role == 'club';
    final bool isDark = themeProvider.isDarkMode;

    // Temaya göre dinamik renkler
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF4F3FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = AppColors.primary;
    final dividerColor = isDark ? Colors.white12 : Colors.grey.withOpacity(0.2);

    return Drawer(
      backgroundColor: backgroundColor, 
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
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25, 
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                    child: Icon(Icons.person, color: isDark ? Colors.white70 : Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      auth.userModel?.username ?? 'Profile',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: textColor 
                      ),
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
                  leading: Icon(Icons.article_rounded, color: iconColor),
                  title: Text('Posts', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                
                ExpansionTile(
                  leading: Icon(Icons.calendar_month, color: iconColor),
                  title: Text('Calendar', style: TextStyle(color: textColor)),
                  iconColor: iconColor,
                  collapsedIconColor: isDark ? Colors.white70 : Colors.grey,
                  shape: const Border(), 
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40),
                      title: Text('Monthly', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context); 
                        Navigator.pushNamed(context, '/calendar');
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 40),
                      title: Text('Daily', style: TextStyle(color: textColor)),
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
                    leading: Icon(Icons.add_circle_rounded, color: iconColor),
                    title: Text('Create Posts', style: TextStyle(color: textColor)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/post/pick');
                    },
                  ),

                ListTile(
                  leading: Icon(Icons.settings_outlined, color: iconColor),
                  title: Text('Settings', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),

          // --- SIGN OUT ---
          Divider(indent: 20, endIndent: 20, color: dividerColor),
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
