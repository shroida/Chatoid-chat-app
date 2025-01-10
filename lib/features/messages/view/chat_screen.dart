import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/messages/view/widgets/message_input_areal.dart';
import 'package:chatoid/features/messages/view/widgets/button_scroll_down.dart';
import 'package:chatoid/features/messages/view/widgets/messages_list.dart';
import 'package:chatoid/features/messages/view/widgets/my_header_widget.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/view/widgets/text_in_chat.dart';
import 'package:chatoid/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final UserData friendUser;

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

  void _updateReplyState(bool willReply) {
    setState(() {
      iWillReply = willReply;
    });
  }

  void _updateMessageTextToReply(String? textToReply) {
    setState(() {
      messageTextToReply = textToReply;
    });
  }

  @override
  void initState() {
    super.initState();
    Future<void> checkIfUsersInChat() async {
      final loginCubit = context.read<LoginCubit>();
      final currentUserId = loginCubit.currentUser.userId;
      final messagesCubit = Provider.of<MessagesCubit>(context, listen: false);

      bool isInChat = await messagesCubit.ifTwoUsersInChat(
          currentUserId, widget.friendUser.friendId);

      setState(() {
        _isInChat = isInChat;
      });
    }

    checkIfUsersInChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatsCubit = Provider.of<ChatsCubit>(context, listen: false);
      final messagesCubit = Provider.of<MessagesCubit>(context, listen: false);
      final loginCubit = context.read<LoginCubit>();

      chatsCubit.fetchAllMessages(loginCubit.currentUser);

      chatsCubit.subscribe('messages', () async {
        await chatsCubit.fetchAllMessages(loginCubit.currentUser);
        if (_scrollController.hasClients) {
          _scrollToBottom();
        }
      });
      chatsCubit.subscribe('user_profiles', () async {
        await messagesCubit.ifTwoUsersInChat(
            loginCubit.currentUser.userId, widget.friendUser.friendId);
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
    final loginCubit = Provider.of<LoginCubit>(context);
    final chatsCubit = Provider.of<ChatsCubit>(context);
    final themeCubit = context.read<ThemeCubit>();

    final currentUserId = loginCubit.currentUser.userId;
    final messages = chatsCubit.friendMessages
        .where((message) =>
            (message.senderId == currentUserId &&
                message.friendId == widget.friendUser.friendId) ||
            (message.senderId == widget.friendUser.friendId &&
                message.friendId == currentUserId))
        .toList();

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    Future<bool> onWillPop() async {
      final messagesCubit = Provider.of<MessagesCubit>(context, listen: false);
      messagesCubit.onLeaveChat();
      setState(() {
        _isInChat = false;
      });
      return true;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        onWillPop();
      },
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
                    if (_isInChat) const TextInChat(),
                    MessageListView(
                      messsagReply: messageTextToReply,
                      messages: messages,
                      currentUserId:
                          currentUserId, // Replace with the actual user ID
                      scrollController: _scrollController,
                      focusNode: _focusNode,
                      dragOffsets: dragOffsets,
                      onReplyChanged: _updateReplyState,
                      onMessageTextToReplyChanged: _updateMessageTextToReply,
                      friendUser: widget.friendUser,
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
                ButtonScrollDown(
                  scrollToBottom: _scrollToBottom,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(
      int currentUserId, int friendUserId, String message, bool inChat) async {
    final loginCubit = context.read<LoginCubit>();
    final chatsCubit = context.read<MessagesCubit>();

    if (inChat) {
      if (!iWillReply) {
        await chatsCubit.sendMessage(loginCubit.currentUser.userId,
            widget.friendUser.friendId, _messageController.text,
            makeItReadWeAreInChat: true);
      } else {
        await chatsCubit.sendMessage(loginCubit.currentUser.userId,
            widget.friendUser.friendId, _messageController.text,
            willReply: iWillReply,
            messageTextWillReply: messageTextToReply,
            makeItReadWeAreInChat: true);
      }
    } else {
      if (!iWillReply) {
        await chatsCubit.sendMessage(
          loginCubit.currentUser.userId,
          widget.friendUser.friendId,
          _messageController.text,
        );
      } else {
        await chatsCubit.sendMessage(
          loginCubit.currentUser.userId,
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
}
