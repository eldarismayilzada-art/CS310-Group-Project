import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Start listening to real-time posts stream
  void listenToPosts() {
    _isLoading = true;
    notifyListeners();

    _postService.getPosts().listen(
      (posts) {
        _posts = posts;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createPost(PostModel post) async {
    try {
      await _postService.createPost(post);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _postService.toggleLike(postId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePost(String postId,
      {String? caption, String? location}) async {
    try {
      await _postService.updatePost(postId,
          caption: caption, location: location);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Stream<List<PostModel>> getPostsByUser(String userId) {
    return _postService.getPostsByUser(userId);
  }
}