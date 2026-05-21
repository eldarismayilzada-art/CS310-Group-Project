import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final TextEditingController _bioController = TextEditingController();

  final List<String> _allInterests = [
    'Physics', 'Astronomy', 'Gym', 'Aviation',
    'Music', 'Art', 'Photography', 'Gaming',
    'Coding', 'Sports', 'Cinema', 'Travel',
  ];

  final Set<String> _selected = {};

  Future<void> _handleContinue() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one interest!')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    await auth.saveOnboarding(
      interests: _selected.toList(),
      bio: _bioController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    const Color hubColor = Color(0xFF6A11CB);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Interests')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please choose your INTERESTS!!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allInterests.map((interest) {
                final isSelected = _selected.contains(interest);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selected.remove(interest);
                    } else {
                      _selected.add(interest);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? hubColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text(
              'Anything you want to tell about yourself?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 200,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell us about yourself...',
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: auth.isLoading ? null : _handleContinue,
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
                      : const Text('CONTINUE ▶▶',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}