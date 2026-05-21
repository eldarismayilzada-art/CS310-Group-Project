import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/club_service.dart';

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

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _usernameController.text = user.username;
      _dobController.text = user.dateOfBirth ?? '';
      _bioController.text = user.bio;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImage = image);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromGallery();
              },
            ),
          ],
        ),
      ),
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

    try {
      final auth = context.read<AuthProvider>();
      final uid = auth.firebaseUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': _usernameController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'bio': _bioController.text.trim(),
      });

      // Reload user model
      await auth.saveOnboarding(
        interests: auth.userModel?.interests ?? [],
        bio: _bioController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile photo
              GestureDetector(
                onTap: _showPhotoOptions,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                    ? FileImage(File(_selectedImage!.path))
                    : (user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!) as ImageProvider
                        : null),
                  child: (_selectedImage == null && user?.avatarUrl == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Tap profile picture to change'),
              const SizedBox(height: 24),

              // Dark mode toggle
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode',
                    style: TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600)),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text('Seed Clubs (run once)'),
                  onPressed: () async {
                    await ClubService().seedClubs(force: true);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Clubs seeded! ✅')),
                    );
                  },
                ),
              ),

              // Date of Birth
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
              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
                ),
              ),

              const SizedBox(height: 12),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout',
                    style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    await auth.signOut();
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