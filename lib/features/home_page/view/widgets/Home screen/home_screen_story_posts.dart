import 'package:chatoid/features/posts/view/posts.dart';
import 'package:chatoid/features/story/view/story_list.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:chatoid/features/story/view_model/cubit/story_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenStoryPosts extends StatefulWidget {
  const HomeScreenStoryPosts({super.key});

  @override
  HomeScreenStoryPostsState createState() => HomeScreenStoryPostsState();
}

class HomeScreenStoryPostsState extends State<HomeScreenStoryPosts> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading) {
          return Center(child: Image.asset('assets/loading_earth.gif'));
        } else if (state is StoryLoaded) {
          return const Column(
            children: [
              StoryList(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 2,
                  color: Colors.grey,
                ),
              ),
              Expanded(child: Posts()), // Wrap in Expanded
            ],
          );
        } else if (state is StoryError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'Failed to load stories.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('Unexpected error occurred.'),
          );
        }
      },
    );
  }
}
