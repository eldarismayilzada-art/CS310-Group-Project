import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/day_detail_screen.dart';
import 'screens/login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClubConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/login',
      routes: {
        '/login': (ctx)=> const Loginscreen(),
        '/home':            (ctx) => const PlaceholderScreen(
          title: 'Posts', navIndex: 2,
          icon: Icons.article_rounded),
        '/calendar':        (ctx) => const CalendarScreen(),
        '/add-event':       (ctx) => const AddEventScreen(),
        '/profile/student': (ctx) => const PlaceholderScreen(
          title: 'Profile', navIndex: 0,
          icon: Icons.person_rounded),
        '/profile/club':    (ctx) => const PlaceholderScreen(
          title: 'Club Profile', navIndex: 0,
          icon: Icons.groups_rounded),
        '/post/pick':       (ctx) => const PlaceholderScreen(
          title: 'Create Post', navIndex: 3,
          icon: Icons.add_photo_alternate_rounded),
        '/post/edit':       (ctx) => const PlaceholderScreen(
          title: 'Edit Post', navIndex: 3,
          icon: Icons.edit_rounded),  
        '/settings':        (ctx) => const PlaceholderScreen(
          title: 'Settings', navIndex: 0,
          icon: Icons.settings_rounded),
        '/comments':        (ctx) => const PlaceholderScreen(
          title: 'Comments', navIndex: 2,
          icon: Icons.comment_rounded),
      },
    );
  }
}