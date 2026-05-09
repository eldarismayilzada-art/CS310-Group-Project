import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../models/event_model.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/post_service.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/side_screen.dart';
import '../screens/comments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postService = PostService();
    final eventService = EventService();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F3FF);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: scaffoldBg,
      drawer: const SideScreen(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("ClubHub", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
      body: Column(
        children: [
          _buildActivityStories(eventService, isDark),
          
          Divider(height: 1, color: dividerColor),
     
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: postService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Text('No posts yet.\nFollow some clubs!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => _PostCard(post: posts[index], isDark: isDark),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildActivityStories(EventService eventService, bool isDark) {
    return Container(
      height: 115,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: StreamBuilder<List<EventModel>>(
        stream: eventService.getTodaysEvents(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox(width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Text("No events scheduled for today", 
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Text(
                          event.clubName[0].toUpperCase(), 
                          style: TextStyle(color: isDark ? Colors.white : AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 70,
                      child: Text(
                        event.clubName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10, 
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  final bool isDark;
  const _PostCard({required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUserId = auth.firebaseUser?.uid ?? '';
    final isLiked = post.likes.contains(currentUserId);

    final mainText = isDark ? Colors.white : Colors.black;
    final subText = isDark ? Colors.white70 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          title: Text(post.clubName, 
            style: TextStyle(fontWeight: FontWeight.bold, color: mainText)),
          subtitle: post.location != null
              ? Text(post.location!, style: TextStyle(fontSize: 12, color: subText))
              : null,
        ),
        
        if (post.imageUrl != null)
          Image.network(
            post.imageUrl!,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 250, 
                color: isDark ? Colors.white10 : Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250, 
              width: double.infinity, 
              color: isDark ? Colors.white10 : Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          )
        else
          Container(
            height: 250, 
            width: double.infinity, 
            color: isDark ? Colors.white10 : Colors.grey[300],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),

        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(post.caption, style: TextStyle(color: mainText)),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : subText),
                onPressed: () => postProvider.toggleLike(post.id, currentUserId),
              ),
              Text('${post.likes.length}', style: TextStyle(color: mainText)),
              const SizedBox(width: 15),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: subText),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CommentsPage(postI: post.id, postOwnerName: post.clubName))),
              ),
            ],
          ),
        ),
        Divider(color: isDark ? Colors.white10 : Colors.black12),
      ],
    );
  }
}
