import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileFriendsImage extends StatefulWidget {
  const ProfileFriendsImage({
    super.key,
    required this.isCurrentUserProfile,
    required this.friendData,
    required this.userProfile,
    required this.likes,
  });

  final bool isCurrentUserProfile;
  final int likes;
  final List<UserData> friendData;
  final UserData userProfile;

  @override
  State<ProfileFriendsImage> createState() => _ProfileFriendsImageState();
}

class _ProfileFriendsImageState extends State<ProfileFriendsImage> {
  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().loadUserData();
  }

  final supabase = Supabase.instance;

  @override
  Widget build(BuildContext context) {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    final loginCubit = BlocProvider.of<LoginCubit>(context);

    void showSliderBottomSheet() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enableInfiniteScroll: true,
                viewportFraction: 0.8,
              ),
              items: profilesImages.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await chatsCubit.upLoadImageProfile(
                              imagePath, loginCubit.currentUser.userId);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: 200,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showSliderBottomSheet();
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
              return BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is LoginSuccess) {
                    if (chatsCubit.allUsersApp.isNotEmpty) {
                      String imgprofile = chatsCubit.allUsersApp
                          .firstWhere(
                            (user) => user.userId == widget.userProfile.userId,
                          )
                          .profileImage;
                      return ClipOval(
                        child: Image.asset(
                          imgprofile,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      return ClipOval(
                        child: Image.asset(
                          'assets/loading_earth.gif',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  } else {
                    return const Text('No data available');
                  }
                },
              );
            }),
          ),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Column(
              children: [
                Text(
                  widget.isCurrentUserProfile
                      ? chatsCubit.friendsList.length.toString()
                      : widget.friendData.length.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Friends',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: [
                Text(
                  widget.likes.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Likes',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
