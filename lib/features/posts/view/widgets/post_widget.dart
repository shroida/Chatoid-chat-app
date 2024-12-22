import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
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
    final loginCubit = BlocProvider.of<LoginCubit>(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Image.asset('assets/profile.gif'),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  postsCubit.formatMessageDate(post.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.clip,
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.postsText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.clip,
              maxLines: 20,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    postsCubit.increaseReacts(post.postID,loginCubit.currentUser.username);
                  },
                  icon: const Icon(
                    Icons.favorite,
                    size: 25,
                    color: Colors.red,
                  ),
                  label: Text('${post.reacts}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black)),
                ),
                const Icon(
                  Icons.comment,
                  size: 25,
                  color: Colors.blue,
                ),
                const Icon(
                  Icons.share,
                  size: 25,
                  color: Colors.blue,
                ),
              ],
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
