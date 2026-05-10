import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';


class CommentsPage extends StatefulWidget {
  final String postI;
  final String postOwnerName;

  const CommentsPage({
    super.key,
    required this.postI,
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

  final List<Color> _colorOptions = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];




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

Future<void> _postComment() async {
  final text = _commentController.text.trim();

  if (text.isEmpty) return;

  final auth = context.read<AuthProvider>();
  final commentProvider = context.read<CommentProvider>();

  final userId = auth.firebaseUser?.uid;
  final username = auth.userModel?.username ?? 'Unknown User';

  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must be logged in to comment.')),
    );
    return;
  }

  final newComment = CommentModel(
    id: '',
    postI: widget.postI,
    text: text,
    authorName: username,
    createdBy: userId,
    createdAt: DateTime.now(),
    fontSize: _selectedFontSize,
    textColor: _selectedColor.value,
    fontFamily: _selectedFontFamily,
  );

  final success = await commentProvider.createComment(newComment);

  if (!mounted) return;

  if (success) {
    setState(() {
      _commentController.clear();
      _isExpanded = false;
      _selectedFontSize = 16;
      _selectedColor = Colors.black;
      _selectedFontFamily = 'Roboto';
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          commentProvider.errorMessage ?? 'Failed to post comment.',
        ),
      ),
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

  Widget _buildCommentCard(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
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
                child: Text(
                  comment.authorName.isNotEmpty ? comment.authorName[0] : '?',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                _formatTime(comment.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade600,
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

  Widget _buildCollapsedBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: const [
                Icon(Icons.comment_outlined, size: 20),
                SizedBox(width: 10),
                Text(
                  'Write a comment...',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedEditor() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Comment Editor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _toggleExpanded,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Font family
            DropdownButtonFormField<String>(
              value: _selectedFontFamily,
              decoration: const InputDecoration(
                labelText: 'Font',
                border: OutlineInputBorder(),
              ),
              items: _fontFamilies.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font, style: TextStyle(fontFamily: font)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedFontFamily = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Font size
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Font Size: ${_selectedFontSize.toStringAsFixed(0)}'),
                Slider(
                  min: 12,
                  max: 30,
                  divisions: 18,
                  value: _selectedFontSize,
                  onChanged: (value) {
                    setState(() {
                      _selectedFontSize = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Color picker
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((color) {
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
                          color: isSelected ? Colors.black : Colors.transparent,
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
                color: _selectedColor,
                fontFamily: _selectedFontFamily,
              ),
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Live preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _commentController.text.isEmpty
                    ? 'Preview will appear here...'
                    : _commentController.text,
                style: TextStyle(
                  fontSize: _selectedFontSize,
                  color: _selectedColor,
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
    return Scaffold(
    appBar: AppBar(
      title: Text('Comments - ${widget.postOwnerName}'),
    ),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<List<CommentModel>>(
            stream: context.read<CommentProvider>().commentsStream(widget.postI),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading comments: ${snapshot.error}'),
                );
              }

              final comments = snapshot.data ?? [];

              if (comments.isEmpty) {
                return const Center(
                  child: Text('No comments yet. Be the first to comment!'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentCard(comments[index]);
                },
              );
            },
          ),
        ),
        _isExpanded ? _buildExpandedEditor() : _buildCollapsedBar(),
      ],  
      ),
    );
  }
}

