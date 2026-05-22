import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/event_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/comment_provider.dart'; 

// Screens
import 'screens/calendar_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/club_profile_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/edit_post_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/comments_screen.dart';
import 'screens/home_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()), 
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ClubHub',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6A11CB),
              ),
            ),

            darkTheme: ThemeData.dark().copyWith(
              textTheme: ThemeData.dark()
                  .textTheme
                  .apply(fontFamily: 'Poppins'),
            ),

            themeMode: themeProvider.themeMode,

            home: const AuthWrapper(),

            routes: {
              '/login': (context) => const Loginscreen(),
              '/register': (context) => const RegisterScreen(),
              '/interests': (context) => const InterestScreen(),
              '/home': (context) => const HomeScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/add-event': (context) => const AddEventScreen(),
              '/profile/student': (context) => const StudentProfileScreen(),
              '/profile/club': (context) => const ClubProfileScreen(),
              '/post/pick': (context) => const CreatePostScreen(),
              '/post/edit': (context) => const EditPostScreen(),
              '/settings': (context) => SettingsScreen(),
              
              // Fixed: typo "postI" -> "postId" and extract arguments for Named Routes
              '/comments': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final String postId = args is String ? args : 'post_123';
                return CommentsPage(
                  postId: postId,
                  postOwnerName: 'Club_name',
                );
              },
            },
          );
        },
      ),
    );
  }
}