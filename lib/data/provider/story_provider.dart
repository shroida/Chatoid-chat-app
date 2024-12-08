import 'package:chatoid/data/models/story/story.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Story> _allStories = [];
  List<Story> get allStories => _allStories;

  List<UserData> _allUsers = [];
  List<UserData> get allUsers => _allUsers;

  List<Map<UserData, List<Story>>> usersStory = [];

  Future<void> addToStory(String text, BuildContext context) async {
    // Access the LoginCubit
    final loginCubit = Provider.of<LoginCubit>(context, listen: false);
    final currentUser = loginCubit.currentUserData; // Get the current user

    // Ensure currentUser is not null before using it
    if (currentUser == null) {
      throw Exception('No user is logged in.');
    }

    final response = await supabase.from('stories').insert({
      'user_id': currentUser.user_id, // Use the current user's ID
      'story_text': text,
      'created_at':
          DateTime.now().toIso8601String(), // Convert DateTime to string
      'expiry_time': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
    });

    await fetchAllStories();
  }

  Future<void> fetchAllStories() async {
    try {
      final response =
          await supabase.from('stories').select('id, user_id, story_text');

      _allStories =
          (response as List).map((story) => Story.fromJson(story)).toList();
      notifyListeners();
    } catch (e) {
    }
  }

  // Fetch all users
  Future<void> fetchAllUsers() async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('user_id, username, email');

      _allUsers =
          (response as List).map((user) => UserData.fromJson(user)).toList();
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> loadStories() async {
    await fetchAllStories();
    await fetchAllUsers();

    // Clear previous user-story mapping
    usersStory.clear();

    // Create the user-story mapping, but only add users who have stories
    for (var user in _allUsers) {
      // Get all stories for the current user
      List<Story> userStories =
          _allStories.where((story) => story.userId == user.user_id).toList();

      // Add only users who have stories
      if (userStories.isNotEmpty) {
        usersStory.add({user: userStories});
      }
    }
    notifyListeners();
  }

//  Future<void> setReactOnStory(
//     String messageText,
//     int receiverId,
//     int senderId,
//     String reaction, // Add reaction as an argument
//   ) async {
//     final response = await supabase
//         .from('story_views')
//         .update({'react': reaction})
//         .eq('sender_id', senderId)
//         .eq('message_text', messageText)
//         .eq('receiver_id', receiverId);

//     if (response != null) {
//       print('Error updating reaction: ${response.error!.message}');
//     } else {
//       print('Reaction updated successfully');
//     }
//   }
  Future<void> setViewOnStory(
    int storyId,
    int viewerId,
    // String reaction,
  ) async {
    try {
      final response = await supabase.from('story_views').insert({
        'story_id': storyId,
        'user_id': viewerId,
        // 'react': reaction,
        'viewed_at': DateTime.now().toIso8601String(),
      });

      notifyListeners();
      if (response != null) {
        notifyListeners();
      } else {
        notifyListeners();
      }
    } catch (e) {
      notifyListeners();
    }
  }

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
   Future<void> deleteStory(int storyId) async {
    final response = await supabase
        .from('stories')
        .delete()
        .eq('id', storyId);
  }
}
