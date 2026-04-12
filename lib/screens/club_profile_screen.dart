import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────
class ClubPost {
  final String id;
  final String imageUrl;

  const ClubPost({
    required this.id,
    required this.imageUrl,
  });
}

class Club {
  final String clubName;
  final String? avatarUrl;
  final List<ClubPost> posts;

  const Club({
    required this.clubName,
    this.avatarUrl,
    this.posts = const [],
  });
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class ClubProfileScreen extends StatelessWidget {
  const ClubProfileScreen({super.key});

  static const _demoClub = Club(
    clubName: 'SU Tennis Club',
    avatarUrl: null,
    posts: [
      ClubPost(id: '1', imageUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=400'),
      ClubPost(id: '2', imageUrl: 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=400'),
      ClubPost(id: '3', imageUrl: 'https://picsum.photos/seed/tennis3/400/400'),
      ClubPost(id: '4', imageUrl: 'https://picsum.photos/seed/tennis4/400/400'),
      ClubPost(id: '5', imageUrl: 'https://picsum.photos/seed/tennis5/400/400'),
      ClubPost(id: '6', imageUrl: 'https://picsum.photos/seed/tennis6/400/400'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
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
        ],
      ),
      drawer: const _SideDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ClubAvatar(club: _demoClub),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
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
                            _demoClub.clubName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'POSTS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
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

          // Posts grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _PostThumbnail(
                  post: _demoClub.posts[index],
                  onTap: () => Navigator.pushNamed(context, '/comments'),
                ),
                childCount: _demoClub.posts.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────

class _ClubAvatar extends StatelessWidget {
  const _ClubAvatar({required this.club});
  final Club club;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      backgroundImage:
          club.avatarUrl != null ? NetworkImage(club.avatarUrl!) : null,
      child: club.avatarUrl == null
          ? const Icon(Icons.groups_rounded, size: 56, color: AppColors.primary)
          : null,
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({required this.post, required this.onTap});
  final ClubPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          post.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.image_not_supported_outlined,
                color: AppColors.primary),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.primary.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIDE DRAWER
// ─────────────────────────────────────────────
class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    final items = [
      _DrawerItem(Icons.person_rounded, 'Profile', '/profile/student'),
      _DrawerItem(Icons.calendar_month_rounded, 'Calendar – Monthly', '/calendar'),
      _DrawerItem(Icons.today_rounded, 'Calendar – Daily', '/calendar'),
      _DrawerItem(Icons.article_rounded, 'Posts', '/home'),
      _DrawerItem(Icons.add_photo_alternate_rounded, 'Create Posts', '/post/pick'),
      _DrawerItem(Icons.settings_rounded, 'Settings', '/settings'),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                'ClubConnect',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...items.map((item) => ListTile(
                  leading: Icon(item.icon, color: AppColors.primary),
                  title: Text(
                    item.label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, item.route);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;
  const _DrawerItem(this.icon, this.label, this.route);
}