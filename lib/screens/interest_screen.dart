import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class InterestScreen extends StatefulWidget {
  final bool isSettings;
  const InterestScreen({super.key, this.isSettings = false});

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

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında mevcut kullanıcı verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().userModel;
      if (user != null) {
        setState(() {
          _bioController.text = user.bio;
          _selected.addAll(user.interests);
        });
      }
    });
  }

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

    if (widget.isSettings) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interests updated successfully!')),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color hubColor = Color(0xFF6A11CB);
    final auth = context.watch<AuthProvider>();
   
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black87;
    final chipBackground = isDark ? Colors.grey[800] : Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Interests'),
        automaticallyImplyLeading: widget.isSettings,
        leading: widget.isSettings ? null : Container(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please choose your INTERESTS!!',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 22,
                color: textColor, 
              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? hubColor : chipBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor, 
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              'Anything you want to tell about yourself?',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: textColor, // Dinamik renk
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: chipBackground, 
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 200,
                style: TextStyle(color: textColor), 
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell us about yourself...',
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  contentPadding: const EdgeInsets.all(15),
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
                      colors: [Colors.blue, hubColor],
                    ),
                  ),
                  child: Center(
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isSettings ? 'SAVE CHANGES' : 'CONTINUE ▶▶',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
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
