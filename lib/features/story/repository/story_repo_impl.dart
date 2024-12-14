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
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('There is an issue'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('There is an issue'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('There is an issue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Future<List<Map<UserData, List<Story>>>> retrieveViewersForMyStories(
    int currentuser,
    int storyId,
  ) async {
    List<Map<UserData, List<Story>>> viewersWithStories = [];

    try {
      final response = await supabase
          .from('story_views')
          .select('user_id, stories!inner(id, user_id, story_text)')
          .eq('stories.user_id', currentuser);

      // Initialize a map to group stories by viewer (user_id)
      Map<int, List<Story>> viewersMap = {};

      for (var row in response) {
        // Extract user data and story information
        int viewerId = row['user_id'];
        var storyData = row['stories'];
        Story story = Story.fromJson(
            storyData); // Assuming you have a Story.fromJson constructor

        // If the viewer is not yet in the map, initialize their story list
        if (!viewersMap.containsKey(viewerId)) {
          viewersMap[viewerId] = [];
        }

        // Add the current story to the viewer's list of stories
        viewersMap[viewerId]!.add(story);
      }

      // Convert the map into a list of UserData with their viewed stories
      for (var entry in viewersMap.entries) {
        // Fetch user data for each viewer (assuming UserData.fromJson is defined)
        UserData viewer = await _getUserDataById(
            entry.key); // Implement this function to fetch user details
        viewersWithStories.add({viewer: entry.value});
      }
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('There is an issue'),
          backgroundColor: Colors.red,
        ),
      );
    }

    return viewersWithStories;
  }

  Future<UserData> _getUserDataById(int userId) async {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .single();
    return UserData.fromJson(response);
  }

  @override
  Future<void> deleteStory(int storyId) async {
    await supabase.from('stories').delete().eq('id', storyId);
  }

  Future<void> subscribe(
    String table,
    Future<void> Function() callbackAction,
  ) async {
    try {
      supabase
          .channel('public:$table')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (payload) async {
              await callbackAction();
            },
          )
          .subscribe();
    } catch (e) {
      rethrow;
    }
  }
}
