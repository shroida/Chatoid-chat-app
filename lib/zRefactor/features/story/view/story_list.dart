
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/story/view/widgets/add_story.dart';
import 'package:chatoid/zRefactor/features/story/view/widgets/story_view.dart';
import 'package:chatoid/zRefactor/features/story/view/widgets/story_element.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/story/model/story.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryList extends StatefulWidget {
  const StoryList({super.key});

  @override
  StoryListState createState() => StoryListState();
}

class StoryListState extends State<StoryList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).loadStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = Provider.of<LoginCubit>(context, listen: true);
    final storyProvider = Provider.of<StoryProvider>(context, listen: true);

    // Get the current user's stories
    final currentUserStories = storyProvider.allStories
        .where((story) => story.userId == loginCubit.currentUser.user_id)
        .toList();

    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (currentUserStories.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _showOptionsToAddStoryOrShow(
                      context, currentUserStories, loginCubit.currentUser);
                },
                child: StoryWidget(
                  imageUrl: 'assets/profile.gif',
                  username: 'My story',
                  storyCount: currentUserStories.length,
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStoryScreen(),
                    ),
                  );
                },
                child: const StoryWidget(
                  imageUrl: '',
                  username: 'Add Story',
                  isAddStory: true,
                ),
              ),
            const SizedBox(width: 10),
            ...storyProvider.usersStory.where((userData) {
              final user = userData.keys.first;
              // Filter out the current user's stories
              return user.user_id != loginCubit.currentUser.user_id;
            }).map((userData) {
              final user = userData.keys.first;
              final stories = userData[user];

              return GestureDetector(
                onTap: () {
                  storyProvider.setViewOnStory(
                      stories[0].id, loginCubit.currentUser.user_id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryView(
                        stories: stories,
                        username: user.username,
                        isCurrentUserStory: false,
                      ),
                    ),
                  );
                },
                child: StoryWidget(
                  imageUrl: 'assets/profile.gif',
                  username: user.username,
                  storyCount: stories!.length, // Pass the number of stories
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

void _showOptionsToAddStoryOrShow(BuildContext context,
    List<Story> currentUserStories, UserData currentUser) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(left: 30, bottom: 30),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddStoryScreen()));
                          },
                          child: const StoryWidget(
                            imageUrl: '',
                            username: 'Add Story',
                            isAddStory: true,
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 30, bottom: 30),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StoryView(
                                          isCurrentUserStory: true,
                                          stories: currentUserStories,
                                          username: currentUser.username,
                                        )));
                          },
                          child: const StoryWidget(
                            imageUrl: 'assets/boy1.gif',
                            username: 'My Story',
                            isAddStory: false,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      );
    },
  );
}