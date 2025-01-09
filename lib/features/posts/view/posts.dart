import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view/widgets/post_widget.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  PostsWidgetState createState() => PostsWidgetState();
}

class PostsWidgetState extends State<Posts> {
  @override
  void initState() {
    super.initState();
    final postsCubit = BlocProvider.of<PostsCubit>(context);
    postsCubit.getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) {
        if (state is PostsLoading) {
          return Center(child: Image.asset('assets/loading_earth.gif'));
        } else if (state is PostsLoaded) {
          final posts = state.posts;
          return _buildPostsList(posts, chatsCubit);
        } else {
          return const Center(child: Text("No posts available"));
        }
      },
    );
  }

  Widget _buildPostsList(List<ClsPost> posts, ChatsCubit chatsCubit) {
    if (posts.isEmpty) {
      return const Center(child: Text("No posts available"));
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        UserData userPost;
        try {
          userPost = chatsCubit.allUsersApp.firstWhere(
            (user) => user.userId == posts[index].userID,
          );
        } catch (e) {
          userPost = UserData(
              userId: 0,
              username: 'Unknown User',
              email: '',
              friendId: -1,
              profileImage: '');
        }

        return PostWidget(post: posts[index], user: userPost);
      },
    );
  }
}
