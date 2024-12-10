import 'package:chatoid/constants.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:chatoid/zRefactor/features/home_page/view/home_page.dart';
import 'package:chatoid/presntation/screens/profile.dart';
import 'package:chatoid/presntation/widgets/mainMessage.dart';
import 'package:chatoid/presntation/widgets/messageInputAreal.dart';
import 'package:chatoid/presntation/widgets/my_header_widget.dart';
import 'package:chatoid/presntation/widgets/reaction_button.dart';
import 'package:chatoid/presntation/widgets/replyMessage.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final UserData friendUser; // Add friendUser

  const ChatScreen({
    super.key,
    required this.friendUser,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isScrollDownButtonVisible = false;
  Map<int, double> dragOffsets = {};
  bool iWillReply = false;
  String? messageTextToReply;
  bool _isInChat = false;

  @override
  void initState() {
    super.initState();
    Future<void> _checkIfUsersInChat() async {
      final loginCubit = context.read<LoginCubit>();
      final currentUserId = loginCubit.currentUser.user_id;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Call the function and update the state accordingly
      bool isInChat = await chatProvider.ifTwoUsersInChat(
          currentUserId, widget.friendUser.friendId);

      setState(() {
        _isInChat = isInChat;
      });
    }

    _checkIfUsersInChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final loginCubit = context.read<LoginCubit>();

      chatProvider.fetchAllMessages(loginCubit.currentUser);

      chatProvider.subscribe('messages', () async {
        await chatProvider.fetchAllMessages(loginCubit.currentUser);
        if (_scrollController.hasClients) {
          _scrollToBottom();
        }
      });
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <
          _scrollController.position.maxScrollExtent - 200) {
        setState(() {
          _isScrollDownButtonVisible = true;
        });
      } else {
        setState(() {
          _isScrollDownButtonVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<LoginCubit>(context);
    final themeCubit = context.read<ThemeCubit>();

    final currentUserId = authProvider.currentUser.user_id;
    final messages = chatProvider.friendMessages
        .where((message) =>
            (message.senderId == currentUserId &&
                message.friendId == widget.friendUser.friendId) ||
            (message.senderId == widget.friendUser.friendId &&
                message.friendId == currentUserId))
        .toList();

    // Sort messages by the time they were created (oldest at the top, newest at the bottom)
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    Future<bool> onWillPop() async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.onLeaveChat();
      return true; // Allows the back navigation
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Container(
                color: themeCubit.colorOfApp, // Use the current theme color
                child: Column(
                  children: [
                    MyHeaderWidget(
                      userProfile: widget.friendUser,
                      headername: widget.friendUser.username,
                      leftIcon: Icons.add_ic_call,
                      iconColor: Colors.black,
                      backgroundColor: themeCubit.colorOfApp,
                    ),
                    if (_isInChat)
                      Text(
                        'Y\'all in the chat',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 9, 225, 16),
                            fontWeight: FontWeight.w800),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final bool isSentByUser =
                              currentUserId == message.senderId;

                          dragOffsets[index] = dragOffsets[index] ?? 0;

                          return GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                double screenWidth =
                                    MediaQuery.of(context).size.width;
                                dragOffsets[index] = (dragOffsets[index]! +
                                        details.delta.dx)
                                    .clamp(0,
                                        MediaQuery.of(context).size.width / 2);

                                // Check if the drag offset reaches half of the screen width

                                if (dragOffsets[index]! > screenWidth / 2 + 2) {
                                  iWillReply = true;
                                } else {
                                  iWillReply = false;
                                }
                              });
                            },
                            onPanEnd: (details) async {
                              double screenWidth =
                                  MediaQuery.of(context).size.width;

                              if (dragOffsets[index]! > screenWidth / 2 - 5) {
                                setState(() {
                                  iWillReply = true;
                                  messageTextToReply = message.messageText;
                                });
                              } else {
                                setState(() {
                                  iWillReply = false;
                                  messageTextToReply = null;
                                });
                              }

                              // Keep the focus on the input field so the keyboard stays open
                              FocusScope.of(context).requestFocus(_focusNode);

                              setState(() {
                                dragOffsets[index] = 0;
                              });
                            },
                            onLongPress: () {
                              _showMessageOptions(
                                  chatProvider, context, message);
                            },
                            child: Transform.translate(
                                offset: Offset(dragOffsets[index]!, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: isSentByUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          if (message.messsagReply != null)
                                            MessageReplyDisplay(
                                              username:
                                                  widget.friendUser.username,
                                              replyMessage: message
                                                  .messsagReply!, // Pass the replied message
                                            ),
                                          MainMessage(
                                            message:
                                                message, // Pass the message object
                                            isSentByUser:
                                                isSentByUser, // Pass whether the message is sent by the user
                                            chatProvider:
                                                chatProvider, // Pass the ChatProvider instance
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 9,
                                    )
                                  ],
                                )),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MessageInputArea(
                            onCloseReply: () {
                              setState(() {
                                iWillReply = false;
                              });
                            },
                            iWillReply: iWillReply,
                            username: widget.friendUser.username,
                            messageTextToReply:
                                messageTextToReply, // Pass it directly
                            messageController: _messageController,
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.send,
                                  color: themeCubit.colorOfApp),
                              onPressed: () {
                                if (_messageController.text.isNotEmpty) {
                                  _sendMessage(
                                      currentUserId,
                                      widget.friendUser.friendId,
                                      _messageController.text,
                                      _isInChat);
                                  _messageController.clear();
                                  _scrollToBottom(); // Scroll to bottom after sending a message
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isScrollDownButtonVisible)
                Positioned(
                  bottom: 80,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: _scrollToBottom,
                    backgroundColor: ChatAppColors.backgroundColor,
                    child: const Icon(Icons.arrow_downward, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(
      int currentUserId, int friendUserId, String message, bool inChat) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final loginCubit = context.read<LoginCubit>();

    // Keep the focus on the existing FocusNode
    FocusScope.of(context).requestFocus(_focusNode);

    if (inChat) {
      if (!iWillReply) {
        await chatProvider.sendMessage(loginCubit.currentUser.user_id,
            widget.friendUser.friendId, _messageController.text,
            makeItReadWeAreInChat: true);
      } else {
        await chatProvider.sendMessage(loginCubit.currentUser.user_id,
            widget.friendUser.friendId, _messageController.text,
            willReply: iWillReply,
            messageTextWillReply: messageTextToReply,
            makeItReadWeAreInChat: true);
      }
    } else {
      if (!iWillReply) {
        await chatProvider.sendMessage(
          loginCubit.currentUser.user_id,
          widget.friendUser.friendId,
          _messageController.text,
        );
      } else {
        await chatProvider.sendMessage(
          loginCubit.currentUser.user_id,
          widget.friendUser.friendId,
          _messageController.text,
          willReply: iWillReply,
          messageTextWillReply: messageTextToReply,
        );
      }
    }

    iWillReply = false;

    _messageController.clear();
  }

  void _showMessageOptions(
      ChatProvider chatProvider, BuildContext context, clsMessage message) {
    void deleteMessage(clsMessage message) async {
      await chatProvider.deleteMessage(
          message); // Ensure this is awaited for proper execution
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Message'),
            onTap: () {
              deleteMessage(message); // Call your delete function
              Navigator.of(context).pop(); // Close the bottom sheet
            },
          ),
        ]);
      },
    );
  }
}
