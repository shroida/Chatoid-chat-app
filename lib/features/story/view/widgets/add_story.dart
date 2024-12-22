import 'package:chatoid/constants.dart';
import 'package:chatoid/features/messages/view/widgets/my_header_widget.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddStoryScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the StoryCubit instance
    final storyCubit = BlocProvider.of<StoryCubit>(context, listen: false);
    // Optionally, you can get the current user from LoginCubit
    final loginCubit = context.read<LoginCubit>();

    return Scaffold(
      backgroundColor: ChatAppColors.appBarColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyHeaderWidget(
            userProfile: loginCubit.currentUser,
            headername: 'Add Story',
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
                  hintText: 'Tell your story...',
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
                          await storyCubit.addToStory(storyText, context);
                        

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
