import 'package:chatoid/features/notification/repository/noti_repo_impl.dart';
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
          'user_id, created_at, posts_text, reacts, id'); // Ensure you call execute() to get the response

      allPosts.clear(); // Clear the previous posts
      for (var post in response) {
        allPosts.add(ClsPost(
          postID: post['id'] ?? 0,
          createdAt: DateTime.parse(post['created_at']), // Parse the date
          userID: post['user_id'] ?? 0, // Use a default value if null
          postsText: post['posts_text'] ?? '', // Use an empty string if null
          reacts: post['reacts'] ?? 0, // Use a default value if null
        ));
      }

      // Sort posts by date (newest first)
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(PostsLoaded(posts: allPosts));
    } catch (e) {
      emit(PostsError(errorMsg: "Error fetching posts: $e"));
    }
  }

  Future<void> increaseReacts(int postId,String username) async {
    NotiRepoImpl notiRepoImpl = NotiRepoImpl();
    try {
      // Find the post in the list
      final index = allPosts.indexWhere((post) => post.postID == postId);

      if (index == -1) {
        emit(PostsError(errorMsg: "Post not found."));
        return;
      }
      final updatedPost = ClsPost(
        postID: allPosts[index].postID,
        postsText: allPosts[index].postsText,
        userID: allPosts[index].userID,
        createdAt: allPosts[index].createdAt,
        reacts: allPosts[index].reacts + 1, // Increment reacts
      );
      notiRepoImpl.sendPushNotification(
          updatedPost.userID, 'React on your post ♥️', username);

      allPosts[index] = updatedPost;
      allPosts
          .sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by date
      // Emit updated state for UI
      emit(PostsLoaded(posts: List.from(allPosts)));

      await supabase.client.from('posts').update({
        'reacts': updatedPost.reacts,
      }).eq('id', postId);
    } catch (e) {
      emit(PostsError(errorMsg: "Error increasing reacts: $e"));
    }
  }

  Future<void> insertPost(int userID, String postsText) async {
    ClsPost newPost = ClsPost(
      postID: 0,
      postsText: postsText,
      userID: userID,
      createdAt: DateTime.now(),
      reacts: 0,
    );

    allPosts.add(newPost);
    try {
      await supabase.client.from('posts').insert({
        'user_id': userID,
        'posts_text': postsText,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Sort the posts by creation date (newest first)
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(PostsLoaded(posts: List.from(allPosts)));
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
    return DateFormat('hh:mm a \ndd/MM/yyyy ').format(date);
  }
}
