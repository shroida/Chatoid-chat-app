import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/view/widgets/Group%20Section/all_users_list.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/features/messages/view/widgets/main_message.dart';
import 'package:chatoid/features/messages/view/widgets/message_input_areal.dart';
import 'package:chatoid/features/messages/view/widgets/my_header_widget.dart';
import 'package:chatoid/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ChatScreenGroup extends StatefulWidget {
  const ChatScreenGroup({super.key, required this.allUsersMessages});
  final List<ClsMessage> allUsersMessages;
  @override
  State<ChatScreenGroup> createState() => _ChatScreenGroupState();
}

class _ChatScreenGroupState extends State<ChatScreenGroup> {
  late ScrollController scrollController;
  late FocusNode focusNode;
  Map<int, double?> dragOffsets = {};
  final TextEditingController _messageController = TextEditingController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context, listen: true);
    final messagesCubit = BlocProvider.of<MessagesCubit>(context, listen: true);
    final loginCubit = BlocProvider.of<LoginCubit>(context, listen: true);
    final themeCubit = BlocProvider.of<ThemeCubit>(context, listen: true);
    String senderUsername(int senderMessageID) {
      final user = chatsCubit.allUsersApp.firstWhere(
        (user) => user.userId == senderMessageID,
        orElse: () => UserData(
            userId: -1, username: 'Unknown User', friendId: -1, email: ''),
      );
      return user.username;
    }

    return Scaffold(
      body: Container(
        color: themeCubit.colorOfApp,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return AllUsersList(
                        chatsCubit: chatsCubit,
                      );
                    });
              },
              child: const MyHeaderWidget(
                headername: "@all",
                leftIcon: Icons.add_ic_call,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.allUsersMessages.length,
                itemBuilder: (context, index) {
                  final message = widget.allUsersMessages[index];
                  final bool isSentByUser =
                      loginCubit.currentUser.userId == message.senderId;

                  dragOffsets[index] = dragOffsets[index] ?? 0;

                  return GestureDetector(
                    onLongPress: () {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Delete message\n"${message.messageText}"',
                        confirmBtnText: 'Delete!',
                        onConfirmBtnTap: () {
                          Navigator.of(context).pop();
                          messagesCubit.deleteMessageGrp(message);
                          setState(() {});
                          
                        },
                      );
                    },
                    child: Transform.translate(
                      offset: Offset(dragOffsets[index]!, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: isSentByUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: message.senderId !=
                                          loginCubit.currentUser.userId
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(60),
                                          topLeft: Radius.circular(60),
                                        ),
                                        color: isSentByUser
                                            ? const Color.fromARGB(
                                                255, 103, 103, 103)
                                            : const Color.fromARGB(
                                                115, 180, 180, 180),
                                      ),
                                      child: Text(
                                        senderUsername(
                                          message.senderId,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    MainMessage(
                                      message: message,
                                      isSentByUser: isSentByUser,
                                      chatsCubit: chatsCubit,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 9),
                        ],
                      ),
                    ),
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
                      setState(() {});
                    },
                    iWillReply: false,
                    username: 'username',
                    messageTextToReply:
                        'messageTextToReply', // Pass it directly
                    messageController: _messageController,
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: themeCubit.colorOfApp),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          messagesCubit.insertMessageGroup(
                              loginCubit.currentUser.userId,
                              _messageController.text);
                          _messageController.clear();
                          _scrollToBottom();
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
    );
  }
}
