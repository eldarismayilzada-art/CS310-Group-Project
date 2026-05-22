import 'package:flutter/material.dart';

class TestLoginForm extends StatefulWidget {
  const TestLoginForm({super.key});

  @override
  State<TestLoginForm> createState() => _TestLoginFormState();
}

class _TestLoginFormState extends State<TestLoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;

  void validateLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      if (email.isEmpty || password.isEmpty) {
        errorMessage = 'Please enter email and password';
      } else if (!email.contains('@') || !email.contains('.')) {
        errorMessage = 'Invalid email';
      } else {
        errorMessage = null;
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'Email'),
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(hintText: 'Password'),
          obscureText: true,
        ),
        ElevatedButton(
          onPressed: validateLogin,
          child: const Text('Login'),
        ),
        if (errorMessage != null)
          Text(errorMessage!),
      ],
    );
  }
}