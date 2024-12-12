import 'dart:async';

import 'package:chatoid/data/models/story/story.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/card_friend.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/card_story.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/profile_friends_image.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/send_request.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/smooth_indicator_profile.dart';
import 'package:chatoid/zRefactor/features/profile/view/widgets/text_friend_stories_row.dart';
import 'package:chatoid/zRefactor/features/profile/view_model/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:provider/provider.dart';

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
    print("Test Friend Data before initialization: $friendData");
    initializeProfile(); // Call the async initialization method
    getStoriesProfile(); // Synchronous call to fetch stories
  }

  /// Asynchronous initialization logic
  Future<void> initializeProfile() async {
    bool isCurrentUserProfileInit = widget.userProfile.user_id == 0;

    if (isCurrentUserProfileInit) {
      print("I'm the current user.");
      print("Is current user profile initialized: $isCurrentUserProfileInit");
      fetchFriendsFromCubit();
    } else {
      print("I'm not the current user.");
      print("Is current user profile initialized: $isCurrentUserProfileInit");

      // Fetch friends asynchronously
      friendData = await fetchFriendsIfNotCurrent();

      // Debugging to confirm data update
      print("Updated Friend Data: $friendData");

      // Refresh UI with updated friendData
      setState(() {});
    }
  }

  /// Fetch friends from ChatsCubit for the current user
  void fetchFriendsFromCubit() {
    final friendsList = BlocProvider.of<ChatsCubit>(context).friendsList;

    setState(() {
      friendData = friendsList; // Update friendData with Cubit's list
    });

    print("Friend Data from ChatsCubit: $friendData");
    print("Friend Data from ChatsCubit length: ${friendData.length}");
  }

  Future<List<UserData>> fetchFriendsIfNotCurrent() async {
    final profileCubit = BlocProvider.of<ProfileCubit>(context);
    return profileCubit.fetchFriends(widget.userProfile.friendId);
  }

  Future<void> fetchFriendsIfCurrent() async {
    final profileCubit = BlocProvider.of<ProfileCubit>(context);
    final loginCubit = BlocProvider.of<LoginCubit>(context);

    await profileCubit.fetchFriends(loginCubit.currentUser.user_id);
  }

  void getStoriesProfile() {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    if (widget.userProfile.user_id != 0) {
      storyProfile = storyProvider.allStories
          .where((story) => story.userId == widget.userProfile.friendId)
          .toList();
    } else {
      final authProvider = BlocProvider.of<LoginCubit>(context);
      print('auth cueuureuuruurueu${authProvider.currentUser.user_id}');
      storyProfile = storyProvider.allStories
          .where((story) => story.userId == authProvider.currentUser.user_id)
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = BlocProvider.of<ChatsCubit>(context);
    final authProvider = BlocProvider.of<LoginCubit>(context);
    bool areFriends = chatProvider.friendsList.any((friend) =>
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
                              itemCount: friendData.length,
                              // itemCount: widget.userProfile.user_id != 0
                              //     ? chatProvider.friendsList.length
                              //     : friendData.length,
                              itemBuilder: (context, index) {
                                final friend = friendData[index];
                                // final friend = widget.userProfile.user_id != 0
                                //     ? chatProvider.friendsList[index]
                                //     : friendData[index];

                                return CardFriend(username: friend.username);
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
