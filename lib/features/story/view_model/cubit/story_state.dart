import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/story/model/story.dart';

sealed class StoryState {}

final class StoryInitial extends StoryState {}

final class StoryLoading extends StoryState {}

final class StoryError extends StoryState {
  StoryError(String errorMsg);
}

final class StoryLoaded extends StoryState {
  final List<Story> allStories;
  final List<Map<UserData, List<Story>>> usersStory;

  StoryLoaded(this.allStories, this.usersStory);
}
