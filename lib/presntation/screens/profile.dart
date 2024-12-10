import 'dart:async';

import 'package:chatoid/data/models/story/story.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/data/provider/story_provider.dart';
import 'package:chatoid/zRefactor/features/home_page/view/Home_Page.dart';
import 'package:chatoid/presntation/screens/chat_screen.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    if (widget.userProfile.user_id == 0) {
      friendData =
          Provider.of<ChatProvider>(context, listen: false).friendsList;
    } else {
      fetchFriendsIfNotCurrent();
    }
    print("Friend Data: $friendData");

    getStoriesProfile();
  }

  Future<void> fetchFriends(int currentUserId) async {
    try {
      final response = await supabase.client
          .from('friendships')
          .select(
              'user_id, friend_id, user_profiles_friend:friend_id(username, email), user_profiles_user:user_id(username, email)')
          .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId');

      if (response.isNotEmpty) {
        final Set<int> uniqueFriendIds = Set();

        for (var friend in response) {
          int friendUserId;
          Map<String, dynamic> userProfile;

          if (friend['user_id'] == currentUserId) {
            friendUserId = friend['friend_id'];
            userProfile =
                friend['user_profiles_friend'] as Map<String, dynamic>;
          } else {
            friendUserId = friend['user_id'];
            userProfile = friend['user_profiles_user'] as Map<String, dynamic>;
          }

          if (uniqueFriendIds.add(friendUserId)) {
            friendData.add(UserData.fromJson({
              'friend_id': friendUserId,
              'user_id': currentUserId,
              'username': userProfile['username'] ?? 'Unknown User',
              'email': userProfile['email'] ?? 'Unknown Email',
            }));
          }
        }
      }
    } catch (e) {
      print("Error fetching friends: $e");
    }
  }

  Future<void> fetchFriendsIfNotCurrent() async {
    if (widget.userProfile.user_id != 0) {
      await fetchFriends(widget.userProfile.friendId);
    }
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

  void _showSliderBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: true);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 200, // Adjust the height of the slider
              enlargeCenterPage: true, // Zoom in the centered item
              autoPlay: true, // Auto slide the images
              autoPlayInterval:
                  const Duration(seconds: 3), // Duration between slides
              enableInfiniteScroll: true, // Loop through the items
              viewportFraction:
                  0.8, // How much of the previous/next item is visible
            ),
            items: profilesImages.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        print(
                            'Displaying profile for: ${widget.userProfile.username}');
                        // setState(() {
                        //   chatProvider.upLoadImageProfile(
                        //       imagePath,
                        //       widget.userProfile
                        //           .user_id);
                        //   widget.userProfile.profile_image = imagePath;
                        //   Navigator.pop(context);
                        // });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: 200,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = BlocProvider.of<LoginCubit>(context);
    bool areFriends = chatProvider.friendsList.any((friend) =>
        friend.friendId == widget.userProfile.friendId &&
        friend.user_id == authProvider.currentUser.user_id);
    String currentUserName = authProvider.currentUser.username;
    bool isCurrentUserProfile = widget.userProfile.user_id == 0 &&
        widget.userProfile.user_id == authProvider.currentUser.user_id;

    Future<void> _refreshData() async {
      await Future.delayed(const Duration(seconds: 2));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      print(
                          'Displaying profiless fossssr: ${currentUserName} ');

                      _showSliderBottomSheet();
                    }, // Show slider on tap
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/profile.gif',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.userProfile.user_id == 0
                                ? chatProvider.friendsList.length.toString()
                                : friendData.length.toString(),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            'Friends',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'isCurrentUserProfile ${isCurrentUserProfile}',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'widget.userProfile.user_id ${widget.userProfile.user_id}',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'isCurrentUserProfile ${widget.userProfile.friendId}',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 25,
              ),
              widget.userProfile.user_id == 0
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (areFriends) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'You are already friends with ${widget.userProfile.username}.'),
                                    ),
                                  );
                                } else {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.confirm,
                                    title: "Confirm Friend Request",
                                    text:
                                        "Send a friend request to ${widget.userProfile.username}?",
                                    confirmBtnText: "Yes",
                                    cancelBtnText: "No",
                                    onConfirmBtnTap: () {
                                      chatProvider.addFriend(
                                        authProvider.currentUser.user_id,
                                        widget.userProfile,
                                      );
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage()));
                                    },
                                    onCancelBtnTap: () =>
                                        Navigator.pop(context),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: ChatAppColors.appBarColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2)),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                        areFriends
                                            ? Icons.emoji_emotions
                                            : Icons.person_add,
                                        color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      areFriends
                                          ? "We are friends"
                                          : "Send Request",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        friendUser: widget.userProfile),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 34),
                                decoration: BoxDecoration(
                                  color: ChatAppColors.chatTextColorReceiver,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Message",
                                  style: TextStyle(
                                    color: ChatAppColors.iconColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              const Divider(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Friends",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Stories",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              SmoothPageIndicator(
                controller: _controller,
                count: 2,
                effect: WormEffect(
                  activeDotColor: Colors.blue,
                  dotColor: Colors.white.withOpacity(0.5),
                  dotHeight: 10,
                  dotWidth: 100,
                  spacing: 8.0,
                ),
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
                                itemCount: widget.userProfile.user_id != 0
                                    ? chatProvider.friendsList.length
                                    : friendData.length,
                                itemBuilder: (context, index) {
                                  final friend = widget.userProfile.user_id != 0
                                      ? chatProvider.friendsList[index]
                                      : friendData[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    padding: const EdgeInsets.all(
                                        20), // Adjust padding as needed
                                    decoration: BoxDecoration(
                                      color: ChatAppColors.appBarColor,
                                      borderRadius: BorderRadius.circular(
                                          16), // Add border radius here
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipOval(
                                          // This makes the CircleAvatar a perfect circle
                                          child: CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            child: Image.asset(
                                                'assets/profile.gif'),
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                8), // Add some spacing between avatar and text
                                        Text(
                                          friend.username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ), // Adjust text style as needed
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
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
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal:
                                            20), // Adjust margins as needed
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 20, bottom: 80),
                                    decoration: BoxDecoration(
                                      color: ChatAppColors.appBarColor,
                                      borderRadius: BorderRadius.circular(
                                          16), // Add border radius here
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            ClipOval(
                                              child: CircleAvatar(
                                                backgroundColor: Colors.blue,
                                                child: Image.asset(
                                                    'assets/profile.gif'),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              widget.userProfile.username,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight
                                                      .bold), // Adjust text style as needed
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          story.storyText,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight
                                                  .bold), // Adjust text style as needed
                                        ),
                                      ],
                                    ),
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
      ),
    );
  }
}
