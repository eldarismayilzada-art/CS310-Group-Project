import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final formkey = GlobalKey<FormState>();

  final TextEditingController audio_controller = TextEditingController();
  final TextEditingController location_controller = TextEditingController();
  final TextEditingController date_controller = TextEditingController();
  final TextEditingController caption_controller = TextEditingController();
  final TextEditingController tagPeople_controller = TextEditingController();

  @override
  void dispose() {
    audio_controller.dispose();
    location_controller.dispose();
    date_controller.dispose();
    caption_controller.dispose();
    tagPeople_controller.dispose();
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  void submitPost() {
    if (formkey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully!')),
      );
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
                  Expanded(
                    child: Container(),
                  ),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Post'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                controller: audio_controller,
                decoration: buildInputDecoration('Add audio'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: location_controller,
                decoration: buildInputDecoration('Location'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: date_controller,
                decoration: buildInputDecoration('Date'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: caption_controller,
                maxLines: 3,
                decoration: buildInputDecoration('Write a caption'),

              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tagPeople_controller,
                decoration: buildInputDecoration('Tag people'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitPost,
                  child: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}