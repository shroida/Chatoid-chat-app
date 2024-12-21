import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit() : super(PostsInitial());
  final supabase = Supabase.instance;

  List<ClsPost> allPosts = [];

  Future<void> getAllPosts() async {
    emit(PostsLoading());
    try {
      final response = await supabase.client.from('posts').select(
          'user_id, created_at, posts_text, reacts'); // Ensure you call execute() to get the response

      allPosts.clear(); // Clear the previous posts
      print(response);
      for (var post in response) {
        allPosts.add(ClsPost(
          createdAt: DateTime.parse(post['created_at']), // Parse the date
          id: post['user_id'] ?? 0, // Use a default value if null
          postsText: post['posts_text'] ?? '', // Use an empty string if null
          reacts: post['reacts'] ?? 0, // Use a default value if null
        ));
      }
      emit(PostsLoaded(posts: allPosts));
    } catch (e) {
      emit(PostsError(errorMsg: "Error fetching posts: $e"));
    }
  }

  Future<void> increaseReacts(int postId) async {
    try {
      // Find the post in the list
      final postIndex = allPosts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) throw Exception('Post not found');

      // Update the reacts count locally
      allPosts[postIndex].reacts += 1;
      emit(PostsLoaded(posts: allPosts));

      // Update the reacts count in the database
      await supabase.client.from('posts').update({
        'reacts': allPosts[postIndex].reacts,
      }).eq('user_id', postId);
    } catch (e) {
      emit(PostsError(errorMsg: "Error increasing reacts: $e"));
    }
  }

  Future<void> insertPost(
    int id,
    String postsText,
  ) async {
    ClsPost newPost = ClsPost(
        postsText: postsText, id: id, createdAt: DateTime.now(), reacts: 0);
    allPosts.add(newPost);
    print('new post${newPost.postsText}');
    try {
      await supabase.client.from('posts').insert({
        'user_id': id,
        'posts_text': postsText,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Try to send from home page'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String formatMessageDate(DateTime date) {
    return DateFormat('hh:mm a dd/MM/yyyy ').format(date);
  }
}
