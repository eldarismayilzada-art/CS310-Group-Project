import 'package:clubhub/screens/interest_screen.dart';
import 'package:clubhub/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/day_detail_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/club_profile_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/edit_post_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClubConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/',         // ✅ fixed
      routes: {
        '/': (context) => const Loginscreen(),
        '/interests': (ctx) => const InterestScreen(),
        '/home': (ctx) => const PlaceholderScreen(
            title: 'Posts', navIndex: 2,
            icon: Icons.article_rounded),
        '/calendar': (ctx) => const CalendarScreen(),
        '/add-event': (ctx) => const AddEventScreen(),
        '/profile/student': (ctx) => const StudentProfileScreen(),
        '/profile/club': (ctx) => const ClubProfileScreen(),
        '/post/pick': (ctx) => const CreatePostScreen(),
        '/post/edit': (ctx) => const EditPostScreen(),
        '/settings': (ctx) => const PlaceholderScreen(
            title: 'Settings', navIndex: 0,
            icon: Icons.settings_rounded),
        '/comments': (ctx) => const PlaceholderScreen(
            title: 'Comments', navIndex: 2,
            icon: Icons.comment_rounded),
      },
    );
  }
}