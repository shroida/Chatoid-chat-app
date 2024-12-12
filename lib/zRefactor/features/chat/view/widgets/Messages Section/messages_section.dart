import 'package:chatoid/constants.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/zRefactor/features/chat/view/widgets/Messages%20Section/friends_list.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_state.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesSection extends StatelessWidget {
  const MessagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    final messagesCubit = BlocProvider.of<MessagesCubit>(context);
    final themeCubit = BlocProvider.of<ThemeCubit>(context);

    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return Center(child: Image.asset('assets/loading_earth.gif'));
        } else if (state is ChatEmpty) {
          return Center(
            child: Column(
              children: [
                Image.asset('assets/loading_earth.gif'),
                GestureDetector(
                  onTap: () {
                    chatsCubit.fetchFriends(authProvider
                        .currentUser.user_id); // Trigger fetch friends
                    chatsCubit.fetchAllMessages(
                        authProvider.currentUser); // Trigger fetch messages
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 34),
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
        } else {
          return FriendsList(
            messagesCubit: messagesCubit,
            chatsCubit: chatsCubit,
            authCubit: authProvider,
          );
        }
      },
    );
  }
}
