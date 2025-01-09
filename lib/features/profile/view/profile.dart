import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/posts/model/cls_post.dart';
import 'package:chatoid/features/posts/view/widgets/post_widget.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:chatoid/features/profile/view/widgets/card_friend.dart';
import 'package:chatoid/features/profile/view/widgets/card_story.dart';
import 'package:chatoid/features/profile/view/widgets/profile_friends_image.dart';
import 'package:chatoid/features/profile/view/widgets/send_request.dart';
import 'package:chatoid/features/profile/view/widgets/smooth_indicator_profile.dart';
import 'package:chatoid/features/profile/view/widgets/text_friend_stories_row.dart';
import 'package:chatoid/features/profile/view_model/cubit/profile_cubit.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';

class Profile extends StatefulWidget {
  final UserData userProfile;

  const Profile({super.key, required this.userProfile});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  late final PageController _controller;
  late List<UserData> friendData;
  late List<Story> storyProfile;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    friendData = [];
    storyProfile = [];
    initializeData();
  }

  Future<void> initializeData() async {
    await initializeFriendData();
    await getStoriesProfile();
  }

  Future<void> initializeFriendData() async {
    final isCurrentUser = widget.userProfile.userId == 0;

    if (isCurrentUser) {
      friendData = context.read<ChatsCubit>().friendsList;
    } else {
      friendData = await context
          .read<ProfileCubit>()
          .fetchFriends(widget.userProfile.friendId);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getStoriesProfile() async {
    final storyCubit = context.read<StoryCubit>();
    storyProfile = storyCubit.allStories
        .where((story) => story.userId == widget.userProfile.userId)
        .toList();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    final storyCubit = context.read<StoryCubit>();
    final postsCubit = context.read<PostsCubit>();
    final themeCubit = context.read<ThemeCubit>();
    final chatsCubit = context.read<ChatsCubit>();

    final currentUser = loginCubit.currentUser;
    final isCurrentUserProfile =
        widget.userProfile.userId == currentUser.userId;

    final posts = postsCubit.allPosts.where((post) {
      return isCurrentUserProfile
          ? post.userID == currentUser.userId
          : post.userID == widget.userProfile.friendId;
    }).toList();
    final stories = storyCubit.allStories.where((story) {
      return isCurrentUserProfile
          ? story.userId == currentUser.userId
          : story.userId == widget.userProfile.friendId;
    }).toList();

    final totalLikes = posts.fold(0, (sum, post) => sum + post.reacts);
    final areFriends = chatsCubit.friendsList.any((friend) =>
        friend.friendId == widget.userProfile.friendId &&
        friend.userId == currentUser.userId);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileFriendsImage(
              likes: totalLikes,
              friendData: friendData,
              isCurrentUserProfile: isCurrentUserProfile,
              userProfile: widget.userProfile,
            ),
            const SizedBox(height: 25),
            Text(
              isCurrentUserProfile
                  ? currentUser.username
                  : widget.userProfile.username,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (!isCurrentUserProfile)
              SendRequest(
                areFriends: areFriends,
                currentUser: currentUser,
                profileFriend: widget.userProfile,
              ),
            const Divider(),
            const TextFriendStoriesRow(),
            const Divider(),
            SmoothIndicatorProfile(controller: _controller),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildPageContent(index, isCurrentUserProfile, stories,
                      posts, chatsCubit, themeCubit);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(
      int index,
      bool isCurrentUserProfile,
      List<Story> stories,
      List<ClsPost> posts,
      ChatsCubit chatsCubit,
      ThemeCubit themeCubit) {
    switch (index) {
      case 0:
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostWidget(
              user: isCurrentUserProfile
                  ? context.read<LoginCubit>().currentUser
                  : widget.userProfile,
              post: posts[index],
            );
          },
        );
      case 1:
        final friends =
            isCurrentUserProfile ? chatsCubit.friendsList : friendData;
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return CardFriend(
              username: friends[index].username,
              themeCubit: themeCubit,
            );
          },
        );
      case 2:
        return ListView.builder(
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            return CardStory(
              storyText: story.storyText,
              username: widget.userProfile.username,
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
