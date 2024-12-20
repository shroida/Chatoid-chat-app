import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/profile/view/profile.dart';
import 'package:flutter/material.dart';

class MyHeaderWidget extends StatefulWidget {
  final String headername;
  final IconData leftIcon; // For the back icon
  final Color backgroundColor;
  final Color? iconColor;
  final UserData? userProfile;

  const MyHeaderWidget({
    super.key,
    required this.headername,
    required this.leftIcon,
    this.iconColor,
    this.userProfile,
    this.backgroundColor = ChatAppColors.appBarColor,
  });

  @override
  MyHeaderWidgetState createState() => MyHeaderWidgetState();
}

class MyHeaderWidgetState extends State<MyHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ChatAppColors.chatBubbleColorReceiver,
            widget.backgroundColor, // Use the passed background color
          ],
          stops: const [0.5, 0.5],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(60),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                        Icons.arrow_back), // Use the passed left icon
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                  userProfile: widget.userProfile ??
                                      UserData(
                                          friendId: 5,
                                          userId: 3,
                                          username: 'username',
                                          email: 'email'))));
                    },
                    child: CircleAvatar(
                      child: Image.asset('assets/profile.gif'),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.headername,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: const BoxDecoration(
              color: ChatAppColors.chatBubbleColorReceiver,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
              ),
            ),
            child: Row(children: [
              IconButton(
                icon: Icon(widget.leftIcon,
                    color: widget.iconColor ??
                        Colors.white), // Use optional icon color
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert,
                    color: widget.iconColor ?? Colors.white),
                onPressed: () {},
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
