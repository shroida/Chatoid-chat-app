import 'dart:async';
import 'package:chatoid/zRefactor/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/text_friend_stories_row.dart';
import 'package:chatoid/zRefactor/features/story/model/story.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/card_friend.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/card_story.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/profile_friends_image.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/send_request.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/smooth_indicator_profile.dart';
import 'package:chatoid/zRefactor/features/profile/view_model/cubit/profile_cubit.dart';
import 'package:chatoid/zRefactor/features/story/view_model/cubit/story_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/zRefactor/core/utlis/user_data.dart';

class Profile extends StatefulWidget {
  final UserData userProfile;

  const Profile({
    super.key,
    required this.userProfile,
  });

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  List<UserData> friendData = [];
  List<Story> storyProfile = [];

  final _controller = PageController();
  @override
  void initState() {
    super.initState();
    initializeFriendData();
    initializeProfile(); // Call the async initialization method
    getStoriesProfile(); // Synchronous call to fetch stories
  }

  /// Initialize friendData from ChatsCubit
  void initializeFriendData() {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    friendData = List.from(chatsCubit.friendsList); // Use current friendsList
    print("Initialized friendData: $friendData");
  }

  /// Asynchronous initialization logic
  Future<void> initializeProfile() async {
    bool isCurrentUserProfileInit = widget.userProfile.user_id == 0;

    if (isCurrentUserProfileInit) {
      print("I'm the current user.");
      print("Is current user profile initialized: $isCurrentUserProfileInit");
      print("Is current user  ${widget.userProfile}");
      fetchFriendsFromCubit();
    } else {
      final profileCubit = BlocProvider.of<ProfileCubit>(context);

      friendData = await profileCubit.fetchFriends(widget.userProfile.friendId);
      setState(() {});
    }
  }

  void fetchFriendsFromCubit() {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    setState(() {
      friendData = List.from(chatsCubit.friendsList); // Refresh friendData
    });
    print("friendData updated: $friendData.");
  }

  void getStoriesProfile() {
    final storyCubit = BlocProvider.of<StoryCubit>(context, listen: false);
    storyCubit.fetchAllStories(); // Ensure stories are fetched
    storyProfile = storyCubit.allStories
        .where((story) => story.userId == widget.userProfile.friendId)
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = BlocProvider.of<ChatsCubit>(context);
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final themeCubit = BlocProvider.of<ThemeCubit>(context);
    bool areFriends = chatCubit.friendsList.any((friend) =>
        friend.friendId == widget.userProfile.friendId &&
        friend.user_id == authProvider.currentUser.user_id);

    String currentUserName = authProvider.currentUser.username;

    bool isCurrentUserProfile = widget.userProfile.user_id == 0 &&
        widget.userProfile.user_id != authProvider.currentUser.user_id;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(authProvider.currentUser.username),
            ProfileFriendsImage(
              friendData: friendData,
              isCurrentUserProfile: isCurrentUserProfile,
              userProfile: widget.userProfile,
            ),
            const SizedBox(
              height: 25,
            ),
            isCurrentUserProfile
                ? Text(
                    currentUserName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Column(
                    children: [
                      Text(
                        widget.userProfile.username,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SendRequest(
                          areFriends: areFriends,
                          currentUserId: authProvider.currentUser.user_id,
                          profileFriend: widget.userProfile),
                    ],
                  ),
            const SizedBox(height: 20),
            const Divider(),
            const TextFriendStoriesRow(),
            const Divider(),
            SmoothIndicatorProfile(
              controller: _controller,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 2, // Two pages: one for friends, one for stories
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // First Page: Friends List
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              key: ValueKey(friendData),
                              itemCount: widget.userProfile.user_id != 0
                                  ? friendData.length
                                  : chatCubit.friendsList.length,

                              // itemCount: widget.userProfile.user_id != 0
                              //     ? chatCubit.friendsList.length
                              //     : friendData.length,
                              itemBuilder: (context, index) {
                                final friend = widget.userProfile.user_id != 0
                                    ? friendData[index]
                                    : chatCubit.friendsList[index];
                                // final friend = widget.userProfile.user_id != 0
                                //     ? chatCubit.friendsList[index]
                                //     : friendData[index];

                                return CardFriend(
                                  username: friend.username,
                                  themeCubit: themeCubit,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Second Page: Stories
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: storyProfile.length,
                              itemBuilder: (context, index) {
                                final story = storyProfile[index];
                                return CardStory(
                                  storyText: story.storyText,
                                  username: widget.userProfile.username,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
