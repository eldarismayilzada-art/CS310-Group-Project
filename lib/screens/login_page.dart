import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {

  void _showForgotPassword(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final auth = context.read<AuthProvider>();
              final success = await auth.resetPassword(email);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                    ? 'Password reset email sent! Check your inbox.'
                    : auth.errorMessage ?? 'Error sending reset email'),
                ),
              );
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(email: email, password: password);

    if (!mounted) return;

    if (success) {
      final completed = await auth.hasCompletedOnboarding();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context, completed ? '/home' : '/interests');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color hubColor = Color(0xFF6A11CB);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to", style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CLUB", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, fontSize: 50)),
                const Text("HUB", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hubColor, fontSize: 50)),
              ],
            ),
            const SizedBox(height: 30),

            // EMAIL field (was username)
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Email',
                  icon: Icon(Icons.email)),
              ),
            ),
            const SizedBox(height: 15),

            // PASSWORD field
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) => auth.isLoading ? null : _handleLogin(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Password',
                  icon: Icon(Icons.lock)),
              ),
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: () => _showForgotPassword(context),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF6A11CB),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // LOGIN BUTTON
            GestureDetector(
              onTap: auth.isLoading ? null : _handleLogin,
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Color(0xFF6A11CB)],
                  ),
                  boxShadow: [BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5))],
                ),
                child: Center(
                  child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LOGIN", style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SIGN UP BUTTON
            GestureDetector(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: hubColor, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text("Don't have an account? Sign Up",
                  style: TextStyle(
                    color: hubColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
              ),
            ),

            const SizedBox(height: 15),

            // ARE YOU A CLUB BUTTON
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/club-login'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: hubColor, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text("Are you a club? 🎓",
                  style: TextStyle(
                    color: hubColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}