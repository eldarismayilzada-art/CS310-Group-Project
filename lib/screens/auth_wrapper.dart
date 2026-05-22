import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_page.dart';
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
        // Wait for userModel to finish loading before deciding
        if (auth.isLoading || auth.userModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // interests is List<String> (never null) — empty means onboarding not done
        final doneOnboarding = auth.userModel!.interests.isNotEmpty;
        return doneOnboarding ? const HomeScreen() : const InterestScreen();
    }
  }
}