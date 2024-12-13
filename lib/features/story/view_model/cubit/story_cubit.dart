import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:chatoid/features/story/repository/story_repo_impl.dart';
import 'package:chatoid/features/story/view_model/cubit/story_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCubit extends Cubit<StoryState> {
  StoryCubit() : super(StoryInitial());
  final StoryRepoImpl _storyRepoImpl = StoryRepoImpl();

  List<Story> _allStories = [];
  List<Story> get allStories => _allStories;

  List<UserData> _allUsers = [];
  List<UserData> get allUsers => _allUsers;

  List<Map<UserData, List<Story>>> usersStory = [];

  void fetchAllStories() async {
    emit(StoryLoading());
    try {
      _allStories = await _storyRepoImpl.fetchAllStories();
      emit(StoryLoaded(_allStories));
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> addToStory(String text, BuildContext context) async {
    try {
      await _storyRepoImpl.addToStory(text, context);
      fetchAllStories(); // Fetch updated stories and emit a new state
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> loadStories() async {
    fetchAllStories();
    _allUsers = await _storyRepoImpl.fetchAllUsers();

    // Clear previous user-story mapping
    usersStory.clear();

    for (var user in _allUsers) {
      // Get all stories for the current user
      List<Story> userStories =
          _allStories.where((story) => story.userId == user.userId).toList();

      // Add only users who have stories
      if (userStories.isNotEmpty) {
        usersStory.add({user: userStories});
      }
    }
  }

  Future<void> setViewOnStory(
    int storyId,
    int viewerId,
  ) async {
    await _storyRepoImpl.setViewOnStory(storyId, viewerId);
  }

  Future<List<Map<UserData, List<Story>>>> retrieveViewersForMyStories(
      int currentuser, int storyId, List<UserData> allUsers) async {
    List<Map<UserData, List<Story>>> viewersWithStories = [];
    viewersWithStories = await _storyRepoImpl.retrieveViewersForMyStories(
        currentuser, storyId, allUsers);
    return viewersWithStories;
  }

  Future<void> deleteStory(int storyId) async {
    await _storyRepoImpl.deleteStory(storyId);
  }
}
