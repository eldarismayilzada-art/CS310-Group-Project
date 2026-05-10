import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _commentsRef(String postId) {
    return _db.collection('posts').doc(postId).collection('comments');
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _commentsRef(postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> createComment(CommentModel comment) async {
    final ref = _commentsRef(comment.postId).doc();

    final newComment = CommentModel(
      id: ref.id,
      postId: comment.postId,
      text: comment.text,
      authorName: comment.authorName,
      createdBy: comment.createdBy,
      createdAt: DateTime.now(),
      fontSize: comment.fontSize,
      textColor: comment.textColor,
      fontFamily: comment.fontFamily,
    );

    await ref.set(newComment.toFirestore());
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String text,
    required double fontSize,
    required int textColor,
    required String fontFamily,
  }) async {
    await _commentsRef(postId).doc(commentId).update({
      'text': text,
      'fontSize': fontSize,
      'textColor': textColor,
      'fontFamily': fontFamily,
    });
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _commentsRef(postId).doc(commentId).delete();
  }
}
