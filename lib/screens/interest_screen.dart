  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/auth_provider.dart';

  class InterestsPage extends StatefulWidget {
    const InterestsPage({super.key});

    @override
    State<InterestsPage> createState() => _InterestsPageState();
  }

  class _InterestsPageState extends State<InterestsPage> {
    final List<String> _allInterests = [
      'Sports', 'Music', 'Technology', 'Art', 'Science',
      'Gaming', 'Travel', 'Food', 'Photography', 'Fashion',
      'Literature', 'Politics', 'Film', 'Coding', 'Environment',
    ];

    final Set<String> _selected = {};

    Future<void> _handleSave() async {
      if (_selected.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one interest')),
        );
        return;
      }

      final auth = context.read<AuthProvider>();
      await auth.saveInterests(_selected.toList());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }

    @override
    Widget build(BuildContext context) {
      const Color hubColor = Color(0xFF6A11CB);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Interests'),
          backgroundColor: hubColor,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("What are you into?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Select topics you're interested in to personalize your feed.",
                style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allInterests.map((interest) {
                    final isSelected = _selected.contains(interest);
                    return GestureDetector(
                      onTap: () => setState(() {
                        isSelected ? _selected.remove(interest) : _selected.add(interest);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? hubColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? hubColor : Colors.transparent,
                          ),
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
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hubColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Continue",
                    style: TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }