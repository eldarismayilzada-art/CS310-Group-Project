import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────
class StudentUser {
  final String username;
  final String? avatarUrl;
  final List<String> interests;

  const StudentUser({
    required this.username,
    this.avatarUrl,
    this.interests = const [],
  });
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  static const _demoUser = StudentUser(
    username: 'aylin.aksu',
    avatarUrl: null,
    interests: ['Physics', 'Astronomy', 'Gym', 'Aviation'],
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
          'Profile',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarSection(user: _demoUser),
              const SizedBox(height: 16),
              Text(
                '@${_demoUser.username}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              _InterestsSection(interests: _demoUser.interests),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.user});
  final StudentUser user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      backgroundImage:
          user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
      child: user.avatarUrl == null
          ? const Icon(Icons.person_rounded, size: 56, color: AppColors.primary)
          : null,
    );
  }
}

class _InterestsSection extends StatelessWidget {
  const _InterestsSection({required this.interests});
  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'INTERESTS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: interests.map((i) => _InterestChip(label: i)).toList(),
        ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
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