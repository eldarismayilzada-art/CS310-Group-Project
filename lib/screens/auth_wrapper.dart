import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'home_screen.dart';
import 'interest_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const Loginscreen();
      case AuthStatus.authenticated:
        // Only show interests if user model is loaded AND interests are empty
        // This means it's a brand new account, not a loading state
        final user = auth.userModel;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (user.interests.isEmpty) {
          return const InterestScreen();
        }
        return const HomeScreen();
    }
  }
}