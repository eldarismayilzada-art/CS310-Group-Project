import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
      Navigator.pushReplacementNamed(
        context, 
        _selectedRole == 'club' ? '/home' : '/interests'
      );
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

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Join", style: TextStyle(
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
              const SizedBox(height: 20),

              _buildRoleSelector(hubColor),
              
              const SizedBox(height: 20),
              _buildField(_usernameController, 'Username / Club Name', Icons.person),
              const SizedBox(height: 15),
              _buildField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 15),
              _buildField(_passwordController, 'Password', Icons.lock, obscure: true),
              const SizedBox(height: 15),
              _buildField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, obscure: true),
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
                      colors: [Colors.blue, Color(0xFF6A11CB)],
                    ),
                  ),
                  child: Center(
                    child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text("Already have an account? Log in", style: TextStyle(color: hubColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(Color color) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text("Student"),
              selected: _selectedRole == 'student',
              onSelected: (val) => setState(() => _selectedRole = 'student'),
            ),
          ),
          Expanded(
            child: ChoiceChip(
              label: const Text("Club"),
              selected: _selectedRole == 'club',
              onSelected: (val) => setState(() => _selectedRole = 'club'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: (_) => _handleRegister(),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          icon: Icon(icon),
        ),
      ),
    );
  }
}
