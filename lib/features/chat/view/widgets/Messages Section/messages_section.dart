import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/features/chat/view/widgets/Messages%20Section/friends_list.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_state.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesSection extends StatelessWidget {
  const MessagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    final chatsCubit = context.read<ChatsCubit>();
    final messagesCubit = context.read<MessagesCubit>();
    final themeCubit = context.read<ThemeCubit>();

    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        if (state is ChatEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/loading_earth.gif'),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    chatsCubit.fetchFriends(loginCubit.currentUser.userId);
                    chatsCubit.fetchAllMessages(loginCubit.currentUser);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 34,
                    ),
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
                ),
              ],
            ),
          );
        } else if (state is ChatFriendsFetched) {
          return Center(
            child: Image.asset('assets/loading_earth.gif'),
          );
        } else {
          return FriendsList(
            messagesCubit: messagesCubit,
            chatsCubit: chatsCubit,
            authCubit: loginCubit,
          );
        }
      },
    );
  }
}
