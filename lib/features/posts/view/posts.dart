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
    // Fetch posts when the widget is initialized
    final postsCubit = BlocProvider.of<PostsCubit>(context);
    postsCubit.getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PostsCubit, PostsState>(
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final posts = state.posts; // Use posts from state
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostWidget(
                  post: posts[index],
                  username: 'shroida', // Update this as needed
                );
              },
            );
          } else if (state is PostsError) {
            return Center(
              child: Text('Error: ${state.errorMsg}'),
            );
          } else {
            return const Center(child: Text('No posts available.'));
          }
        },
      ),
    );
  }
}