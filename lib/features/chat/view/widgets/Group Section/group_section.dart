import 'package:chatoid/core/utlis/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/features/chat/view/widgets/Group%20Section/group_chat_card.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:go_router/go_router.dart';

class GroupSection extends StatefulWidget {
  const GroupSection({super.key});

  @override
  State<GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<GroupSection> {
  @override
  Widget build(BuildContext context) {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);

    String messageDate = chatsCubit.formatMessageDate(chatsCubit
        .allUsersMessagesGroup[chatsCubit.allUsersMessagesGroup.length - 1]
        .createdAt);

    return Column(
      children: [
        GroupChatCard(
          allMessages: chatsCubit.allUsersMessagesGroup,
          isLastMessageFromOther: true,
          messageCount: chatsCubit.allUsersMessagesGroup.length,
          messageDate: messageDate,
          messageText: chatsCubit.allUsersMessagesGroup.isNotEmpty
              ? chatsCubit.allUsersMessagesGroup.last.messageText
              : 'No messages yet',
          onTap: () {
            final allMessages = chatsCubit.allUsersMessagesGroup;
            GoRouter.of(context).push(
              AppRouter.kChatGroupScreen,
              extra: allMessages,
            );
          },
        ),
      ],
    );
  }
}
