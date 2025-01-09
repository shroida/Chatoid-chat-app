import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PostWidget extends StatefulWidget {
  final ClsPost post;
  final UserData user;
  const PostWidget({super.key, required this.post, required this.user});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
                    ClipOval(
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Image.asset(widget.user.profileImage.isNotEmpty
                            ? widget.user.profileImage
                            : 'assets/profile.gif'),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      widget.user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  postsCubit.formatMessageDate(widget.post.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.postsText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.clip,
              maxLines: 20,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    if (context.mounted) {
                      setState(() {
                        widget.post.reacts += 1; // Increase the react count
                      });
                      await postsCubit.increaseReacts(
                          widget.post.postID, loginCubit.currentUser.username);
                    }
                  },
                  icon: const Icon(
                    Icons.favorite,
                    size: 25,
                    color: Colors.red,
                  ),
                  label: Text(
                    '${widget.post.reacts}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.comment,
                  size: 25,
                  color: Colors.blue,
                ),
                if (loginCubit.currentUser.userId == widget.post.userID)
                  GestureDetector(
                      onTap: () {
                        if (loginCubit.currentUser.userId ==
                            widget.post.userID) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: 'Delete post\n"${widget.post.postsText}"',
                            confirmBtnText: 'Delete!',
                            onConfirmBtnTap: () {
                              postsCubit.deletePost(widget.post.postID);
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                else
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
