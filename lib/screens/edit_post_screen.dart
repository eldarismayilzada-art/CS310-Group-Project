import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final formkey = GlobalKey<FormState>();

  final TextEditingController location_controller = TextEditingController();
  final TextEditingController caption_controller = TextEditingController();

  bool _isSharing = false;

  @override
  void dispose() {
    location_controller.dispose();
    caption_controller.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> submitPost(String? imageUrl) async {
    if (!formkey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final user = auth.userModel;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      final post = PostModel(
        id: '',
        clubName: user.username,
        caption: caption_controller.text.trim(),
        imageUrl: imageUrl,
        location: location_controller.text.trim().isEmpty
            ? null
            : location_controller.text.trim(),
        likes: [],
        createdBy: user.id,
        createdAt: DateTime.now(),
      );

      await postProvider.createPost(post);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully! ✅')),
      );

      // Go back to home
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing post: $e')),
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container()),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Post'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.shade200,
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Icon(Icons.image, size: 40)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: location_controller,
                decoration: buildInputDecoration('Location'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: caption_controller,
                maxLines: 3,
                decoration: buildInputDecoration('Write a caption'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write a caption';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSharing ? null : () => submitPost(imageUrl),
                  child: _isSharing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}