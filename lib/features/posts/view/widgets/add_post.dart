import 'package:chatoid/constants.dart';
import 'package:chatoid/features/messages/view/widgets/my_header_widget.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddPostScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the StoryCubit instance
    final postsCubit = BlocProvider.of<PostsCubit>(context, listen: false);
    final loginCubit = context.read<LoginCubit>();

    return Scaffold(
      backgroundColor: ChatAppColors.appBarColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyHeaderWidget(
            userProfile: loginCubit.currentUser,
            headername: 'Add post',
            leftIcon: Icons.abc,
            backgroundColor: ChatAppColors.appBarColor,
          ),

          // Expanded TextField section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type your post...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: ChatAppColors.appBarColor,
                ),
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
              ),
            ),
          ),

          // Use a Container to give a finite size to the Stack
          SizedBox(
            height: 80, // Define a height for the Container
            child: Stack(
              children: [
                // Positioned button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send,
                          color: ChatAppColors.appBarColor),
                      onPressed: () async {
                        final storyText = _controller.text;

                        // Call the addToStory method from StoryCubit
                        if (storyText.isNotEmpty) {
                          await postsCubit.insertPost(
                            loginCubit.currentUser.userId,
                            storyText,
                          );
                          Navigator.pop(context);
                        } else {
                          // Handle empty story text case, e.g., show a SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a story.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
