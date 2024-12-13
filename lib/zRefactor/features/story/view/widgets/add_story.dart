import 'package:chatoid/constants.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/messages/view/widgets/my_header_widget.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStoryScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the StoryProvider instance
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
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

                        // Call the addToStory method from StoryProvider
                        if (storyText.isNotEmpty) {
                          await storyProvider.addToStory(storyText, context);
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
