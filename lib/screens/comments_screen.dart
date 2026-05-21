import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart'; 

class CommentsPage extends StatefulWidget {
  final String postId; 
  final String postOwnerName;

  const CommentsPage({
    super.key,
    required this.postId,
    required this.postOwnerName,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  bool _isExpanded = false;
  double _selectedFontSize = 16;
  Color _selectedColor = Colors.black;
  String _selectedFontFamily = 'Roboto';

  final List<String> _fontFamilies = [
    'Roboto',
    'Arial',
    'Courier',
    'Times New Roman',
  ];

  final Map<Color, int> _colorMap = {
    Colors.black: 0xFF000000,
    Colors.blue: 0xFF2196F3,
    Colors.red: 0xFFF44336,
    Colors.green: 0xFF4CAF50,
    Colors.purple: 0xFF9C27B0,
    Colors.orange: 0xFFFF9800,
  };

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final commentProvider = context.read<CommentProvider>();

    final newComment = CommentModel(
      id: '', 
      postId: widget.postId,
      text: text,
      authorName: auth.userModel?.username ?? 'Anonymous',
      createdBy: auth.firebaseUser?.uid ?? '',
      createdAt: DateTime.now(),
      fontSize: _selectedFontSize,
      textColor: _colorMap[_selectedColor] ?? 0xFF000000, 
      fontFamily: _selectedFontFamily,
    );

    final success = await commentProvider.createComment(newComment);

    if (success) {
      setState(() {
        _commentController.clear();
        _isExpanded = false;
        _selectedFontSize = 16;
        _selectedColor = Colors.black;
        _selectedFontFamily = 'Roboto';
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${commentProvider.errorMessage ?? "Failed to post comment"}')),
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} h ago';
    return '${difference.inDays} d ago';
  }

  Widget _buildCommentCard(CommentModel comment, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                child: Text(
                  comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Text(
                _formatTime(comment.createdAt),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.text,
            style: TextStyle(
              fontSize: comment.fontSize,
              color: Color(comment.textColor), 
              fontFamily: comment.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedBar(bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
          ),
        ),
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.comment_outlined, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(width: 10),
                Text(
                  'Write a comment...',
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedEditor(bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Comment Editor',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _toggleExpanded,
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            DropdownButtonFormField<String>(
              value: _selectedFontFamily,
              dropdownColor: isDark ? const Color(0xFF2E2E3E) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black), 
              decoration: InputDecoration(
                labelText: 'Font',
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54), 
                border: const OutlineInputBorder(),
              ),
              items: _fontFamilies.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font, style: TextStyle(fontFamily: font, color: isDark ? Colors.white : Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedFontFamily = value;
                });
              },
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorMap.keys.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? (isDark ? Colors.white : Colors.black) 
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _commentController,
              minLines: 3,
              maxLines: 6,
              style: TextStyle(
                fontSize: _selectedFontSize,
                color: isDark && _selectedColor == Colors.black ? Colors.white : _selectedColor,
                fontFamily: _selectedFontFamily,
              ),
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
              ),
              child: Text(
                _commentController.text.isEmpty
                    ? 'Preview will appear here...'
                    : _commentController.text,
                style: TextStyle(
                  fontSize: _selectedFontSize,
                  color: isDark && _selectedColor == Colors.black ? Colors.white : _selectedColor,
                  fontFamily: _selectedFontFamily,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleExpanded,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _postComment,
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = context.watch<CommentProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F3FF);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Comments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: commentProvider.commentsStream(widget.postId), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: isDark ? Colors.white : Colors.black)));
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      'No comments yet.\nBe the first to comment!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 16, fontFamily: 'Poppins'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentCard(comments[index], isDark);
                  },
                );
              },
            ),
          ),
          _isExpanded ? _buildExpandedEditor(isDark) : _buildCollapsedBar(isDark),
        ],
      ),
    );
  }
}
