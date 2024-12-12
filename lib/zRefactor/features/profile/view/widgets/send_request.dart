import 'package:chatoid/constants.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/home_page/view/home_page.dart';
import 'package:chatoid/zRefactor/features/messages/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SendRequest extends StatelessWidget {
  const SendRequest(
      {super.key,
      required this.areFriends,
      required this.currentUserId,
      required this.profileFriend});
  final bool areFriends;
  final int currentUserId;
  final UserData profileFriend;
  @override
  Widget build(BuildContext context) {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            if (areFriends) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'You are already friends with ${profileFriend.username}.'),
                ),
              );
            } else {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: "Confirm Friend Request",
                text: "Send a friend request to ${profileFriend.username}?",
                confirmBtnText: "Yes",
                cancelBtnText: "No",
                onConfirmBtnTap: () {
                  chatsCubit.addFriend(
                    currentUserId,
                    profileFriend,
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                },
                onCancelBtnTap: () => Navigator.pop(context),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: ChatAppColors.appBarColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              children: [
                Icon(areFriends ? Icons.emoji_emotions : Icons.person_add,
                    color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  areFriends ? "We are friends" : "Send Request",
                  style: const TextStyle(color: Colors.white),
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
                builder: (context) => ChatScreen(friendUser: profileFriend),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 34),
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
    );
  }
}
