import 'package:flutter/material.dart';

class StoryWidget extends StatelessWidget {
  final String imageUrl;
  final String username;
  final bool isAddStory;
  final int storyCount;

  const StoryWidget({
    super.key,
    required this.imageUrl,
    required this.username,
    this.isAddStory = false,
    this.storyCount = 1,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30), // Increase left padding
      margin: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,

                //borderStory
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: storyCount > 0 ? Colors.blue : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: isAddStory ? null : AssetImage(imageUrl),
                  backgroundColor: isAddStory ? Colors.grey[300] : null,
                  child: isAddStory
                      ? const Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            isAddStory ? 'Add Story' : username,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
