import 'package:flutter/material.dart';


class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/interests'); // ✅ fixed route name
  }

  @override
  Widget build(BuildContext context) {
    const Color hubColor = Color(0xFF6A11CB);

    return Scaffold(
      appBar: AppBar(title: const Text('Log in Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CLUB", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 50)),
                const Text("HUB", style: TextStyle(fontWeight: FontWeight.bold, color: hubColor, fontSize: 50)),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Username', icon: Icon(Icons.person)),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Password', icon: Icon(Icons.lock)),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _handleLogin,
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
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Center(
                  child: Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}