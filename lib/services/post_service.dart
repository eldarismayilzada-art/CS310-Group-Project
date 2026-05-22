import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'posts';

  // CREATE
  Future<void> createPost(PostModel post) async {
    final ref = _db.collection(_collection).doc();
    final newPost = PostModel(
      id: ref.id,
      clubName: post.clubName,
      caption: post.caption,
      imagePath: post.imagePath,
      location: post.location,
      date: post.date,
      audio: post.audio,
      tagPeople: post.tagPeople,
      likes: [],
      createdBy: post.createdBy,
      createdAt: DateTime.now(),
    );
    await ref.set(newPost.toFirestore());
  }

  // READ - real-time stream
  Stream<List<PostModel>> getPosts() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // READ - posts by a specific user
  Stream<List<PostModel>> getPostsByUser(String userId) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  // UPDATE - toggle like
  Future<void> toggleLike(String postId, String userId) async {
    final ref = _db.collection(_collection).doc(postId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final likes = List<String>.from(doc.data()?['likes'] ?? []);
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }
    await ref.update({'likes': likes});
  }

  // UPDATE - edit caption
  Future<void> updatePost(String postId, {String? caption, String? location}) async {
    final data = <String, dynamic>{};
    if (caption != null) data['caption'] = caption;
    if (location != null) data['location'] = location;
    if (data.isNotEmpty) {
      await _db.collection(_collection).doc(postId).update(data);
    }
  }

  // DELETE
  Future<void> deletePost(String postId) async {
    await _db.collection(_collection).doc(postId).delete();
  }
}