import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit() : super(PostsInitial());
  final supabase = Supabase.instance;

  List<ClsPost> allPosts = [];

  Future<void> getAllPosts() async {
    emit(PostsLoading());
    try {
      final response = await supabase.client.from('posts').select(
          'user_id, created_at, post_text, reacts'); // Ensure you call execute() to get the response

      allPosts.clear(); // Clear the previous posts
      print(response);
      for (var post in response) {
        allPosts.add(ClsPost(
          createdAt: DateTime.parse(post['created_at']), // Parse the date
          id: post['user_id'] ?? 0, // Use a default value if null
          postsText: post['post_text'] ?? '', // Use an empty string if null
          reacts: post['reacts'] ?? 0, // Use a default value if null
        ));
      }
      emit(PostsLoaded(posts: allPosts));
    } catch (e) {
      emit(PostsError(errorMsg: "Error fetching posts: $e"));
    }
  }
}
