import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:chatoid/features/story/repository/story_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryRepoImpl with StoryRepo {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Story>> fetchAllStories() async {
    try {
      List<Story> allStories;
      final response =
          await supabase.from('stories').select('id, user_id, story_text');

      allStories =
          (response as List).map((story) => Story.fromJson(story)).toList();
      return allStories;
    } catch (e) {}
    return [];
  }

  @override
  Future<void> addToStory(String text, BuildContext context) async {
    // Access the LoginCubit
    final loginCubit = Provider.of<LoginCubit>(context, listen: false);
    final currentUser = loginCubit.currentUserData; // Get the current user

    await supabase.from('stories').insert({
      'user_id': currentUser.userId, // Use the current user's ID
      'story_text': text,
      'created_at':
          DateTime.now().toIso8601String(), // Convert DateTime to string
      'expiry_time':
          DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  @override
  Future<List<UserData>> fetchAllUsers() async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('user_id, username, email');

      return (response as List).map((user) => UserData.fromJson(user)).toList();
    } catch (e) {}
    return [];
  }

  @override
  Future<void> setViewOnStory(
    int storyId,
    int viewerId,
  ) async {
    try {
      final response = await supabase.from('story_views').insert({
        'story_id': storyId,
        'user_id': viewerId,
        // 'react': reaction,
        'viewed_at': DateTime.now().toIso8601String(),
      });

      if (response != null) {
      } else {}
    } catch (e) {}
  }

  @override
  Future<List<Map<UserData, List<Story>>>> retrieveViewersForMyStories(
      int currentuser, int storyId, List<UserData> allUsers) async {
    List<Map<UserData, List<Story>>> viewersWithStories = [];

    try {
      final response = await supabase
          .from('story_views')
          .select('user_id, stories!inner(id, user_id, story_text)')
          .eq('stories.userId', currentuser);

      // Initialize a map to group stories by viewer (user_id)
      Map<int, List<Story>> viewersMap = {};

      for (var entry in response) {
        int viewerId = entry['user_id'];
        Map<String, dynamic> storyData = entry['stories'];
        Story story = Story.fromJson(storyData);

        if (viewersMap.containsKey(viewerId)) {
          viewersMap[viewerId]!.add(story);
        } else {
          viewersMap[viewerId] = [story];
        }
      }

      // Convert the map to the required format
      for (var viewerId in viewersMap.keys) {
        final viewerData = allUsers.firstWhere(
          (user) => user.userId == viewerId,
          orElse: () => UserData(
              friendId: 0, userId: viewerId, username: 'Unknown', email: ''),
        );
        viewersWithStories.add({viewerData: viewersMap[viewerId]!});
      }

      return viewersWithStories;
    } catch (e) {
      debugPrint('Error retrieving viewers: $e');
      return [];
    }
  }

  @override
  Future<void> deleteStory(int storyId) async {
    await supabase.from('stories').delete().eq('id', storyId);
  }
}
