import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/add_event_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/day_detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/club_profile_screen.dart';
import '../screens/student_profile_screen.dart';


enum UserType { student, club }
class CurrentUser {
  static UserType type = UserType.student; 
}

class SideScreen extends StatelessWidget {
  const SideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF4F3FF),
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PROFILE ---
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (CurrentUser.type == UserType.club) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ClubProfileScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentProfileScreen()));
              }
            },
            child: const DrawerHeader(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.textSecondary)),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 25, child: Icon(Icons.person)),
                  SizedBox(width: 15),
                  Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // --- HOME ---
          ListTile(
            leading: const Icon(Icons.article_rounded, color: AppColors.primary,),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
          ),
          const Divider(),
          
          // --- CALENDAR ---
          ExpansionTile(
            leading: const Icon(Icons.calendar_month, color: AppColors.primary,),
            title: const Text('Calendar'),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 40),
                title: const Text('Monthly'),
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 40),
                title: const Text('Daily'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DayDetailScreen(day: DateTime.now(), events: [],)));
                },
              ),
            ],
          ),
          
          // --- CREATE POSTS (CLUB)---
          if (CurrentUser.type == UserType.club) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary,),
              title: const Text('Create Posts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEventScreen()));
              },
            ),
          ],

          // --- SETTINGS ---
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary,),
            title: const Text('Settings'),
            onTap: () {
          
            },
          ),
        ],
      ),
    );
  }
}
