import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/auth_provider.dart';
import 'home_screen.dart'; 
import 'login_page.dart'; 
import 'interest_screen.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Loginscreen(); 
        }

        return FutureBuilder(
          future: context.read<AuthProvider>().loadCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final auth = context.watch<AuthProvider>();
            final user = auth.userModel;

            if (user == null) {
              return const Loginscreen();
            }

            if (user.role == 'club' || user.onboardingComplete) {
              return const HomeScreen();
            }

            if (user.interests.isEmpty) {
              return const InterestScreen();
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}
