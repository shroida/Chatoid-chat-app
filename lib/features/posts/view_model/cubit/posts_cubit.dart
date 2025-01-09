import 'package:chatoid/features/notification/repository/noti_repo_impl.dart';
import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_state.dart';
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
      final response = await supabase.client
          .from('posts')
          .select('user_id, created_at, posts_text, reacts, id');

      allPosts = response.map<ClsPost>((post) {
        return ClsPost(
          postID: post['id'] ?? 0,
          createdAt: DateTime.parse(post['created_at']),
          userID: post['user_id'] ?? 0,
          postsText: post['posts_text'] ?? '',
          reacts: post['reacts'] ?? 0,
        );
      }).toList();

      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(PostsLoaded(posts: allPosts));
    } catch (e) {
      emit(PostsError(errorMsg: "Error fetching posts: $e"));
    }
  }

  Future<void> increaseReacts(int postId, String username) async {
    NotiRepoImpl notiRepoImpl = NotiRepoImpl();
    try {
      final index = allPosts.indexWhere((post) => post.postID == postId);
      if (index == -1) {
        emit(PostsError(errorMsg: "Post not found."));
        return;
      }

      // Increase the react count locally
      final updatedPost =
          allPosts[index].copyWith(reacts: allPosts[index].reacts + 1);

      // Send push notification (optional)
      notiRepoImpl.sendPushNotification(
          updatedPost.userID, 'React on your post ♥️', username);

      // Update the post list with the updated reacts
      allPosts[index] = updatedPost;

      // Emit the updated list of posts
      emit(PostsLoaded(posts: List.from(allPosts)));

      // Update the reacts count in Supabase
      final response = await supabase.client
          .from('posts')
          .update({'reacts': updatedPost.reacts}).eq('id', postId);

      // Check if the update was successful
      if (response.error != null) {
        throw Exception('Failed to update react count in Supabase');
      }
    } catch (e) {
      // Emit error if something goes wrong
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

    try {
      final response = await supabase.client.from('posts').insert({
        'user_id': userID,
        'posts_text': postsText,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Assuming the database returns the new post ID
      newPost = newPost.copyWith(postID: response.data[0]['id']);
      allPosts.add(newPost);

      emit(PostsLoaded(posts: List.from(allPosts)));
    } catch (e) {
      emit(PostsError(errorMsg: "Error inserting post: $e"));
    }
  }

  Future<void> deletePost(int postID) async {
    try {
      // Delete from Supabase
      await supabase.client.from('posts').delete().eq('id', postID);

      // Remove from local list
      allPosts.removeWhere((post) => post.postID == postID);

      emit(PostsLoaded(posts: List.from(allPosts)));
    } catch (e) {
      emit(PostsError(errorMsg: "Error deleting post: $e"));
    }
  }

  String formatMessageDate(DateTime date) {
    return DateFormat('hh:mm a \ndd/MM/yyyy ').format(date);
  }
}
