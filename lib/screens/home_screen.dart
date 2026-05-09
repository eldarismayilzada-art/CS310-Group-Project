import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/side_screen.dart';
import '../screens/comments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      drawer: const SideScreen(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 1,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];

          return Column(
            children: [
              _buildActivityReminders(),
              const Divider(),
              posts.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        'No posts yet.\nBe the first to post!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return _PostCard(post: posts[index]);
                      },
                    ),
                  ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildActivityReminders() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 35,
              child: CircleAvatar(radius: 32, backgroundColor: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUserId = auth.firebaseUser?.uid ?? '';
    final isLiked = post.likes.contains(currentUserId);
    final isOwner = post.createdBy == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(post.clubName,
            style: const TextStyle(fontFamily: 'Poppins',
              fontWeight: FontWeight.bold)),
          subtitle: post.location != null
            ? Text(post.location!,
                style: const TextStyle(fontSize: 12, color: Colors.grey))
            : null,
          trailing: isOwner
            ? PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    await postProvider.deletePost(post.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ]),
                  ),
                ],
              )
            : null,
        ),

        // Post image
        post.imageUrl != null
          ? Image.network(
              post.imageUrl!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),

        // Caption
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(post.caption,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ),

        // Like & Comment row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () => postProvider.toggleLike(post.id, currentUserId),
              ),
              Text('${post.likes.length}'),
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsPage(
                        postI: post.id,
                        postOwnerName: post.clubName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}