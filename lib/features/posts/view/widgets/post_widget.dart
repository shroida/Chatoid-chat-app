import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostWidget extends StatelessWidget {
  final ClsPost post;
  final String username;
  const PostWidget({super.key, required this.post, required this.username});

  @override
  Widget build(BuildContext context) {
    final postsCubit = BlocProvider.of<PostsCubit>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.postsText,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.clip,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    postsCubit.increaseReacts(post.id);
                  },
                  icon: const Icon(
                    Icons.favorite,
                    size: 20,
                    color: Colors.red,
                  ),
                  label: Text('${post.reacts} Like',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.comment,
                    size: 20,
                    color: Colors.blue,
                  ),
                  label: const Text('Comment',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share,
                    size: 20,
                    color: Colors.blue,
                  ),
                  label: const Text('Share',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
