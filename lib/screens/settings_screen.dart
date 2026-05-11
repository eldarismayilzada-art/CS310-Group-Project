import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'interest_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;
  String? _selectedAvatarPath;

  final List<String> _profileImages = [
    'assets/images/img1.jpeg',
    'assets/images/img2.jpeg',
    'assets/images/img3.jpeg',
    'assets/images/img4.jpeg',
    'assets/images/img5.jpeg',
    'assets/images/img6.jpeg',
    'assets/images/img7.jpeg',
    'assets/images/img8.jpeg',
    'assets/images/img9.jpeg',
  ];

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().userModel;

    if (user != null) {
      _usernameController.text = user.username;
      _dobController.text = user.dateOfBirth ?? '';
      _bioController.text = user.bio;
      _selectedAvatarPath = user.avatarUrl;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showAssetPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _profileImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final imagePath = _profileImages[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarPath = imagePath;
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(imagePath),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid;
    final messenger = ScaffoldMessenger.of(context);

    if (uid == null) {
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to update profile.'),
        ),
      );
      return;
    }

    try {
      final updatedData = <String, dynamic>{
        'username': _usernameController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatarUrl': _selectedAvatarPath,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updatedData);

      await auth.loadCurrentUser();

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showAssetPhotoOptions,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedAvatarPath != null
                      ? AssetImage(_selectedAvatarPath!)
                      : null,
                  child: _selectedAvatarPath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Tap profile picture to change'),
              const SizedBox(height: 24),

              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.purple),
                  title: const Text(
                    'Edit Interests & Bio',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Update what you love'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InterestsPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Basic Info'),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    await auth.signOut();

                    if (!mounted) return;

                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
