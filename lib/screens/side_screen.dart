import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/add_event_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/day_detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/club_profile_screen.dart';
import '../screens/student_profile_screen.dart';

enum UserType { student, club }

class SideScreen extends StatelessWidget {
  const SideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (currentUser.type == UserType.club) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ClubProfileScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentProfileScreen()));
              }
            },
            const DrawerHeader(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
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
            leading: const Icon(Icons.grid_on),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
          ),
          const Divider(),
          
          // --- CALENDAR ---
          ExpansionTile(
            leading: const Icon(Icons.calendar_month),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DayDetailScreen()));
                },
              ),
            ],
          ),
          const Divider(),
          
          // --- CREATE POSTS ---
          ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('Create Posts'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEventScreen()));
            },
          ),
        ],
      ),
    );
  }
}
