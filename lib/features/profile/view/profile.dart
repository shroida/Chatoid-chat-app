import 'dart:async';
import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view/widgets/post_widget.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:chatoid/features/profile/view/widgets/text_friend_stories_row.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/profile/view/widgets/card_friend.dart';
import 'package:chatoid/features/profile/view/widgets/card_story.dart';
import 'package:chatoid/features/profile/view/widgets/profile_friends_image.dart';
import 'package:chatoid/features/profile/view/widgets/send_request.dart';
import 'package:chatoid/features/profile/view/widgets/smooth_indicator_profile.dart';
import 'package:chatoid/features/profile/view_model/cubit/profile_cubit.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/core/utlis/user_data.dart';

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
    initializeProfile();
    getStoriesProfile();
  }

  void initializeFriendData() {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    friendData = List.from(chatsCubit.friendsList);
  }

  Future<void> initializeProfile() async {
    bool isCurrentUserProfileInit = widget.userProfile.userId == 0;

    if (isCurrentUserProfileInit) {
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
    final postsCubit = BlocProvider.of<PostsCubit>(context);
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final themeCubit = BlocProvider.of<ThemeCubit>(context);
    bool areFriends = chatCubit.friendsList.any((friend) =>
        friend.friendId == widget.userProfile.friendId &&
        friend.userId == authProvider.currentUser.userId);
    String currentUserName = authProvider.currentUser.username;
    List<ClsPost> myPosts = postsCubit.allPosts
        .where((post) => post.userID == authProvider.currentUser.userId)
        .toList();
    List<ClsPost> friendPosts = postsCubit.allPosts
        .where((post) => post.userID == widget.userProfile.friendId)
        .toList();

    bool isCurrentUserProfile =
        widget.userProfile.userId != 0 && widget.userProfile.friendId == 0&&widget.userProfile.username == authProvider.currentUser.username;
    int totalLikes = isCurrentUserProfile
        ? myPosts.fold(0, (sum, post) => sum + post.reacts)
        : friendPosts.fold(0, (sum, post) => sum + post.reacts);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
                print('username profile ${widget.userProfile.username}');
                print('friendId userProfile ${widget.userProfile.friendId}');
                print('userId userProfile ${widget.userProfile.userId}');
                print('is current $isCurrentUserProfile');
             
            }, child: Text(widget.userProfile.username)),
            ProfileFriendsImage(
              likes: totalLikes,
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
                          currentUser: authProvider.currentUser,
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
                itemCount: 3,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            key: ValueKey(friendData),
                            itemCount: isCurrentUserProfile
                                ? myPosts.length
                                : friendPosts.length,
                            itemBuilder: (context, index) {
                              final post = isCurrentUserProfile
                                  ? myPosts[index]
                                  : friendPosts[index];

                              return PostWidget(
                                username: isCurrentUserProfile
                                    ? authProvider.currentUser.username
                                    : widget.userProfile.username,
                                post: post,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              key: ValueKey(friendData),
                              itemCount: !isCurrentUserProfile
                                  ? friendData.length
                                  : chatCubit.friendsList.length,
                              itemBuilder: (context, index) {
                                final friend = !isCurrentUserProfile
                                    ? friendData[index]
                                    : chatCubit.friendsList[index];

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
