import 'package:chatoid/features/posts/view/posts.dart';
import 'package:chatoid/features/story/view/story_list.dart';
import 'package:flutter/material.dart';

class HomeScreenStoryPosts extends StatefulWidget {
  const HomeScreenStoryPosts({super.key});

  @override
  HomeScreenStoryPostsState createState() => HomeScreenStoryPostsState();
}

class HomeScreenStoryPostsState extends State<HomeScreenStoryPosts> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StoryList(),
        Divider(
          indent: 10,
          endIndent: 10,
          thickness: 2,
          color: Colors.grey,
        ),
        Expanded(child: Posts()),
      ],
    );
  }
}
