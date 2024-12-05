import 'package:chatoid/data/models/story/story.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/presntation/screens/stories/add_story.dart';
import 'package:chatoid/presntation/screens/stories/show_story.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoryWidget extends StatelessWidget {
  final String imageUrl;
  final String username;
  final bool isAddStory;
  final int storyCount;

  const StoryWidget({
    super.key,
    required this.imageUrl,
    required this.username,
    this.isAddStory = false,
    this.storyCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30), // Increase left padding
      margin: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,

                //borderStory
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: storyCount > 0 ? Colors.blue : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: isAddStory ? null : AssetImage(imageUrl),
                  backgroundColor: isAddStory ? Colors.grey[300] : null,
                  child: isAddStory
                      ? const Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            isAddStory ? 'Add Story' : username,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

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
                      builder: (context) => ShowStory(
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
                                    builder: (context) => ShowStory(
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
