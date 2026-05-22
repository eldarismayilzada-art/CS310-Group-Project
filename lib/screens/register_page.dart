import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  String _selectedRole = 'student'; 

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty ||
        password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    
    final success = await auth.signUp(
      email: email,
      password: password,
      username: username,
      role: _selectedRole, 
    );

    if (!mounted) return;

    if (success) {
      if (_selectedRole == 'club') {
        Navigator.pushReplacementNamed(context, '/profile/club');
      } else {
        Navigator.pushReplacementNamed(context, '/interests');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color hubColor = Color(0xFF6A11CB);
    final auth = context.watch<AuthProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final mainTextColor = isDark ? Colors.white : Colors.black;
    final inputBgColor = isDark ? const Color(0xFF222232) : Colors.grey[200];
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
              Text("Join", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: mainTextColor, fontFamily: 'Poppins')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CLUB", style: TextStyle(fontWeight: FontWeight.bold, color: mainTextColor, fontSize: 50, fontFamily: 'Poppins')),
                  const Text("HUB", style: TextStyle(fontWeight: FontWeight.bold, color: hubColor, fontSize: 50, fontFamily: 'Poppins')),
                ],
              ),
              const SizedBox(height: 25),

              Container(
                width: 300,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: inputBgColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'student'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'student' ? hubColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Student',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: _selectedRole == 'student' ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'club'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'club' ? hubColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Club Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: _selectedRole == 'club' ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildField(_usernameController, 'Username', Icons.person, inputBgColor!, mainTextColor, isDark, iconColor),
              const SizedBox(height: 15),
              _buildField(_emailController, 'Email', Icons.email, inputBgColor, mainTextColor, isDark, iconColor),
              const SizedBox(height: 15),
              _buildField(_passwordController, 'Password', Icons.lock, inputBgColor, mainTextColor, isDark, iconColor, obscure: true),
              const SizedBox(height: 15),
              _buildField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, inputBgColor, mainTextColor, isDark, iconColor, obscure: true),
              const SizedBox(height: 40),

              // REGISTER BUTTON
              GestureDetector(
                onTap: auth.isLoading ? null : _handleRegister,
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
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Center(
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("REGISTER",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BACK TO LOGIN BUTTON
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Log in",
                  style: TextStyle(
                    color: hubColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon,
    Color bgColor,
    Color textColor,
    bool isDark,
    Color iconColor, {
    bool obscure = false,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: textColor, fontFamily: 'Poppins', fontSize: 15),
        onSubmitted: (_) => _handleRegister(),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          icon: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}
