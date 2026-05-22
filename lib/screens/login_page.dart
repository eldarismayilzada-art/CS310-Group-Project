import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; 

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPassword(BuildContext context, bool isDark, Color dialogBg) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg, 
        title: Text('Reset Password', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
            border: const OutlineInputBorder(),
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
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final inputBgColor = isDark ? const Color(0xFF222232) : Colors.grey[200];
    final mainTextColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: IconThemeData(color: mainTextColor)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome to", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: mainTextColor, fontFamily: 'Poppins')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CLUB", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: mainTextColor, fontSize: 50, fontFamily: 'Poppins')),
                  const Text("HUB", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: hubColor, fontSize: 50, fontFamily: 'Poppins')),
                ],
              ),
              const SizedBox(height: 40),

              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: mainTextColor, fontFamily: 'Poppins', fontSize: 15),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      icon: Icon(Icons.email, color: iconColor)),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: mainTextColor, fontFamily: 'Poppins', fontSize: 15),
                  onSubmitted: (_) => auth.isLoading ? null : _handleLogin(),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      icon: Icon(Icons.lock, color: iconColor)),
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => _showForgotPassword(context, isDark, inputBgColor!),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: hubColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 32),

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
                      colors: [Colors.blue, hubColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Center(
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Poppins')),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: hubColor, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                        color: hubColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
