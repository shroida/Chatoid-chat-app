import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:flutter/material.dart';

mixin StoryRepo {
  Future<List<Story>> fetchAllStories();

  Future<void> addToStory(String text, BuildContext context) async {}

  Future<List<UserData>> fetchAllUsers();
  Future<void> setViewOnStory(
    int storyId,
    int viewerId,
  );
  Future<List<Map<UserData, List<Story>>>> retrieveViewersForMyStories(
      int currentuser, int storyId,);

  Future<void> deleteStory(int storyId);
}
