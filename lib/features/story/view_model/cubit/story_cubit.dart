import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:chatoid/features/story/repository/story_repo_impl.dart';
import 'package:chatoid/features/story/view_model/cubit/story_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCubit extends Cubit<StoryState> {
  StoryCubit() : super(StoryInitial()) {
    _subscribeToStoryChanges();
    fetchAllStories();
  }
  final StoryRepoImpl _storyRepoImpl = StoryRepoImpl();

  // Subscribe to real-time changes in the "stories" table
  Future<void> _subscribeToStoryChanges() async {
    _storyRepoImpl.subscribe('stories', () async {
      await fetchAllStories();
    });
  }

  List<Story> _allStories = [];
  List<Story> get allStories => _allStories;

  List<UserData> _allUsers = [];
  List<UserData> get allUsers => _allUsers;

  List<Map<UserData, List<Story>>> usersStory = [];

  Future<void> fetchAllStories() async {
    emit(StoryLoading());
    try {
      final stories = await _storyRepoImpl.fetchAllStories();
      _allStories = stories;

      // After fetching stories, load users and their stories
      _allUsers = await _storyRepoImpl.fetchAllUsers();
      usersStory.clear();

      for (var user in _allUsers) {
        List<Story> userStories =
            _allStories.where((story) => story.userId == user.userId).toList();
        if (userStories.isNotEmpty) {
          usersStory.add({user: userStories});
        }
      }
      
      emit(StoryLoaded(_allStories, usersStory));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> addToStory(String text, BuildContext context) async {
    try {
      await _storyRepoImpl.addToStory(text, context);
      await fetchAllStories(); // Fetch updated stories and emit a new state
      emit(StoryLoaded(_allStories, usersStory));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> loadStories(UserData currentUser) async {
    fetchAllStories();

    _allUsers = await _storyRepoImpl.fetchAllUsers();

    // Clear previous user-story mapping
    usersStory.clear();

    for (var user in _allUsers) {
      List<Story> userStories =
          _allStories.where((story) => story.userId == user.userId).toList();

      // Add only users who have stories
      if (userStories.isNotEmpty) {
        usersStory.add({user: userStories});
      }
    }

    // Add the current user's stories to the list explicitly
    final currentUserStories = _allStories
        .where((story) => story.userId == currentUser.userId)
        .toList();

    if (currentUserStories.isNotEmpty) {
      usersStory.add({
        currentUser: currentUserStories,
      });
    }

    emit(StoryLoaded(_allStories, usersStory));
  }

  Future<void> setViewOnStory(
    int storyId,
    int viewerId,
  ) async {
    await _storyRepoImpl.setViewOnStory(storyId, viewerId);
  }

  Future<List<Map<UserData, List<Story>>>> retrieveViewersForMyStories(
    int currentuser,
    int storyId,
  ) async {
    List<Map<UserData, List<Story>>> viewersWithStories = [];
    viewersWithStories =
        await _storyRepoImpl.retrieveViewersForMyStories(currentuser, storyId);
    return viewersWithStories;
  }

  Future<void> deleteStory(int storyId) async {
    await _storyRepoImpl.deleteStory(storyId);
    emit(StoryLoaded(_allStories, usersStory));
  }
}
