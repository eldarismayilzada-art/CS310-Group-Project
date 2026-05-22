import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart'; 
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
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F3FF);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final mainTextColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
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
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PostSearchDelegate(postService),
              );
            },
          ),
        ],
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildActivityStories(isDark),
          
          Divider(height: 1, color: dividerColor),

          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: postService.getPosts(),
              builder: (context, snapshot) {
                // KRİTİK DÜZELTME: Çift yazılan connectionState hatası düzeltildi
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: mainTextColor)));
                }
                
                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts yet.\nFollow some clubs!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 16, fontFamily: 'Poppins'),
                    ),
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

  // Fixed: Removed the accidental copy-pasted `posts` list builder
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
              child: Text(
                "No events scheduled for today", 
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey, fontFamily: 'Poppins'),
              ),
            );
          }

          // Pass the actual fetched events to the reminders widget
          return _buildActivityReminders(events);
        },
      ),
    );
  }

  // Updated to dynamically use the passed Event list size
  Widget _buildActivityReminders(List<EventModel> events) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final titles = ['Muzikus', 'SU-Copter', 'SUTT', 'Sudance'];
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: const CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.star_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    titles[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87, fontFamily: 'Poppins'),
                  ),
                )
              ],
                ),
              );
            },
          )
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Search delegate
// ─────────────────────────────────────────────────────────────
class _PostSearchDelegate extends SearchDelegate<String> {
  final PostService postService;

  _PostSearchDelegate(this.postService);

  @override
  String get searchFieldLabel => 'Search posts...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Type to search posts or clubs', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
      );
    }

    return StreamBuilder<List<PostModel>>(
      stream: postService.getPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final q = query.toLowerCase();
        final results = snapshot.data!.where((p) {
          return p.clubName.toLowerCase().contains(q) || p.caption.toLowerCase().contains(q);
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text('No results for "$query"', style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final post = results[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.group)),
              title: Text(post.clubName, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              subtitle: Text(
                post.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
              onTap: () {
                close(context, post.id);
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Post card
// ─────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final PostModel post;
  final bool isDark;
  const _PostCard({required this.post, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final currentUserId = auth.userModel?.id ?? ''; 
    final isLiked = post.likes.contains(currentUserId);
    final isOwner = post.createdBy == currentUserId;

    final mainText = isDark ? Colors.white : Colors.black;
    final subText = isDark ? Colors.white70 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(post.clubName, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          subtitle: post.location != null
              ? Text(post.location!, style: const TextStyle(fontSize: 12, color: Colors.grey))
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
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        ),

        // Post Image
        post.imageUrl != null && post.imageUrl!.isNotEmpty
            ? Image.network(
                post.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Container(
                height: 250,
                width: double.infinity,
                color: isDark ? Colors.white10 : Colors.grey[300],
                child: Center(child: Icon(Icons.image, size: 50, color: subText)),
              ),

        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(post.caption, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: mainText)),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : subText,
                ),
                onPressed: () => postProvider.toggleLike(post.id, currentUserId),
              ),
              Text('${post.likes.length}', style: TextStyle(color: mainText)),
              const SizedBox(width: 15),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: subText),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsPage(
                        postId: post.id,
                        postOwnerName: post.clubName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Divider(color: isDark ? Colors.white10 : Colors.black12),
      ],
    );
  }
}