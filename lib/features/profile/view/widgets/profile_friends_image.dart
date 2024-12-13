import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileFriendsImage extends StatelessWidget {
  const ProfileFriendsImage(
      {super.key,
      required this.isCurrentUserProfile,
      required this.friendData,
      required this.userProfile});
  final bool isCurrentUserProfile;
  final List<UserData> friendData;
  final UserData userProfile;
  @override
  Widget build(BuildContext context) {
    final chatsCubit = BlocProvider.of<ChatsCubit>(context);
    void showSliderBottomSheet() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200, // Adjust the height of the slider
                enlargeCenterPage: true, // Zoom in the centered item
                autoPlay: true, // Auto slide the images
                autoPlayInterval:
                    const Duration(seconds: 3), // Duration between slides
                enableInfiniteScroll: true, // Loop through the items
                viewportFraction:
                    0.8, // How much of the previous/next item is visible
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
                        onTap: () {
                          // setState(() {
                          //   chatsCubit.upLoadImageProfile(
                          //       imagePath,
                          //       widget.userProfile
                          //           .user_id);
                          //   widget.userProfile.profile_image = imagePath;
                          //   Navigator.pop(context);
                          // });
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
          }, // Show slider on tap
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/profile.gif',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            Column(
              children: [
                Text(
                  isCurrentUserProfile
                      ? chatsCubit.friendsList.length.toString()
                      : friendData.length.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Friends',
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
