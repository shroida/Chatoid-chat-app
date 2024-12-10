import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/zRefactor/features/home_page/view/Home_Page.dart';
import 'package:chatoid/presntation/screens/chat_screen.dart';
import 'package:chatoid/presntation/widgets/chatCard.dart';
import 'package:chatoid/presntation/screens/stories/story_element.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class HomePageChats extends StatefulWidget {
  const HomePageChats({super.key});

  @override
  HomePageChatsState createState() => HomePageChatsState();
}

class HomePageChatsState extends State<HomePageChats> {
  int _currentIndexHomePage = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = BlocProvider.of<ThemeCubit>(context, listen: true);
    final chatProvider = Provider.of<ChatProvider>(context, listen: true);

    return Scaffold(
      body: Column(
        children: [
          _buildTabBar(themeProvider),
          Expanded(
            child: _currentIndexHomePage == 0
                ? _buildMessagesSection(chatProvider) // Pass chatProvider here
                : _currentIndexHomePage == 1
                    ? _buildGroupsSection()
                    : _buildSettingsSection(context, themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeCubit themeProvider) {
    return Container(
      margin: const EdgeInsets.all(29.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, "Messages", 0, themeProvider),
          _buildTabItem(context, "Groups", 1, themeProvider),
          _buildTabItem(context, "Themes", 2, themeProvider),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      BuildContext context, String label, int index, ThemeCubit themeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.07;

    return GestureDetector(
      onTap: () => setState(() {
        _currentIndexHomePage = index;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _currentIndexHomePage == index
              ? themeProvider.colorOfApp
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  _currentIndexHomePage == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesSection(ChatProvider chatProvider) {
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final themeCubit = BlocProvider.of<ThemeCubit>(context);

    return Column(
      children: [
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.isLoading) {
                return Center(child: Image.asset('assets/loading_earth.gif'));
              } else if (chatProvider.friendsList.isEmpty) {
                return Center(
                    child: Column(
                  children: [
                    Image.asset('assets/loading_earth.gif'),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 34),
                        decoration: BoxDecoration(
                          color: themeCubit.colorOfApp,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Show messages",
                          style: TextStyle(
                            color: ChatAppColors.iconColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ));
              } else {
                return _buildFriendsList(chatProvider, authProvider);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsList(ChatProvider chatProvider, LoginCubit authProvider) {
    List<UserData> sortedFriendsList = List.from(chatProvider.friendsList);

    sortedFriendsList.sort((a, b) {
      final lastMessageA = _getLastMessage(chatProvider, authProvider, a);
      final lastMessageB = _getLastMessage(chatProvider, authProvider, b);

      if (lastMessageA == null && lastMessageB == null) {
        return 0; // If both have no messages, keep the order as is
      } else if (lastMessageA == null) {
        return 1; // If 'a' has no messages, it should go after 'b'
      } else if (lastMessageB == null) {
        return -1; // If 'b' has no messages, it should go after 'a'
      } else {
        // Both have messages, compare by creation date
        return lastMessageB.createdAt.compareTo(lastMessageA.createdAt);
      }
    });

    return Expanded(
      child: sortedFriendsList.isEmpty
          ? const Center(child: Text("No friends found."))
          : ListView.builder(
              itemCount: sortedFriendsList.length,
              itemBuilder: (context, index) {
                final friend = sortedFriendsList[index];
                final lastMessage =
                    _getLastMessage(chatProvider, authProvider, friend);

                List<clsMessage> unreadMessages = _messagesNotReadByMe(
                    chatProvider.friendMessages,
                    friend.friendId,
                    authProvider.currentUser.user_id);
                final messagesCount = getCountMessage(unreadMessages);

                bool isLastMessageFromFriend(
                    clsMessage lastMessage, UserData friend) {
                  return lastMessage.senderId == friend.friendId;
                }

                bool isLastMessageSeenByUser(clsMessage lastMessage) {
                  return lastMessage.isRead;
                }

                return ChatCard(
                  messageDate: lastMessage != null
                      ? _formatDate(lastMessage.createdAt)
                      : "No messages", // Display "No messages" if there are no messages
                  friendData: friend,
                  messageCount: messagesCount,
                  messageText: lastMessage?.messageText ??
                      "No messages yet", // Handle no message text
                  isLastMessageFromFriend: lastMessage != null
                      ? isLastMessageFromFriend(lastMessage, friend)
                      : false,
                  isLastMessageSeenByUser: lastMessage != null
                      ? isLastMessageSeenByUser(lastMessage)
                      : false,
                  onTap: () {
                    chatProvider.onEnterChat(
                      friend.friendId,
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(friendUser: friend)));
                  },
                );
              },
            ),
    );
  }

  Widget _buildGroupsSection() {
    return Text('We will add this feature soon!');
  }

  Widget _buildSettingsSection(BuildContext context, ThemeCubit themeProvider) {
    List<Color> colors = [
      const Color.fromARGB(0, 96, 76, 212),
      ChatAppColors.primaryColor,
      ChatAppColors.primaryColor2,
      ChatAppColors.primaryColor3,
      ChatAppColors.primaryColor4,
    ];

    return Center(
      child: CarouselSlider(
        items: colors.map((color) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const SizedBox(height: 20),
          );
        }).toList(),
        options: CarouselOptions(
          height: 300,
          onPageChanged: (index, reason) {
            themeProvider.toggleBackground(index);
            themeProvider.saveColorOfApp(colors[index]);
          },
          enableInfiniteScroll: false,
          initialPage: 0,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String hour = '';
    hour = (date.hour < 10 ? '0' : '') +
        (date.hour > 12 ? '0${date.hour - 12}' : date.hour.toString());

    String minute = date.minute < 10 ? '0${date.minute}' : '${date.minute}';

    return "$hour:$minute";
  }

  clsMessage? _getLastMessage(
      ChatProvider chatProvider, LoginCubit authProvider, UserData friend) {
    // Get all messages between the current user and the friend
    List<clsMessage> conversationMessages = chatProvider.friendMessages
        .where((msg) =>
            (msg.senderId == friend.friendId &&
                msg.friendId == authProvider.currentUser.user_id) ||
            (msg.senderId == authProvider.currentUser.user_id &&
                msg.friendId == friend.friendId))
        .toList();

    // Sort messages by createdAt in descending order
    conversationMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Return the most recent message, or null if none exist
    return conversationMessages.isNotEmpty ? conversationMessages.first : null;
  }

  List<clsMessage> _messagesNotReadByMe(
      List<clsMessage> messageFromUserNotReadByMe,
      int friendId,
      int currentUserId) {
    return messageFromUserNotReadByMe
        .where((msg) =>
            friendId == msg.senderId &&
            !msg.isRead &&
            msg.friendId == currentUserId)
        .toList();
  }

  int getCountMessage(List<clsMessage> msgsUnRead) {
    return msgsUnRead.length; // Return the count of unread messages
  }
}
