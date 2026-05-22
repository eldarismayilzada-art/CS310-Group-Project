import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

// Fixed: Added the missing SideScreen import
import '../screens/side_screen.dart';

class ClubProfileScreen extends StatelessWidget {
  const ClubProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final user = auth.userModel;
    final currentUserId = auth.firebaseUser?.uid ?? '';
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F3FF);
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final clubInterests = user?.interests ?? [];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Club Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: const SideScreen(), 
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        user != null && user.username.isNotEmpty 
                            ? user.username[0].toUpperCase() 
                            : 'C',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Club',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            user?.username ?? 'SU Club',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (clubInterests.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: clubInterests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: const Text('Edit Club Tags'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _showClubEditDialog(context, auth, isDark),
                    ),

                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'MY POSTS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : const Color(0xFF6B6B6B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          StreamBuilder<List<PostModel>>(
            stream: postProvider.getPostsByUser(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Database index is creating, please wait a few minutes...', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontFamily: 'Poppins', fontSize: 13),
                      ),
                    ),
                  ),
                );
              }

              final myPosts = snapshot.data ?? [];

              if (myPosts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'You haven\'t shared any posts yet.',
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = myPosts[index];
                      return _PostThumbnail(
                        post: post,
                        cardColor: cardColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/comments', arguments: post.id);
                        },
                      );
                    },
                    childCount: myPosts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({required this.post, required this.cardColor, required this.onTap});
  final PostModel post;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? path = post.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: cardColor,
          child: path != null && path.isNotEmpty
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(Icons.article_outlined, color: AppColors.primary, size: 28),
                ),
        ),
      ),
    );
  }
}

void _showClubEditDialog(BuildContext context, AuthProvider auth, bool isDark) {
  final user = auth.userModel;
  if (user == null) return;

  final Set<String> selectedTags = Set.from(user.interests);

  const clubCategoryPool = [
    'Music', 'Cinema', 'Coding', 'Sports',
    'Art', 'Photography', 'Gaming', 'Dance',
    'Theater', 'Aviation', 'Literature', 'Social Resp.',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setPanelState) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Club Categories',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select categories that represent your club activities.',
                style: TextStyle(
                  fontSize: 12, 
                  color: isDark ? Colors.white60 : Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              
              Wrap(
                spacing: 8, 
                runSpacing: 10,
                children: clubCategoryPool.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => setPanelState(() {
                      if (isSelected) {
                        selectedTags.remove(tag);
                      } else {
                        selectedTags.add(tag);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.transparent),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 28),
              
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await auth.saveOnboarding(
                      interests: selectedTags.toList(),
                      bio: user.bio, 
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Club profile updated successfully!')),
                    );
                  },
                  child: const Text('Save Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}