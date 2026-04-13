import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/side_screen.dart';
import '../screens/comments_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      drawer: const SideScreen(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
        elevation: 1,
      ),
      body: Column(
        children: [
          activityReminder(),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return activityPost(context);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget activityReminder() {
    return SizedBox (
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

  Widget activityPost(BuildContext context) { 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Club_name'),
        ),
        Container(
          height: 250,
          width: double.infinity,
          color:AppColors.textSecondary,
          child: const Center(child: Icon(Icons.image, size: 50)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Like Button
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  debugPrint ('liked');
                },
              ),
              const Text('24'),
              const SizedBox(width: 15),
              
              // Comments Button
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommentsPage(
                        postID: 'post_123',
                        postOwnerName: 'Club_name',
                      ),
                    ),
                  );
                },
              ),
              const Text('12'),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}


