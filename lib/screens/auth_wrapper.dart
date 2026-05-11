import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

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
          return const _NavigateTo(routeName: '/login');
        }

        return FutureBuilder(
          future: context.read<AuthProvider>().loadCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final auth = context.read<AuthProvider>();
            final user = auth.userModel;

            if (user == null) {
              return const _NavigateTo(routeName: '/login');
            }

            if (user.role == 'club' || user.onboardingComplete) {
              return const _NavigateTo(routeName: '/home');
            }

            return const _NavigateTo(routeName: '/interests');
          },
        );
      },
    );
  }
}

class _NavigateTo extends StatefulWidget {
  final String routeName;
  const _NavigateTo({required this.routeName});
  @override
  State<_NavigateTo> createState() => _NavigateToState();

}

class _NavigateToState extends State<_NavigateTo> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, widget.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}