import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllUsersList extends StatelessWidget {
  const AllUsersList({super.key, required this.chatsCubit});
  final ChatsCubit chatsCubit;

  @override
  Widget build(BuildContext context) {
    final themeCubit = BlocProvider.of<ThemeCubit>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // Limit height
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: ListView.builder(
        itemCount: chatsCubit.allUsersApp.length,
        itemBuilder: (context, index) {
          return Container(
              margin: const EdgeInsets.symmetric(vertical: 5,),
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
              decoration: BoxDecoration(
                color: themeCubit.colorOfApp,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                chatsCubit.allUsersApp[index].username,
                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,),
              ));
        },
      ),
    );
  }
}
