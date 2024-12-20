import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
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

    return Scaffold(
      body: Container(
        color: themeCubit.colorOfApp,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                print('group Info');
              },
              child: const MyHeaderWidget(
                headername: "@all",
                leftIcon: Icons.add_ic_call,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController, // Use the scroll controller here
                itemCount: widget.allUsersMessages.length,
                itemBuilder: (context, index) {
                  final message = widget.allUsersMessages[index];
                  final bool isSentByUser =
                      loginCubit.currentUser.userId == message.senderId;

                  // Ensure dragOffsets is initialized for the index
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
                          // messagesCubit.deleteMessage(message);
                        },
                      );
                    },
                    child: Transform.translate(
                      offset:
                          Offset(dragOffsets[index]!, 0), // Apply drag offset
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: isSentByUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MainMessage(
                                  message: message,
                                  isSentByUser: isSentByUser,
                                  chatsCubit: chatsCubit,
                                ),
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
