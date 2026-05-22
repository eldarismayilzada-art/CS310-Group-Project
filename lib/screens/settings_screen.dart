import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/club_service.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isSaving = false;

  List<String> _userInterests = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _usernameController.text = user.username;
      _bioController.text = user.bio;
      _userInterests = List<String>.from(user.interests);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
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

  void _showPhotoOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: isDark ? Colors.white70 : Colors.black87),
              title: Text('Take a photo', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: isDark ? Colors.white70 : Colors.black87),
              title: Text('Choose from gallery', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
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

  void _openInterestsEditor(bool isDark) {
    final Set<String> tempSelected = Set.from(_userInterests);
    final userRole = context.read<AuthProvider>().userModel?.role;

    final pool = userRole == 'club'
        ? ['Music', 'Cinema', 'Coding', 'Sports', 'Art', 'Photography', 'Gaming', 'Dance', 'Theater', 'Aviation']
        : ['Physics', 'Astronomy', 'Gym', 'Aviation', 'Music', 'Art', 'Photography', 'Gaming', 'Coding', 'Sports', 'Cinema', 'Travel'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setPanelState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Interests / Tags',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pool.map((interest) {
                  final isSelected = tempSelected.contains(interest);
                  return GestureDetector(
                    onTap: () => setPanelState(() {
                      if (isSelected) {
                        tempSelected.remove(interest);
                      } else {
                        tempSelected.add(interest);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black), 
                          fontWeight: FontWeight.w500, 
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() {
                      _userInterests = tempSelected.toList();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthProvider>();
      final currentId = auth.userModel?.id; 
      if (currentId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(currentId).update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'interests': _userInterests, 
      });

      await auth.saveOnboarding(
        interests: _userInterests,
        bio: _bioController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully! ✅')),
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
    final isDark = themeProvider.isDarkMode;
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F3FF);
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final mainTextColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- PROFILE PHOTO ---
              GestureDetector(
                onTap: () => _showPhotoOptions(isDark),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: _selectedImage != null
                      ? FileImage(File(_selectedImage!.path))
                      : (user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) as ImageProvider : null),
                  child: (_selectedImage == null && user?.avatarUrl == null) ? const Icon(Icons.person, size: 50, color: AppColors.primary) : null,
                ),
              ),
              const SizedBox(height: 10),
              Text('Tap profile picture to change', style: TextStyle(color: subTextColor, fontFamily: 'Poppins', fontSize: 13)),
              const SizedBox(height: 24),

              // --- DARK MODE TOGGLE ---
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
                  title: Text('Dark Mode', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: mainTextColor)),
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              const SizedBox(height: 20),

              // --- USERNAME INPUT ---
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: mainTextColor, fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: subTextColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- BIO INPUT ---
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                style: TextStyle(color: mainTextColor, fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: subTextColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // --- INTERESTS / TAGS MANAGEMENT AREA ---
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'INTERESTS / TAGS', 
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 0.8),
                          ),
                          const Spacer(), 
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                            onPressed: () => _openInterestsEditor(isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _userInterests.isEmpty
                          ? Text('No interests selected yet.', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: subTextColor))
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _userInterests.map((interest) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(interest, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Save Changes', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),

              // --- LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text('Logout', style: TextStyle(color: Colors.red, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await auth.signOut();
                    Future.microtask(() {
                      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- ADMIN SEED BUTTON ---
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.sync, size: 16, color: Colors.grey),
                  label: const Text('Seed Clubs Database (Admin)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  onPressed: () async {
                    await ClubService().seedClubs(force: true);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clubs seeded! ✅')));
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
