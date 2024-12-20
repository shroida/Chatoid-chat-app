import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final ClsPost post;
  final String username;
  const PostWidget({super.key, required this.post, required this.username});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite,
                    size: 25,
                    color: Colors.red,
                  ),
                  label: Text('${post.reacts} Like',
                      style: const TextStyle(color: Colors.black)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.comment,
                    size: 25,
                    color: Colors.blue,
                  ),
                  label: const Text('Comment',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share,
                    size: 25,
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
